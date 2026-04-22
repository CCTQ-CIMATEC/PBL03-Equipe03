`ifndef RV32I_ENV_SV
`define RV32I_ENV_SV

class rv32i_env extends uvm_env;
    `uvm_component_utils(rv32i_env)

    // ------------------------------------------------------------
    // Componentes do ambiente
    // ------------------------------------------------------------
    rv32i_monitor    monitor;
    rv32i_ref_model  ref_model;
    rv32i_scoreboard scoreboard;
    rv32i_checker_base checker_h;

    // ------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------
    function new(string name = "rv32i_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // ------------------------------------------------------------
    // Build phase
    // ------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        monitor    = rv32i_monitor   ::type_id::create("monitor", this);
        ref_model  = rv32i_ref_model ::type_id::create("ref_model", this);
        scoreboard = rv32i_scoreboard::type_id::create("scoreboard", this);
        checker_h  = rv32i_checker_base::type_id::create("checker", this);
    endfunction

    // ------------------------------------------------------------
    // Connect phase
    // ------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Monitor -> observado no DUT
        monitor.commit_ap.connect(scoreboard.obs_fifo.analysis_export);

        // Reference model -> esperado
        ref_model.exp_ap.connect(scoreboard.exp_fifo.analysis_export);

        // Checker recebe o canal expandido
        monitor.checker_ap.connect(checker_h.analysis_export);
    endfunction

    // ------------------------------------------------------------
    // End of elaboration
    // ------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        `uvm_info("RV32I_ENV",
            "Ambiente rv32i construido e conectado com sucesso.",
            UVM_LOW)
    endfunction

endclass

`endif