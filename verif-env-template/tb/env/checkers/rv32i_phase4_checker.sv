`ifndef RV32I_PHASE4_CHECKER_SV
`define RV32I_PHASE4_CHECKER_SV

class rv32i_phase4_checker extends rv32i_phase3_checker;
    `uvm_component_utils(rv32i_phase4_checker)

    // ------------------------------------------------------------
    // Evidências / cobertura da Fase 4
    // ------------------------------------------------------------
    bit saw_beq;
    bit saw_bne;
    bit saw_blt;
    bit saw_bge;
    bit saw_bltu;
    bit saw_bgeu;

    bit saw_jal;
    bit saw_jalr;

    bit saw_branch_taken;
    bit saw_branch_not_taken;

    bit saw_branch_positive_offset;
    bit saw_branch_negative_offset;

    bit saw_jump_positive_offset;
    bit saw_jump_negative_offset;

    bit saw_link_write;
    bit saw_link_x0;

    bit saw_signed_branch;
    bit saw_unsigned_branch;

    bit pending_ctrl;
    bit pending_branch;
    bit [31:0] pending_pc;
    bit [31:0] pending_instr;

    function new(string name = "rv32i_phase4_checker", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        saw_beq  = 0;
        saw_bne  = 0;
        saw_blt  = 0;
        saw_bge  = 0;
        saw_bltu = 0;
        saw_bgeu = 0;

        saw_jal  = 0;
        saw_jalr = 0;

        saw_branch_taken     = 0;
        saw_branch_not_taken = 0;

        saw_branch_positive_offset = 0;
        saw_branch_negative_offset = 0;

        saw_jump_positive_offset = 0;
        saw_jump_negative_offset = 0;

        saw_link_write = 0;
        saw_link_x0    = 0;

        saw_signed_branch   = 0;
        saw_unsigned_branch = 0;

        pending_ctrl   = 0;
        pending_branch = 0;
        pending_pc     = 32'h0000_0000;
        pending_instr  = 32'h0000_0000;
    endfunction

    function automatic bit [31:0] sext13(input bit [12:0] imm13);
        sext13 = {{19{imm13[12]}}, imm13};
    endfunction

    function automatic bit [31:0] sext21(input bit [20:0] imm21);
        sext21 = {{11{imm21[20]}}, imm21};
    endfunction

    function automatic bit [31:0] imm_b(input bit [31:0] instr);
        imm_b = sext13({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0});
    endfunction

    function automatic bit [31:0] imm_j(input bit [31:0] instr);
        imm_j = sext21({instr[31], instr[19:12], instr[20], instr[30:21], 1'b0});
    endfunction

    function automatic bit [31:0] imm_i(input bit [31:0] instr);
        imm_i = sext12(instr[31:20]);
    endfunction

    // ------------------------------------------------------------
    // Recebe commits do monitor
    // ------------------------------------------------------------
    function void write(rv32i_commit_tr t);
        bit cur_is_branch;
        bit cur_is_jump;
        bit [31:0] off_b;
        bit [31:0] off_j;
        bit [31:0] off_i;

        // Reaproveita toda a checagem/evidência das fases anteriores
        super.write(t);

        // Resolve evidência pendente do evento de controle anterior
        if (pending_ctrl) begin
            if (pending_branch) begin
                if (t.pc == (pending_pc + 32'd4))
                    saw_branch_not_taken = 1'b1;
                else
                    saw_branch_taken = 1'b1;
            end

            pending_ctrl   = 1'b0;
            pending_branch = 1'b0;
        end

        cur_is_branch = is_beq_instr(t.instr)  ||
                        is_bne_instr(t.instr)  ||
                        is_blt_instr(t.instr)  ||
                        is_bge_instr(t.instr)  ||
                        is_bltu_instr(t.instr) ||
                        is_bgeu_instr(t.instr);

        cur_is_jump = is_jal_instr(t.instr) || is_jalr_instr(t.instr);

        off_b = imm_b(t.instr);
        off_j = imm_j(t.instr);
        off_i = imm_i(t.instr);

        // --------------------------------------------------------
        // Evidências das instruções observadas
        // --------------------------------------------------------
        if (is_beq_instr (t.instr)) saw_beq  = 1'b1;
        if (is_bne_instr (t.instr)) saw_bne  = 1'b1;
        if (is_blt_instr (t.instr)) saw_blt  = 1'b1;
        if (is_bge_instr (t.instr)) saw_bge  = 1'b1;
        if (is_bltu_instr(t.instr)) saw_bltu = 1'b1;
        if (is_bgeu_instr(t.instr)) saw_bgeu = 1'b1;

        if (is_jal_instr (t.instr)) saw_jal  = 1'b1;
        if (is_jalr_instr(t.instr)) saw_jalr = 1'b1;

        // --------------------------------------------------------
        // Classificação de branches
        // --------------------------------------------------------
        if (cur_is_branch) begin
            if (off_b[31])
                saw_branch_negative_offset = 1'b1;
            else if (off_b != 32'h0000_0000)
                saw_branch_positive_offset = 1'b1;

            if (is_bltu_instr(t.instr) || is_bgeu_instr(t.instr))
                saw_unsigned_branch = 1'b1;
            else
                saw_signed_branch = 1'b1;

            pending_ctrl   = 1'b1;
            pending_branch = 1'b1;
            pending_pc     = t.pc;
            pending_instr  = t.instr;
        end

        // --------------------------------------------------------
        // Classificação de jumps
        // --------------------------------------------------------
        if (is_jal_instr(t.instr)) begin
            if (off_j[31])
                saw_jump_negative_offset = 1'b1;
            else if (off_j != 32'h0000_0000)
                saw_jump_positive_offset = 1'b1;

            if (t.rd_addr == 5'd0)
                saw_link_x0 = 1'b1;
            else
                saw_link_write = 1'b1;

            pending_ctrl   = 1'b1;
            pending_branch = 1'b0;
            pending_pc     = t.pc;
            pending_instr  = t.instr;
        end

        if (is_jalr_instr(t.instr)) begin
            if (off_i[31])
                saw_jump_negative_offset = 1'b1;
            else if (off_i != 32'h0000_0000)
                saw_jump_positive_offset = 1'b1;

            if (t.rd_addr == 5'd0)
                saw_link_x0 = 1'b1;
            else
                saw_link_write = 1'b1;

            pending_ctrl   = 1'b1;
            pending_branch = 1'b0;
            pending_pc     = t.pc;
            pending_instr  = t.instr;
        end
    endfunction

    // ------------------------------------------------------------
    // Relatório da Fase 4
    // ------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("RV32I_P4_REPORT",
            $sformatf(
                "Phase4 summary: beq=%0d bne=%0d blt=%0d bge=%0d bltu=%0d bgeu=%0d jal=%0d jalr=%0d br_taken=%0d br_not_taken=%0d br_off_pos=%0d br_off_neg=%0d jmp_off_pos=%0d jmp_off_neg=%0d link_write=%0d link_x0=%0d signed_br=%0d unsigned_br=%0d",
                saw_beq, saw_bne, saw_blt, saw_bge, saw_bltu, saw_bgeu,
                saw_jal, saw_jalr,
                saw_branch_taken, saw_branch_not_taken,
                saw_branch_positive_offset, saw_branch_negative_offset,
                saw_jump_positive_offset, saw_jump_negative_offset,
                saw_link_write, saw_link_x0,
                saw_signed_branch, saw_unsigned_branch
            ),
            UVM_NONE
        );

        if (!saw_beq ) `uvm_warning("RV32I_P4_REPORT", "Nenhuma instrucao BEQ foi observada")
        if (!saw_bne ) `uvm_warning("RV32I_P4_REPORT", "Nenhuma instrucao BNE foi observada")
        if (!saw_blt ) `uvm_warning("RV32I_P4_REPORT", "Nenhuma instrucao BLT foi observada")
        if (!saw_bge ) `uvm_warning("RV32I_P4_REPORT", "Nenhuma instrucao BGE foi observada")
        if (!saw_bltu) `uvm_warning("RV32I_P4_REPORT", "Nenhuma instrucao BLTU foi observada")
        if (!saw_bgeu) `uvm_warning("RV32I_P4_REPORT", "Nenhuma instrucao BGEU foi observada")

        if (!saw_jal ) `uvm_warning("RV32I_P4_REPORT", "Nenhuma instrucao JAL foi observada")
        if (!saw_jalr) `uvm_warning("RV32I_P4_REPORT", "Nenhuma instrucao JALR foi observada")

        if (!saw_branch_taken)
            `uvm_warning("RV32I_P4_REPORT", "Nenhuma evidencia de branch taken foi observada")

        if (!saw_branch_not_taken)
            `uvm_warning("RV32I_P4_REPORT", "Nenhuma evidencia de branch not taken foi observada")

        if (!saw_branch_positive_offset)
            `uvm_warning("RV32I_P4_REPORT", "Nenhuma evidencia de branch com offset positivo foi observada")

        if (!saw_branch_negative_offset)
            `uvm_warning("RV32I_P4_REPORT", "Nenhuma evidencia de branch com offset negativo foi observada")

        if (!saw_jump_positive_offset)
            `uvm_warning("RV32I_P4_REPORT", "Nenhuma evidencia de jump com offset positivo foi observada")

        if (!saw_jump_negative_offset)
            `uvm_warning("RV32I_P4_REPORT", "Nenhuma evidencia de jump com offset negativo foi observada")

        if (!saw_link_write)
            `uvm_warning("RV32I_P4_REPORT", "Nenhuma evidencia de escrita em link register foi observada")

        if (!saw_link_x0)
            `uvm_warning("RV32I_P4_REPORT", "Nenhuma evidencia de jump com rd=x0 foi observada")
    endfunction

endclass

`endif
