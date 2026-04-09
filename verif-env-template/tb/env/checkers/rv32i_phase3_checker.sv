`ifndef RV32I_PHASE3_CHECKER_SV
`define RV32I_PHASE3_CHECKER_SV

class rv32i_phase3_checker extends rv32i_phase2_checker;
    `uvm_component_utils(rv32i_phase3_checker)

    // ------------------------------------------------------------
    // Evidências / cobertura da Fase 3
    // ------------------------------------------------------------

    // Loads
    bit saw_lb;
    bit saw_lh;
    bit saw_lw;
    bit saw_lbu;
    bit saw_lhu;

    // Stores
    bit saw_sb;
    bit saw_sh;
    bit saw_sw;

    // Classes de acesso à memória
    bit saw_decode_load;
    bit saw_decode_store;

    // Extensão
    bit saw_signext_byte;
    bit saw_signext_half;
    bit saw_zeroext_byte;
    bit saw_zeroext_half;

    // Offsets
    bit saw_load_zero_offset;
    bit saw_load_positive_offset;
    bit saw_load_negative_offset;

    bit saw_store_zero_offset;
    bit saw_store_positive_offset;
    bit saw_store_negative_offset;

    // Resultados observados em loads
    bit saw_load_zero_result;
    bit saw_load_positive_result;
    bit saw_load_negative_result;

    function new(string name = "rv32i_phase3_checker", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        saw_lb  = 0;
        saw_lh  = 0;
        saw_lw  = 0;
        saw_lbu = 0;
        saw_lhu = 0;

        saw_sb  = 0;
        saw_sh  = 0;
        saw_sw  = 0;

        saw_decode_load  = 0;
        saw_decode_store = 0;

        saw_signext_byte = 0;
        saw_signext_half = 0;
        saw_zeroext_byte = 0;
        saw_zeroext_half = 0;

        saw_load_zero_offset     = 0;
        saw_load_positive_offset = 0;
        saw_load_negative_offset = 0;

        saw_store_zero_offset     = 0;
        saw_store_positive_offset = 0;
        saw_store_negative_offset = 0;

        saw_load_zero_result     = 0;
        saw_load_positive_result = 0;
        saw_load_negative_result = 0;
    endfunction

    function automatic bit [31:0] sext12(input bit [11:0] imm12);
        sext12 = {{20{imm12[11]}}, imm12};
    endfunction

    function automatic bit [31:0] imm_s(input bit [31:0] instr);
        imm_s = sext12({instr[31:25], instr[11:7]});
    endfunction

    function automatic bit [31:0] imm_i(input bit [31:0] instr);
        imm_i = sext12(instr[31:20]);
    endfunction

    // ------------------------------------------------------------
    // Recebe commits do monitor
    // ------------------------------------------------------------
    function void write(rv32i_commit_tr t);
        bit [31:0] off_i;
        bit [31:0] off_s;

        // Reaproveita toda a checagem/evidência das Fases 1 e 2
        super.write(t);

        off_i = imm_i(t.instr);
        off_s = imm_s(t.instr);

        // --------------------------------------------------------
        // Decode / classificação
        // --------------------------------------------------------
        if (is_lb_instr(t.instr)  ||
            is_lh_instr(t.instr)  ||
            is_lw_instr(t.instr)  ||
            is_lbu_instr(t.instr) ||
            is_lhu_instr(t.instr)) begin
            saw_decode_load = 1'b1;
        end

        if (is_sb_instr(t.instr) ||
            is_sh_instr(t.instr) ||
            is_sw_instr(t.instr)) begin
            saw_decode_store = 1'b1;
        end

        // --------------------------------------------------------
        // Evidências de instruções observadas
        // --------------------------------------------------------
        if (is_lb_instr(t.instr))  saw_lb  = 1'b1;
        if (is_lh_instr(t.instr))  saw_lh  = 1'b1;
        if (is_lw_instr(t.instr))  saw_lw  = 1'b1;
        if (is_lbu_instr(t.instr)) saw_lbu = 1'b1;
        if (is_lhu_instr(t.instr)) saw_lhu = 1'b1;

        if (is_sb_instr(t.instr))  saw_sb  = 1'b1;
        if (is_sh_instr(t.instr))  saw_sh  = 1'b1;
        if (is_sw_instr(t.instr))  saw_sw  = 1'b1;

        // --------------------------------------------------------
        // Offsets observados
        // --------------------------------------------------------
        if (is_lb_instr(t.instr)  ||
            is_lh_instr(t.instr)  ||
            is_lw_instr(t.instr)  ||
            is_lbu_instr(t.instr) ||
            is_lhu_instr(t.instr)) begin

            if (off_i == 32'h0000_0000)
                saw_load_zero_offset = 1'b1;
            else if (off_i[31])
                saw_load_negative_offset = 1'b1;
            else
                saw_load_positive_offset = 1'b1;
        end

        if (is_sb_instr(t.instr) ||
            is_sh_instr(t.instr) ||
            is_sw_instr(t.instr)) begin

            if (off_s == 32'h0000_0000)
                saw_store_zero_offset = 1'b1;
            else if (off_s[31])
                saw_store_negative_offset = 1'b1;
            else
                saw_store_positive_offset = 1'b1;
        end

        // --------------------------------------------------------
        // Resultados de loads
        // --------------------------------------------------------
        if (is_lb_instr(t.instr)  ||
            is_lh_instr(t.instr)  ||
            is_lw_instr(t.instr)  ||
            is_lbu_instr(t.instr) ||
            is_lhu_instr(t.instr)) begin

            if (t.rd_data == 32'h0000_0000)
                saw_load_zero_result = 1'b1;
            else if (t.rd_data[31])
                saw_load_negative_result = 1'b1;
            else
                saw_load_positive_result = 1'b1;
        end

        // --------------------------------------------------------
        // Evidências indiretas de sign/zero extension
        // --------------------------------------------------------
        // LB: se o resultado ficou negativo, houve sign extension
        if (is_lb_instr(t.instr) && t.rd_data[31])
            saw_signext_byte = 1'b1;

        // LH: se o resultado ficou negativo, houve sign extension
        if (is_lh_instr(t.instr) && t.rd_data[31])
            saw_signext_half = 1'b1;

        // LBU: extensão por zero sempre gera bits [31:8] zerados
        if (is_lbu_instr(t.instr) && (t.rd_data[31:8] == 24'h000000))
            saw_zeroext_byte = 1'b1;

        // LHU: extensão por zero sempre gera bits [31:16] zerados
        if (is_lhu_instr(t.instr) && (t.rd_data[31:16] == 16'h0000))
            saw_zeroext_half = 1'b1;
    endfunction

    // ------------------------------------------------------------
    // Relatório da Fase 3
    // ------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("RV32I_P3_REPORT",
            $sformatf(
                "Phase3 summary: lb=%0d lh=%0d lw=%0d lbu=%0d lhu=%0d sb=%0d sh=%0d sw=%0d dec_load=%0d dec_store=%0d signext_b=%0d signext_h=%0d zeroext_b=%0d zeroext_h=%0d load_off_0=%0d load_off_pos=%0d load_off_neg=%0d store_off_0=%0d store_off_pos=%0d store_off_neg=%0d load_res_zero=%0d load_res_pos=%0d load_res_neg=%0d",
                saw_lb, saw_lh, saw_lw, saw_lbu, saw_lhu,
                saw_sb, saw_sh, saw_sw,
                saw_decode_load, saw_decode_store,
                saw_signext_byte, saw_signext_half,
                saw_zeroext_byte, saw_zeroext_half,
                saw_load_zero_offset, saw_load_positive_offset, saw_load_negative_offset,
                saw_store_zero_offset, saw_store_positive_offset, saw_store_negative_offset,
                saw_load_zero_result, saw_load_positive_result, saw_load_negative_result
            ),
            UVM_NONE
        );

        if (!saw_lb ) `uvm_warning("RV32I_P3_REPORT", "Nenhuma instrucao LB foi observada")
        if (!saw_lh ) `uvm_warning("RV32I_P3_REPORT", "Nenhuma instrucao LH foi observada")
        if (!saw_lw ) `uvm_warning("RV32I_P3_REPORT", "Nenhuma instrucao LW foi observada")
        if (!saw_lbu) `uvm_warning("RV32I_P3_REPORT", "Nenhuma instrucao LBU foi observada")
        if (!saw_lhu) `uvm_warning("RV32I_P3_REPORT", "Nenhuma instrucao LHU foi observada")

        if (!saw_sb ) `uvm_warning("RV32I_P3_REPORT", "Nenhuma instrucao SB foi observada")
        if (!saw_sh ) `uvm_warning("RV32I_P3_REPORT", "Nenhuma instrucao SH foi observada")
        if (!saw_sw ) `uvm_warning("RV32I_P3_REPORT", "Nenhuma instrucao SW foi observada")

        if (!saw_signext_byte)
            `uvm_warning("RV32I_P3_REPORT", "Nenhuma evidencia de sign extension em byte foi observada")

        if (!saw_signext_half)
            `uvm_warning("RV32I_P3_REPORT", "Nenhuma evidencia de sign extension em halfword foi observada")

        if (!saw_zeroext_byte)
            `uvm_warning("RV32I_P3_REPORT", "Nenhuma evidencia de zero extension em byte foi observada")

        if (!saw_zeroext_half)
            `uvm_warning("RV32I_P3_REPORT", "Nenhuma evidencia de zero extension em halfword foi observada")
    endfunction

endclass

`endif