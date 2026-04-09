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
    // Helpers para stores
    // ------------------------------------------------------------
    function automatic int unsigned count_mask_bytes(
        input logic [3:0] wmask
    );
        int unsigned n;
        n = 0;

        for (int i = 0; i < 4; i++) begin
            if (wmask[i])
                n++;
        end

        return n;
    endfunction

    function automatic logic [31:0] expected_store_payload(
        input logic [31:0] exp_data,
        input logic [3:0]  wmask
    );
        logic [31:0] payload;
        int unsigned n;

        payload = 32'h0000_0000;
        n = count_mask_bytes(wmask);

        for (int i = 0; i < n; i++) begin
            payload[i*8 +: 8] = exp_data[i*8 +: 8];
        end

        return payload;
    endfunction

    function automatic logic [31:0] observed_store_payload(
        input logic [31:0] obs_data,
        input logic [3:0]  wmask
    );
        logic [31:0] payload;
        int unsigned out_idx;

        payload = 32'h0000_0000;
        out_idx = 0;

        for (int lane = 0; lane < 4; lane++) begin
            if (wmask[lane]) begin
                payload[out_idx*8 +: 8] = obs_data[lane*8 +: 8];
                out_idx++;
            end
        end

        return payload;
    endfunction

    function automatic bit masked_store_payload_match(
        input logic [31:0] exp_data,
        input logic [31:0] obs_data,
        input logic [3:0]  wmask
    );
        return expected_store_payload(exp_data, wmask) ===
               observed_store_payload(obs_data, wmask);
    endfunction

    function automatic string store_payload_diff_str(
        input logic [31:0] exp_data,
        input logic [31:0] obs_data,
        input logic [3:0]  wmask
    );
        logic [31:0] exp_p;
        logic [31:0] obs_p;

        exp_p = expected_store_payload(exp_data, wmask);
        obs_p = observed_store_payload(obs_data, wmask);

        return $sformatf("payload_exp=%08h payload_obs=%08h",
                         exp_p, obs_p);
    endfunction

    // ------------------------------------------------------------
    // Comparação principal das transações
    // - scoreboard arquitetural
    // - não compara sinais temporais de controle do pipeline
    // - compara payload normalizado para stores parciais
    // ------------------------------------------------------------
    function automatic bit compare_commit_store_aware(
        input rv32i_commit_tr obs_tr,
        input rv32i_commit_tr exp_tr,
        output string cmp_msg
    );
        cmp_msg = "";

        // --------------------------------------------------------
        // Campos comuns
        // --------------------------------------------------------
        if (obs_tr.pc !== exp_tr.pc) begin
            cmp_msg = $sformatf("PC mismatch: exp=%08h obs=%08h",
                                exp_tr.pc, obs_tr.pc);
            return 1'b0;
        end

        if (obs_tr.instr !== exp_tr.instr) begin
            cmp_msg = $sformatf("INSTR mismatch: exp=%08h obs=%08h",
                                exp_tr.instr, obs_tr.instr);
            return 1'b0;
        end

        if (obs_tr.regwrite !== exp_tr.regwrite) begin
            cmp_msg = $sformatf("REGWRITE mismatch: exp=%0b obs=%0b",
                                exp_tr.regwrite, obs_tr.regwrite);
            return 1'b0;
        end

        if (obs_tr.rd_addr !== exp_tr.rd_addr) begin
            cmp_msg = $sformatf("RD mismatch: exp=x%0d obs=x%0d",
                                exp_tr.rd_addr, obs_tr.rd_addr);
            return 1'b0;
        end

        if (obs_tr.rd_data !== exp_tr.rd_data) begin
            cmp_msg = $sformatf("RD_DATA mismatch: exp=%08h obs=%08h",
                                exp_tr.rd_data, obs_tr.rd_data);
            return 1'b0;
        end

        if (obs_tr.x0_value !== exp_tr.x0_value) begin
            cmp_msg = $sformatf("X0 mismatch: exp=%08h obs=%08h",
                                exp_tr.x0_value, obs_tr.x0_value);
            return 1'b0;
        end

        // --------------------------------------------------------
        // Campos de memória
        // --------------------------------------------------------
        if (obs_tr.memwrite !== exp_tr.memwrite) begin
            cmp_msg = $sformatf("MEMWRITE mismatch: exp=%0b obs=%0b",
                                exp_tr.memwrite, obs_tr.memwrite);
            return 1'b0;
        end

        if (obs_tr.mem_addr !== exp_tr.mem_addr) begin
            cmp_msg = $sformatf("MEM_ADDR mismatch: exp=%08h obs=%08h",
                                exp_tr.mem_addr, obs_tr.mem_addr);
            return 1'b0;
        end

        if (obs_tr.mem_wmask !== exp_tr.mem_wmask) begin
            cmp_msg = $sformatf("MEM_WMASK mismatch: exp=%04b obs=%04b",
                                exp_tr.mem_wmask, obs_tr.mem_wmask);
            return 1'b0;
        end

        if (exp_tr.memwrite) begin
            if (!masked_store_payload_match(exp_tr.mem_wdata,
                                            obs_tr.mem_wdata,
                                            exp_tr.mem_wmask)) begin
                cmp_msg = $sformatf(
                    "MEM_WDATA mismatch (normalized): exp=%08h obs=%08h wmask=%04b | %s",
                    exp_tr.mem_wdata,
                    obs_tr.mem_wdata,
                    exp_tr.mem_wmask,
                    store_payload_diff_str(exp_tr.mem_wdata,
                                           obs_tr.mem_wdata,
                                           exp_tr.mem_wmask)
                );
                return 1'b0;
            end
        end
        else begin
            if (obs_tr.mem_wdata !== exp_tr.mem_wdata) begin
                cmp_msg = $sformatf("MEM_WDATA mismatch: exp=%08h obs=%08h",
                                    exp_tr.mem_wdata, obs_tr.mem_wdata);
                return 1'b0;
            end
        end

        return 1'b1;
    endfunction

    // ------------------------------------------------------------
    // Run phase
    // Compara transações observadas e esperadas em ordem.
    //
    // Nesta versão, uma transação pode representar:
    // - writeback no estágio W
    // - store no estágio M
    //
    // Portanto, o scoreboard compara "eventos arquiteturais"
    // em FIFO, sem assumir uma transação por ciclo nem
    // regwrite obrigatório.
    // ------------------------------------------------------------
    task run_phase(uvm_phase phase);
        rv32i_commit_tr obs_tr;
        rv32i_commit_tr exp_tr;
        string cmp_msg;

        forever begin
            obs_fifo.get(obs_tr);
            exp_fifo.get(exp_tr);

            num_compares++;

            if (compare_commit_store_aware(obs_tr, exp_tr, cmp_msg)) begin
                num_pass++;

                `uvm_info("RV32I_SB_PASS",
                    $sformatf(
                        "COMPARE PASS [%0d]\nEXP: %s\nOBS: %s",
                        num_compares,
                        exp_tr.convert2string(),
                        obs_tr.convert2string()
                    ),
                    UVM_LOW
                )
            end
            else begin
                num_fail++;

                `uvm_error("RV32I_SB_FAIL",
                    $sformatf(
                        "COMPARE FAIL [%0d] -> %s\nEXP: %s\nOBS: %s",
                        num_compares,
                        cmp_msg,
                        exp_tr.convert2string(),
                        obs_tr.convert2string()
                    ))
            end
        end
    endtask

    // ------------------------------------------------------------
    // Report phase
    // ------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("RV32I_SB_REPORT",
            $sformatf(
                "Scoreboard summary: compares=%0d pass=%0d fail=%0d",
                num_compares, num_pass, num_fail
            ),
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