package rv32i_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // transações
    `include "env/agents/rv32i_agent/rv32i_commit_tr.sv"

    // monitor / ref model / scoreboard
    `include "env/agents/rv32i_agent/rv32i_monitor.sv"
    `include "env/ref_model/rv32i_ref_model.sv"
    `include "env/top/rv32i_scoreboard.sv"

    // checkers
    `include "env/checkers/rv32i_checker_base.sv"
    `include "env/checkers/rv32i_phase1_checker.sv"

    // env
    `include "env/top/rv32i_env.sv"

    // tests
    `include "tests/rv32i_base_test.sv"
    `include "tests/rv32i_phase1_test.sv"
endpackage