`ifndef RV32I_SCOREBOARD_SV
`define RV32I_SCOREBOARD_SV

class rv32i_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(rv32i_scoreboard)

    // ------------------------------------------------------------
    // FIFOs de análise
    // obs_fifo: transações observadas no DUT
    // exp_fifo: transações previstas pelo ref model
    // ------------------------------------------------------------
    uvm_tlm_analysis_fifo #(rv32i_commit_tr) obs_fifo;
    uvm_tlm_analysis_fifo #(rv32i_commit_tr) exp_fifo;

    // ------------------------------------------------------------
    // Contadores
    // ------------------------------------------------------------
    int unsigned num_compares;
    int unsigned num_pass;
    int unsigned num_fail;

    // ------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------
    function new(string name = "rv32i_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // ------------------------------------------------------------
    // Build phase
    // ------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        obs_fifo = new("obs_fifo", this);
        exp_fifo = new("exp_fifo", this);

        num_compares = 0;
        num_pass     = 0;
        num_fail     = 0;
    endfunction

    // ------------------------------------------------------------
    // Run phase
    // Compara transações observadas e esperadas em ordem.
    // ------------------------------------------------------------
    task run_phase(uvm_phase phase);
        rv32i_commit_tr obs_tr;
        rv32i_commit_tr exp_tr;
        string cmp_msg;

        forever begin
            obs_fifo.get(obs_tr);
            exp_fifo.get(exp_tr);

            num_compares++;

            if (obs_tr.compare_commit(exp_tr, cmp_msg)) begin
                num_pass++;

                `uvm_info("RV32I_SB_PASS",
                    $sformatf("COMPARE PASS [%0d]\nEXP: %s\nOBS: %s",
                              num_compares,
                              exp_tr.convert2string(),
                              obs_tr.convert2string()),
                    UVM_LOW
                )
            end
            else begin
                num_fail++;

                `uvm_error("RV32I_SB_FAIL",
                    $sformatf("COMPARE FAIL [%0d] -> %s\nEXP: %s\nOBS: %s",
                              num_compares, cmp_msg,
                              exp_tr.convert2string(),
                              obs_tr.convert2string()))
            end
        end
    endtask

    // ------------------------------------------------------------
    // Report phase
    // ------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("RV32I_SB_REPORT",
            $sformatf("Scoreboard summary: compares=%0d pass=%0d fail=%0d",
                      num_compares, num_pass, num_fail),
            UVM_NONE
        )

        if (num_fail == 0 && num_compares > 0) begin
            `uvm_info("RV32I_SB_RESULT",
                "SCOREBOARD FINAL: PASS",
                UVM_NONE
            )
        end
        else if (num_fail > 0) begin
            `uvm_error("RV32I_SB_RESULT",
                $sformatf("SCOREBOARD FINAL: FAIL (%0d falhas)", num_fail))
        end
        else begin
            `uvm_warning("RV32I_SB_RESULT",
                "SCOREBOARD FINAL: nenhuma comparação foi executada")
        end
    endfunction

endclass

`endif