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

    /***************************
     PHASE 1 FUNCTIONS CHECKERS
    ****************************/
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

    /***************************
     PHASE 2 FUNCTIONS CHECKERS
    ****************************/
    function bit is_andi_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0010011) &&
               (instr[14:12] == 3'b111);
    endfunction

    function bit is_ori_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0010011) &&
               (instr[14:12] == 3'b110);
    endfunction

    function bit is_xori_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0010011) &&
               (instr[14:12] == 3'b100);
    endfunction

    function bit is_slli_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0010011) &&
               (instr[14:12] == 3'b001)     &&
               (instr[31:25] == 7'b0000000);
    endfunction

    function bit is_srli_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0010011) &&
               (instr[14:12] == 3'b101)     &&
               (instr[31:25] == 7'b0000000);
    endfunction

    function bit is_srai_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0010011) &&
               (instr[14:12] == 3'b101)     &&
               (instr[31:25] == 7'b0100000);
    endfunction

    function bit is_and_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0110011) &&
               (instr[14:12] == 3'b111)     &&
               (instr[31:25] == 7'b0000000);
    endfunction

    function bit is_or_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0110011) &&
               (instr[14:12] == 3'b110)     &&
               (instr[31:25] == 7'b0000000);
    endfunction

    function bit is_xor_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0110011) &&
               (instr[14:12] == 3'b100)     &&
               (instr[31:25] == 7'b0000000);
    endfunction

    function bit is_sll_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0110011) &&
               (instr[14:12] == 3'b001)     &&
               (instr[31:25] == 7'b0000000);
    endfunction

    function bit is_srl_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0110011) &&
               (instr[14:12] == 3'b101)     &&
               (instr[31:25] == 7'b0000000);
    endfunction

    function bit is_sra_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0110011) &&
               (instr[14:12] == 3'b101)     &&
               (instr[31:25] == 7'b0100000);
    endfunction

    /***************************
     PHASE 3 FUNCTIONS CHECKERS
    ****************************/
    function bit is_lb_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0000011) &&
               (instr[14:12] == 3'b000);
    endfunction

    function bit is_lh_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0000011) &&
               (instr[14:12] == 3'b001);
    endfunction

    function bit is_lw_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0000011) &&
               (instr[14:12] == 3'b010);
    endfunction

    function bit is_lbu_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0000011) &&
               (instr[14:12] == 3'b100);
    endfunction

    function bit is_lhu_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0000011) &&
               (instr[14:12] == 3'b101);
    endfunction

    function bit is_sb_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0100011) &&
               (instr[14:12] == 3'b000);
    endfunction

    function bit is_sh_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0100011) &&
               (instr[14:12] == 3'b001);
    endfunction

    function bit is_sw_instr(bit [31:0] instr);
        return (instr[6:0]   == 7'b0100011) &&
               (instr[14:12] == 3'b010);
    endfunction

endclass

`endif