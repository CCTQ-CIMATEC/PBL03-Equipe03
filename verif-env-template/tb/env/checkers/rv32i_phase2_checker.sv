`ifndef RV32I_PHASE2_CHECKER_SV
`define RV32I_PHASE2_CHECKER_SV

class rv32i_phase2_checker extends rv32i_phase1_checker;
    `uvm_component_utils(rv32i_phase2_checker)

    // ------------------------------------------------------------
    // Evidências / cobertura da Fase 2
    // ------------------------------------------------------------

    // Lógicas I-type
    bit saw_andi;
    bit saw_ori;
    bit saw_xori;

    // Comparações I-type
    bit saw_slti;
    bit saw_sltiu;

    // Lógicas R-type
    bit saw_and;
    bit saw_or;
    bit saw_xor;

    // Comparações R-type
    bit saw_slt;
    bit saw_sltu;

    // Shifts I-type
    bit saw_slli;
    bit saw_srli;
    bit saw_srai;

    // Shifts R-type
    bit saw_sll;
    bit saw_srl;
    bit saw_sra;

    // U-type
    bit saw_lui;
    bit saw_auipc;

    // Immediate generation
    bit saw_imm_zero;
    bit saw_imm_positive;
    bit saw_imm_negative;

    // Shift amount
    bit saw_shamt_zero;
    bit saw_shamt_nonzero;
    bit saw_shamt_large;

    // Decode por classe
    bit saw_decode_logic_itype;
    bit saw_decode_logic_rtype;
    bit saw_decode_shift_itype;
    bit saw_decode_shift_rtype;
    bit saw_decode_compare_itype;
    bit saw_decode_compare_rtype;
    bit saw_decode_utype;

    function new(string name = "rv32i_phase2_checker", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        saw_andi = 0;
        saw_ori  = 0;
        saw_xori = 0;

        saw_slti  = 0;
        saw_sltiu = 0;

        saw_and  = 0;
        saw_or   = 0;
        saw_xor  = 0;

        saw_slt  = 0;
        saw_sltu = 0;

        saw_slli = 0;
        saw_srli = 0;
        saw_srai = 0;

        saw_sll  = 0;
        saw_srl  = 0;
        saw_sra  = 0;

        saw_lui   = 0;
        saw_auipc = 0;

        saw_imm_zero     = 0;
        saw_imm_positive = 0;
        saw_imm_negative = 0;

        saw_shamt_zero    = 0;
        saw_shamt_nonzero = 0;
        saw_shamt_large   = 0;

        saw_decode_logic_itype   = 0;
        saw_decode_logic_rtype   = 0;
        saw_decode_shift_itype   = 0;
        saw_decode_shift_rtype   = 0;
        saw_decode_compare_itype = 0;
        saw_decode_compare_rtype = 0;
        saw_decode_utype         = 0;
    endfunction

    function automatic bit [31:0] sext12(input bit [11:0] imm12);
        sext12 = {{20{imm12[11]}}, imm12};
    endfunction

    function automatic bit [4:0] shamt_i(input bit [31:0] instr);
        shamt_i = instr[24:20];
    endfunction

    // ------------------------------------------------------------
    // Recebe commits do monitor
    // ------------------------------------------------------------
    function void write(rv32i_commit_tr t);
        bit [31:0] imm_i;
        bit [4:0]  shamt;

        // Reaproveita toda a checagem/evidência da Fase 1
        super.write(t);

        imm_i = sext12(t.instr[31:20]);
        shamt = shamt_i(t.instr);

        // --------------------------------------------------------
        // Immediate generation (indireto, pela instrução observada)
        // --------------------------------------------------------
        if (is_andi_instr(t.instr)  || is_ori_instr(t.instr)   || is_xori_instr(t.instr) ||
            is_slti_instr(t.instr)  || is_sltiu_instr(t.instr)) begin
            if (imm_i == 32'h0000_0000)
                saw_imm_zero = 1'b1;
            else if (imm_i[31])
                saw_imm_negative = 1'b1;
            else
                saw_imm_positive = 1'b1;
        end

        // --------------------------------------------------------
        // Shift amount
        // --------------------------------------------------------
        if (is_slli_instr(t.instr) || is_srli_instr(t.instr) || is_srai_instr(t.instr)) begin
            if (shamt == 5'd0)
                saw_shamt_zero = 1'b1;
            else
                saw_shamt_nonzero = 1'b1;

            if (shamt >= 5'd16)
                saw_shamt_large = 1'b1;
        end

        // --------------------------------------------------------
        // Decode / classificação por encoding
        // --------------------------------------------------------
        if (is_andi_instr(t.instr) || is_ori_instr(t.instr) || is_xori_instr(t.instr)) begin
            saw_decode_logic_itype = 1'b1;
        end

        if (is_and_instr(t.instr) || is_or_instr(t.instr) || is_xor_instr(t.instr)) begin
            saw_decode_logic_rtype = 1'b1;
        end

        if (is_slli_instr(t.instr) || is_srli_instr(t.instr) || is_srai_instr(t.instr)) begin
            saw_decode_shift_itype = 1'b1;
        end

        if (is_sll_instr(t.instr) || is_srl_instr(t.instr) || is_sra_instr(t.instr)) begin
            saw_decode_shift_rtype = 1'b1;
        end

        if (is_slti_instr(t.instr) || is_sltiu_instr(t.instr)) begin
            saw_decode_compare_itype = 1'b1;
        end

        if (is_slt_instr(t.instr) || is_sltu_instr(t.instr)) begin
            saw_decode_compare_rtype = 1'b1;
        end

        if (is_lui_instr(t.instr) || is_auipc_instr(t.instr)) begin
            saw_decode_utype = 1'b1;
        end

        // --------------------------------------------------------
        // Evidências das instruções observadas
        // --------------------------------------------------------
        if (is_andi_instr (t.instr)) saw_andi  = 1'b1;
        if (is_ori_instr  (t.instr)) saw_ori   = 1'b1;
        if (is_xori_instr (t.instr)) saw_xori  = 1'b1;

        if (is_slti_instr (t.instr)) saw_slti  = 1'b1;
        if (is_sltiu_instr(t.instr)) saw_sltiu = 1'b1;

        if (is_and_instr(t.instr))   saw_and   = 1'b1;
        if (is_or_instr (t.instr))   saw_or    = 1'b1;
        if (is_xor_instr(t.instr))   saw_xor   = 1'b1;

        if (is_slt_instr (t.instr))  saw_slt   = 1'b1;
        if (is_sltu_instr(t.instr))  saw_sltu  = 1'b1;

        if (is_slli_instr(t.instr))  saw_slli  = 1'b1;
        if (is_srli_instr(t.instr))  saw_srli  = 1'b1;
        if (is_srai_instr(t.instr))  saw_srai  = 1'b1;

        if (is_sll_instr(t.instr))   saw_sll   = 1'b1;
        if (is_srl_instr(t.instr))   saw_srl   = 1'b1;
        if (is_sra_instr(t.instr))   saw_sra   = 1'b1;

        if (is_lui_instr  (t.instr)) saw_lui   = 1'b1;
        if (is_auipc_instr(t.instr)) saw_auipc = 1'b1;
    endfunction

    // ------------------------------------------------------------
    // Relatório da Fase 2
    // ------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("RV32I_P2_REPORT",
            $sformatf(
                "Phase2 summary: andi=%0d ori=%0d xori=%0d slti=%0d sltiu=%0d and=%0d or=%0d xor=%0d slt=%0d sltu=%0d slli=%0d srli=%0d srai=%0d sll=%0d srl=%0d sra=%0d lui=%0d auipc=%0d imm_zero=%0d imm_pos=%0d imm_neg=%0d shamt_zero=%0d shamt_nonzero=%0d shamt_large=%0d dec_logic_i=%0d dec_logic_r=%0d dec_shift_i=%0d dec_shift_r=%0d dec_cmp_i=%0d dec_cmp_r=%0d dec_utype=%0d",
                saw_andi, saw_ori, saw_xori, saw_slti, saw_sltiu,
                saw_and, saw_or, saw_xor, saw_slt, saw_sltu,
                saw_slli, saw_srli, saw_srai,
                saw_sll, saw_srl, saw_sra,
                saw_lui, saw_auipc,
                saw_imm_zero, saw_imm_positive, saw_imm_negative,
                saw_shamt_zero, saw_shamt_nonzero, saw_shamt_large,
                saw_decode_logic_itype, saw_decode_logic_rtype,
                saw_decode_shift_itype, saw_decode_shift_rtype,
                saw_decode_compare_itype, saw_decode_compare_rtype,
                saw_decode_utype
            ),
            UVM_NONE
        );

        if (!saw_andi ) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao ANDI foi observada")
        if (!saw_ori  ) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao ORI foi observada")
        if (!saw_xori ) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao XORI foi observada")
        if (!saw_slti ) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao SLTI foi observada")
        if (!saw_sltiu) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao SLTIU foi observada")

        if (!saw_and  ) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao AND foi observada")
        if (!saw_or   ) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao OR foi observada")
        if (!saw_xor  ) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao XOR foi observada")
        if (!saw_slt  ) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao SLT foi observada")
        if (!saw_sltu ) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao SLTU foi observada")

        if (!saw_slli ) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao SLLI foi observada")
        if (!saw_srli ) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao SRLI foi observada")
        if (!saw_srai ) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao SRAI foi observada")

        if (!saw_sll  ) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao SLL foi observada")
        if (!saw_srl  ) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao SRL foi observada")
        if (!saw_sra  ) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao SRA foi observada")

        if (!saw_lui  ) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao LUI foi observada")
        if (!saw_auipc) `uvm_warning("RV32I_P2_REPORT", "Nenhuma instrucao AUIPC foi observada")
    endfunction

endclass

`endif