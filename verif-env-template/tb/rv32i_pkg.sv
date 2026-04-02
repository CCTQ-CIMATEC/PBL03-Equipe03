package rv32i_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "env/agents/rv32i_agent/rv32i_commit_tr.sv"
    `include "env/agents/rv32i_agent/rv32i_monitor.sv"
    `include "env/top/rv32i_scoreboard.sv"
    `include "env/ref_model/rv32i_ref_model.sv"
    `include "env/top/rv32i_env.sv"
    `include "tests/rv32i_base_test.sv"

endpackage