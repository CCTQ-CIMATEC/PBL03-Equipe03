`ifndef RV32I_CHECKER_BASE_SV
`define RV32I_CHECKER_BASE_SV

class rv32i_checker_base extends uvm_subscriber #(rv32i_commit_tr);
    `uvm_component_utils(rv32i_checker_base)

    virtual rv32i_if vif;
    bit [31:0] start_pc;

    function new(string name = "rv32i_checker_base", uvm_component parent = null);
        super.new(name, parent);
        start_pc = '0;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual rv32i_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF",
                $sformatf("%s: virtual interface rv32i_if nao encontrada",
                          get_full_name()))
        end

        if (!uvm_config_db#(bit [31:0])::get(this, "", "start_pc", start_pc)) begin
            start_pc = '0;
        end
    endfunction

    // Implementação padrão: checker "nulo"
    // Subclasses sobrescrevem isso.
    virtual function void write(rv32i_commit_tr t);
    endfunction

    function bit is_addi_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0010011) &&
               (instr[14:12] == 3'b000);
    endfunction

    function bit is_add_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0110011) &&
               (instr[14:12] == 3'b000)     &&
               (instr[31:25] == 7'b0000000);
    endfunction

    function bit is_sub_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0110011) &&
               (instr[14:12] == 3'b000)     &&
               (instr[31:25] == 7'b0100000);
    endfunction

endclass

`endif