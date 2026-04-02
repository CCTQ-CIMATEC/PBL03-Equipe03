`timescale 1ns/1ps

module rv32i_tb;

    import uvm_pkg::*;
    import rv32i_pkg::*;
    import rv32i_tb_cfg_pkg::*;
    `include "uvm_macros.svh"

    // ============================================================
    // Clock / Reset
    // rst_n é ativo em nível baixo para casar com o DUT
    // ============================================================
    logic clk;
    logic rst_n;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
    end

    // ============================================================
    // Interface
    // ============================================================
    rv32i_if vif (
        .clk   (clk),
        .rst_n (rst_n)
    );

    // ============================================================
    // DUT
    // ============================================================
    pipelined dut (
        .clk (clk),
        .rst (rst_n)
    );

    // ============================================================
    // Carga do programa
    // ============================================================
    string prog_file;

    initial begin
        if (!$value$plusargs("PROG=%s", prog_file))
            prog_file = RV32I_DEFAULT_PROG_FILE;

        #1ps;
        $readmemh(prog_file, dut.u_instruction_memory.instrmem);

        $display("TB: programa carregado de '%s'", prog_file);
        $display("TB: instrmem[0] = %h", dut.u_instruction_memory.instrmem[0]);
        $display("TB: instrmem[1] = %h", dut.u_instruction_memory.instrmem[1]);
    end
    // ============================================================
    // Taps hierárquicos para o monitor
    // ============================================================
    assign vif.pc_fetch_mon      = dut.pcF;
    assign vif.instr_fetch_mon   = dut.instrF;

    assign vif.pc_decode_mon     = dut.pcD;
    assign vif.instr_decode_mon  = dut.instrD;

    assign vif.instr_execute_mon = dut.instrE;

    assign vif.regwrite_w_mon    = dut.regwriteW;
    assign vif.rd_w_mon          = dut.rdW;
    assign vif.result_w_mon      = dut.resultW;

    // Para Fase 1, como o fluxo é sequencial, usar pcplus4W-4 é suficiente
    assign vif.pc_commit_mon     = dut.pcplus4W - 32'd4;

    assign vif.x0_value_mon      = dut.u_reg_file_n.rf[0];

    assign vif.stallF_mon        = dut.stallF;
    assign vif.stallD_mon        = dut.stallD;
    assign vif.flushE_mon        = dut.flushE;

    assign vif.alu_result_m_mon  = dut.aluresultM;
    assign vif.write_data_m_mon  = dut.writedataM;
    assign vif.write_enable_m_mon = dut.writeenableM;

    assign vif.instr_commit_mon =
    dut.u_instruction_memory.instrmem[(dut.pcplus4W - 32'd4) >> 2];

    // ============================================================
    // UVM config
    // ============================================================
    initial begin
        uvm_config_db#(virtual rv32i_if)::set(null, "*", "vif", vif);
        run_test();
    end

endmodule