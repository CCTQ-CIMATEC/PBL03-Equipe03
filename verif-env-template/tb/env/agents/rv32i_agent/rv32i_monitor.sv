`ifndef RV32I_MONITOR_SV
`define RV32I_MONITOR_SV

class rv32i_monitor extends uvm_monitor;
    `uvm_component_utils(rv32i_monitor)

    // ------------------------------------------------------------
    // Virtual interface
    // ------------------------------------------------------------
    virtual rv32i_if vif;

    // ------------------------------------------------------------
    // Analysis port
    // O monitor publica uma transação por evento de writeback.
    // ------------------------------------------------------------
    uvm_analysis_port #(rv32i_commit_tr) commit_ap;

    // ------------------------------------------------------------
    // Contador de ciclos só para debug/rastreabilidade
    // ------------------------------------------------------------
    longint unsigned cycle_count;

    // ------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------
    function new(string name = "rv32i_monitor", uvm_component parent = null);
        super.new(name, parent);
        commit_ap   = new("commit_ap", this);
        cycle_count = 0;
    endfunction

    // ------------------------------------------------------------
    // Build phase
    // ------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual rv32i_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF",
                $sformatf("%s: virtual interface rv32i_if não encontrada",
                          get_full_name()))
        end
    endfunction

    // ------------------------------------------------------------
    // Run phase
    // Estratégia:
    // - espera borda de clock pelo clocking block do monitor
    // - ignora ciclos em reset
    // - cria uma transação sempre que houver regwrite no writeback
    //
    // Observação:
    // o monitor NÃO faz checker funcional de fase.
    // Ele apenas observa e publica commits.
    // ------------------------------------------------------------
    task run_phase(uvm_phase phase);
        rv32i_commit_tr tr;

        forever begin
            @(vif.mon_cb);

            // reset ativo em nível baixo
            if (!vif.mon_cb.rst_n) begin
                cycle_count = 0;
                continue;
            end

            cycle_count++;

            // Para este ambiente, tratamos writeback como "commit"
            if (vif.mon_cb.regwrite_w_mon) begin
                // Filtro opcional para PC inválido/sentinela
                if (vif.mon_cb.pc_commit_mon == 32'hffff_fffc)
                    continue;

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("commit_tr_%0d", cycle_count), this);

                // -----------------------------
                // Campos principais
                // -----------------------------
                tr.cycle     = cycle_count;
                tr.pc        = vif.mon_cb.pc_commit_mon;
                tr.instr     = vif.mon_cb.instr_commit_mon;
                tr.regwrite  = vif.mon_cb.regwrite_w_mon;
                tr.rd_addr   = vif.mon_cb.rd_w_mon;
                tr.rd_data   = vif.mon_cb.result_w_mon;
                tr.x0_value  = vif.mon_cb.x0_value_mon;

                // -----------------------------
                // Campos auxiliares de debug
                // -----------------------------
                tr.stallF      = vif.mon_cb.stallF_mon;
                tr.stallD      = vif.mon_cb.stallD_mon;
                tr.flushE      = vif.mon_cb.flushE_mon;

                tr.pc_fetch    = vif.mon_cb.pc_fetch_mon;
                tr.instr_fetch = vif.mon_cb.instr_fetch_mon;
                tr.instr_dec   = vif.mon_cb.instr_decode_mon;
                tr.instr_ex    = vif.mon_cb.instr_execute_mon;

                // -----------------------------
                // Publica transação
                // -----------------------------
                commit_ap.write(tr);

                `uvm_info("RV32I_MON",
                    $sformatf(
                        "COMMIT cycle=%0d pc=%08h instr=%08h rd=x%0d data=%08h x0=%08h stallF=%0b stallD=%0b flushE=%0b",
                        tr.cycle, tr.pc, tr.instr, tr.rd_addr, tr.rd_data,
                        tr.x0_value, tr.stallF, tr.stallD, tr.flushE
                    ),
                    UVM_MEDIUM
                )
            end
        end
    endtask

endclass

`endif