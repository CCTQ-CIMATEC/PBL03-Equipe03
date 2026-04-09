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
    // O monitor publica transações arquiteturais observadas:
    // - writeback no estágio W
    // - store no estágio M
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
    // Preenche campos auxiliares comuns
    // ------------------------------------------------------------
    function void fill_debug_fields(ref rv32i_commit_tr tr);
        tr.x0_value    = vif.mon_cb.x0_value_mon;

        tr.stallF      = vif.mon_cb.stallF_mon;
        tr.stallD      = vif.mon_cb.stallD_mon;
        tr.flushE      = vif.mon_cb.flushE_mon;

        tr.pc_fetch    = vif.mon_cb.pc_fetch_mon;
        tr.instr_fetch = vif.mon_cb.instr_fetch_mon;
        tr.instr_dec   = vif.mon_cb.instr_decode_mon;
        tr.instr_ex    = vif.mon_cb.instr_execute_mon;
    endfunction

    // ------------------------------------------------------------
    // Publica evento de store observado no estágio M
    // Requer pc_memory_mon / instr_memory_mon na interface
    // ------------------------------------------------------------
    task publish_store_event();
        rv32i_commit_tr tr;

        tr = rv32i_commit_tr::type_id::create(
                $sformatf("store_tr_%0d", cycle_count), this);

        tr.cycle     = cycle_count;

        // Evento arquitetural do estágio M
        tr.pc        = vif.mon_cb.pc_memory_mon;
        tr.instr     = vif.mon_cb.instr_memory_mon;

        // Store não escreve registrador
        tr.regwrite  = 1'b0;
        tr.rd_addr   = 5'd0;
        tr.rd_data   = 32'h0000_0000;

        // Campos de memória
        tr.memwrite  = 1'b1;
        tr.mem_addr  = vif.mon_cb.alu_result_m_mon;
        tr.mem_wdata = vif.mon_cb.write_data_m_mon;
        tr.mem_wmask = vif.mon_cb.write_enable_m_mon;

        fill_debug_fields(tr);

        commit_ap.write(tr);

        `uvm_info("RV32I_MON",
            $sformatf(
                "STORE  cycle=%0d pc=%08h instr=%08h mem_addr=%08h mem_wdata=%08h mem_wmask=%04b x0=%08h stallF=%0b stallD=%0b flushE=%0b",
                tr.cycle, tr.pc, tr.instr, tr.mem_addr, tr.mem_wdata,
                tr.mem_wmask, tr.x0_value, tr.stallF, tr.stallD, tr.flushE
            ),
            UVM_MEDIUM
        )
    endtask

    // ------------------------------------------------------------
    // Publica evento de writeback observado no estágio W
    // ------------------------------------------------------------
    task publish_writeback_event();
        rv32i_commit_tr tr;

        // Filtro opcional para PC inválido/sentinela
        if (vif.mon_cb.pc_commit_mon == 32'hffff_fffc)
            return;

        tr = rv32i_commit_tr::type_id::create(
                $sformatf("commit_tr_%0d", cycle_count), this);

        tr.cycle     = cycle_count;

        // Evento arquitetural do estágio W
        tr.pc        = vif.mon_cb.pc_commit_mon;
        tr.instr     = vif.mon_cb.instr_commit_mon;

        tr.regwrite  = vif.mon_cb.regwrite_w_mon;
        tr.rd_addr   = vif.mon_cb.rd_w_mon;
        tr.rd_data   = vif.mon_cb.result_w_mon;

        // Não é store
        tr.memwrite  = 1'b0;
        tr.mem_addr  = 32'h0000_0000;
        tr.mem_wdata = 32'h0000_0000;
        tr.mem_wmask = 4'b0000;

        fill_debug_fields(tr);

        commit_ap.write(tr);

        `uvm_info("RV32I_MON",
            $sformatf(
                "COMMIT cycle=%0d pc=%08h instr=%08h rd=x%0d data=%08h x0=%08h stallF=%0b stallD=%0b flushE=%0b",
                tr.cycle, tr.pc, tr.instr, tr.rd_addr, tr.rd_data,
                tr.x0_value, tr.stallF, tr.stallD, tr.flushE
            ),
            UVM_MEDIUM
        )
    endtask

    // ------------------------------------------------------------
    // Run phase
    // Estratégia:
    // - espera borda de clock pelo clocking block do monitor
    // - ignora ciclos em reset
    // - publica writeback quando houver regwrite no estágio W
    // - publica store quando houver write_enable no estágio M
    //
    // Observação:
    // podem existir até 2 transações no mesmo ciclo.
    // Ordem adotada:
    // 1) writeback em W  -> instrução mais antiga
    // 2) store em M      -> instrução mais nova
    // ------------------------------------------------------------
    task run_phase(uvm_phase phase);
        forever begin
            @(vif.mon_cb);

            // reset ativo em nível baixo
            if (!vif.mon_cb.rst_n) begin
                cycle_count = 0;
                continue;
            end

            cycle_count++;

            // 1) Evento de writeback em W
            if (vif.mon_cb.regwrite_w_mon) begin
                publish_writeback_event();
            end

            // 2) Evento de store em M
            if (vif.mon_cb.write_enable_m_mon != 4'b0000) begin
                publish_store_event();
            end
        end
    endtask

endclass

`endif