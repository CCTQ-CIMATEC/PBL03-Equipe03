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
        if (!$value$plusargs("PROG=%s", prog_file)) begin
                $fatal(1, "[RV32I_TB] Plusarg PROG nao foi informado");
            end

        rv32i_check_mem_file_or_fatal(prog_file);

        $readmemh(prog_file, dut.u_instruction_memory.instrmem);

        `uvm_info("RV32I_TB",
            $sformatf("Programa carregado de '%s' | instrmem[0]=%h | instrmem[1]=%h",
                    prog_file,
                    dut.u_instruction_memory.instrmem[0],
                    dut.u_instruction_memory.instrmem[1]),
            UVM_LOW)
    end
    // ============================================================
    // Taps hierárquicos para o monitor
    // ============================================================
    assign vif.pc_fetch_mon      = dut.pcF;
    assign vif.instr_fetch_mon   = dut.instrF;

    assign vif.pc_decode_mon     = dut.pcD;
    assign vif.instr_decode_mon  = dut.instrD;

    assign vif.instr_execute_mon = dut.instrE;

    assign vif.pc_memory_mon     = dut.pcplus4M - 32'd4;
    assign vif.instr_memory_mon  =
        dut.u_instruction_memory.instrmem[(dut.pcplus4M - 32'd4) >> 2];

    assign vif.regwrite_w_mon    = dut.regwriteW;
    assign vif.rd_w_mon          = dut.rdW;
    assign vif.result_w_mon      = dut.resultW;

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

    final begin
        display_registers();
        display_mem();
    end

    function void display_registers();
        $display("--------------------------------------------------");
        $display("Resultados finais:");
        $display("x1 = %0d", dut.u_reg_file_n.rf[1]);
        $display("x2 = %0d", dut.u_reg_file_n.rf[2]);
        $display("x3 = %0d", dut.u_reg_file_n.rf[3]);
        $display("x4 = %0d", dut.u_reg_file_n.rf[4]);
        $display("x5 = %0d", dut.u_reg_file_n.rf[5]);
        $display("x6 = %0d", dut.u_reg_file_n.rf[6]);
        $display("x7 = %0d", dut.u_reg_file_n.rf[7]);
        $display("x8 = %0d", dut.u_reg_file_n.rf[8]);
        $display("x9 = %0d", dut.u_reg_file_n.rf[9]);
        $display("x10 = %0d", dut.u_reg_file_n.rf[10]);
        $display("x11 = %0d", dut.u_reg_file_n.rf[11]);
        $display("x12 = %0d", dut.u_reg_file_n.rf[12]);
        $display("x13 = %0d", dut.u_reg_file_n.rf[13]);
        $display("x14 = %0d", dut.u_reg_file_n.rf[14]);
        $display("x15 = %0d", dut.u_reg_file_n.rf[15]);
        $display("x16 = %0d", dut.u_reg_file_n.rf[16]);
        $display("x17 = %0d", dut.u_reg_file_n.rf[17]);
        $display("x18 = %0d", dut.u_reg_file_n.rf[18]);
        $display("x19 = %0d", dut.u_reg_file_n.rf[19]);
        $display("x20 = %0d", dut.u_reg_file_n.rf[20]);
        $display("x21 = %0d", dut.u_reg_file_n.rf[21]);
        $display("x22 = %0d", dut.u_reg_file_n.rf[22]);
        $display("x23 = %0d", dut.u_reg_file_n.rf[23]);
        $display("x24 = %0d", dut.u_reg_file_n.rf[24]);
        $display("x25 = %0d", dut.u_reg_file_n.rf[25]);
        $display("x26 = %0d", dut.u_reg_file_n.rf[26]);
        $display("x27 = %0d", dut.u_reg_file_n.rf[27]);
        $display("x28 = %0d", dut.u_reg_file_n.rf[28]);
        $display("x29 = %0d", dut.u_reg_file_n.rf[29]);
        $display("x30 = %0d", dut.u_reg_file_n.rf[30]);
        $display("x31 = %0d", dut.u_reg_file_n.rf[31]);
        $display("PC final: %h", dut.pc);
        $display("--------------------------------------------------");
    endfunction

    localparam int DATA_MEM_WORDS = $size(dut.u_data_memory.datamem);

    bit touched_mem [0:DATA_MEM_WORDS-1];

    always @(posedge clk) begin
        if (rst_n && dut.writeenableM != 4'b0000) begin
            int idx;
            idx = dut.aluresultM >> 2;

            if (idx >= 0 && idx < DATA_MEM_WORDS) begin
                touched_mem[idx] = 1'b1;
            end
        end
    end

     function void display_mem();
        $display("--------------------------------------------------");
        $display("Celulas de memoria escritas no teste:");
        for (int i = 0; i < DATA_MEM_WORDS; i++) begin
            if (touched_mem[i]) begin
                $display("Mem[%0d] @0x%08h = 0x%08h",
                        i, i*4, dut.u_data_memory.datamem[i]);
            end
        end
        $display("--------------------------------------------------");
    endfunction

endmodule