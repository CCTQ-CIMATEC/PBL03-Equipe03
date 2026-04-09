`ifndef RV32I_IF_SV
`define RV32I_IF_SV

interface rv32i_if (
    input logic clk,
    input logic rst_n
);

    // ============================================================
    // Monitoramento básico do pipeline
    // ============================================================
    logic [31:0] pc_fetch_mon;
    logic [31:0] instr_fetch_mon;

    logic [31:0] pc_decode_mon;
    logic [31:0] instr_decode_mon;

    logic [31:0] instr_execute_mon;

    // ============================================================
    // Monitoramento do estágio M
    // ============================================================
    logic [31:0] pc_memory_mon;
    logic [31:0] instr_memory_mon;

    logic [31:0] instr_commit_mon;

    // ============================================================
    // Monitoramento de writeback / commit aproximado
    // ============================================================
    logic        regwrite_w_mon;
    logic [4:0]  rd_w_mon;
    logic [31:0] result_w_mon;
    logic [31:0] pc_commit_mon;

    // ============================================================
    // Monitoramento do register file
    // ============================================================
    logic [31:0] x0_value_mon;

    // ============================================================
    // Monitoramento de hazards
    // ============================================================
    logic        stallF_mon;
    logic        stallD_mon;
    logic        flushE_mon;

    // ============================================================
    // Monitoramento de memória
    // ============================================================
    logic [31:0] alu_result_m_mon;
    logic [31:0] write_data_m_mon;
    logic [3:0]  write_enable_m_mon;

    // ============================================================
    // Clocking block do monitor
    // ============================================================
    clocking mon_cb @(posedge clk);
        default input #1step output #1step;

        input rst_n;

        input pc_fetch_mon;
        input instr_fetch_mon;

        input pc_decode_mon;
        input instr_decode_mon;

        input instr_execute_mon;

        input pc_memory_mon;
        input instr_memory_mon;

        input instr_commit_mon;

        input regwrite_w_mon;
        input rd_w_mon;
        input result_w_mon;
        input pc_commit_mon;

        input x0_value_mon;

        input stallF_mon;
        input stallD_mon;
        input flushE_mon;

        input alu_result_m_mon;
        input write_data_m_mon;
        input write_enable_m_mon;
    endclocking

    modport mon_mp (clocking mon_cb, input clk, input rst_n);

endinterface

`endif