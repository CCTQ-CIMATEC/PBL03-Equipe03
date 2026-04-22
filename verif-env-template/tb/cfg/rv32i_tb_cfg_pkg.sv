`ifndef RV32I_TB_CFG_PKG
`define RV32I_TB_CFG_PKG

package rv32i_tb_cfg_pkg;

    // default parameters
    localparam string RV32I_DEFAULT_PROG_FILE = "../tb/sanity/test_prog_phase1.mem";
    localparam int unsigned RV32I_DEFAULT_MAX_INSTR = 12;
    localparam bit [31:0] RV32I_DEFAULT_START_PC = 32'h0000_0000;

    // phase 1 parameters
    localparam string RV32I_PHASE1_PROG_FILE = "../tb/programs/phase1/mem/phase1_full.mem";

    // phase 2 parameters
    localparam string RV32I_PHASE2_PROG_FILE = "../tb/programs/phase2/mem/phase2_full.mem";

    // phase 3 parameters
    localparam string RV32I_PHASE3_PROG_FILE = "../tb/programs/phase3/mem/phase3_full.mem";

    // phase 4 parameters
    localparam string RV32I_PHASE4_PROG_FILE = "../tb/programs/phase4/mem/phase4_full.mem";

    // phase 5 parameters
    localparam string RV32I_PHASE5_PROG_FILE = "../tb/programs/phase5/mem/phase5_full.mem";
    
endpackage

`endif