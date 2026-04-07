`ifndef RV32I_PHASE1_TEST_SV
`define RV32I_PHASE1_TEST_SV

import rv32i_tb_cfg_pkg::*;

class rv32i_phase1_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_phase1_test)

    function new(string name = "rv32i_phase1_test", uvm_component parent = null);
        super.new(name, parent);

        // Defaults da Fase 1
        prog_file = RV32I_PHASE1_PROG_FILE;
        max_instr = RV32I_DEFAULT_MAX_INSTR;
        start_pc  = RV32I_DEFAULT_START_PC;
    endfunction

    function void build_phase(uvm_phase phase);

        // --------------------------------------------------------
        // Override do checker genérico pelo checker da Fase 1
        // IMPORTANTE: fazer isso antes do super.build_phase(),
        // porque o env será criado no build do base_test.
        // --------------------------------------------------------
        rv32i_checker_base::type_id::set_type_override(
            rv32i_phase1_checker::get_type()
        );

        `uvm_info("RV32I_P1_TEST",
            "Checker sobrescrito",
            UVM_LOW)

        super.build_phase(phase);
    endfunction

endclass

`endif