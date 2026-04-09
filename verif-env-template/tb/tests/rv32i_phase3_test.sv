`ifndef RV32I_PHASE3_TEST_SV
`define RV32I_PHASE3_TEST_SV

import rv32i_tb_cfg_pkg::*;

class rv32i_phase3_test extends rv32i_base_test;
    `uvm_component_utils(rv32i_phase3_test)

    function new(string name = "rv32i_phase3_test", uvm_component parent = null);
        super.new(name, parent);

        // Defaults da Fase 3
        prog_file = RV32I_PHASE3_PROG_FILE;
        max_instr = RV32I_DEFAULT_MAX_INSTR;
        start_pc  = RV32I_DEFAULT_START_PC;
    endfunction

    function void build_phase(uvm_phase phase);

        // Override do checker genérico pelo checker da Fase 3
        // Deve acontecer antes do super.build_phase(),
        // pois o env é criado no base_test.
        rv32i_checker_base::type_id::set_type_override(
            rv32i_phase3_checker::get_type()
        );

        `uvm_info("RV32I_P3_TEST",
            "Checker sobrescrito para rv32i_phase3_checker",
            UVM_LOW)

        super.build_phase(phase);
    endfunction

endclass

`endif