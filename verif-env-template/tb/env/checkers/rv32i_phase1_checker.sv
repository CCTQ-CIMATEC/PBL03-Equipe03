`ifndef RV32I_PHASE1_CHECKER_SV
`define RV32I_PHASE1_CHECKER_SV

class rv32i_phase1_checker extends rv32i_checker_base;
    `uvm_component_utils(rv32i_phase1_checker)

    // ------------------------------------------------------------
    // Flags de evidência / cobertura da Fase 1
    // ------------------------------------------------------------
    bit saw_reset_release;
    bit saw_reset_x0_ok;

    bit saw_first_commit;
    bit saw_pc_initial_commit;
    bit saw_pc_seq_step;

    bit saw_regwrite_nonzero_rd;

    bit saw_addi;
    bit saw_addi_negative;
    bit saw_add;
    bit saw_sub;

    bit saw_x0_attempt;
    bit saw_x0_addi_attempt;
    bit saw_x0_rtype_attempt;

    bit saw_positive_result;
    bit saw_zero_result;
    bit saw_negative_result;

    bit all_x0_observed_zero;

    bit        prev_pc_valid;
    bit [31:0] prev_pc;

    int unsigned num_errors;

    function new(string name = "rv32i_phase1_checker", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        saw_reset_release       = 0;
        saw_reset_x0_ok         = 0;

        saw_first_commit        = 0;
        saw_pc_initial_commit   = 0;
        saw_pc_seq_step         = 0;

        saw_regwrite_nonzero_rd = 0;

        saw_addi                = 0;
        saw_addi_negative       = 0;
        saw_add                 = 0;
        saw_sub                 = 0;

        saw_x0_attempt          = 0;
        saw_x0_addi_attempt     = 0;
        saw_x0_rtype_attempt    = 0;

        saw_positive_result     = 0;
        saw_zero_result         = 0;
        saw_negative_result     = 0;

        all_x0_observed_zero    = 1;

        prev_pc_valid           = 0;
        prev_pc                 = '0;

        num_errors              = 0;
    endfunction

    // ------------------------------------------------------------
    // Checker explícito de reset
    // ------------------------------------------------------------
    // Para pipeline, não usamos pc_fetch_mon logo após reset como
    // critério arquitetural de aprovação do PC inicial, pois o
    // fetch pode já ter avançado antes do primeiro commit.
    //
    // Nesta fase:
    // - confirmamos a saída de reset
    // - checamos x0 após reset
    // - confirmamos o PC inicial pelo primeiro commit arquitetural
    // ------------------------------------------------------------
    task run_phase(uvm_phase phase);
        wait (vif.mon_cb.rst_n === 1'b1);
        saw_reset_release = 1'b1;

        @(vif.mon_cb);

        if (vif.mon_cb.x0_value_mon !== 32'h0000_0000) begin
            num_errors++;
            `uvm_error("RV32I_P1_RESET",
                $sformatf("x0 incorreto após reset. Esperado=00000000 Observado=%08h",
                          vif.mon_cb.x0_value_mon))
        end
        else begin
            saw_reset_x0_ok = 1'b1;
            `uvm_info("RV32I_P1_RESET",
                "x0 correto após reset: 00000000",
                UVM_LOW)
        end

        `uvm_info("RV32I_P1_RESET",
            $sformatf("Saida de reset observada. O PC inicial arquitetural sera confirmado pelo primeiro commit (start_pc=%08h).",
                      start_pc),
            UVM_LOW)
    endtask

    // ------------------------------------------------------------
    // Recebe commits do monitor
    // ------------------------------------------------------------
    function void write(rv32i_commit_tr t);

        if (!saw_first_commit) begin
            saw_first_commit = 1'b1;

            if (t.pc == start_pc) begin
                saw_pc_initial_commit = 1'b1;

                `uvm_info("RV32I_P1_PC",
                    $sformatf("Primeiro commit no PC inicial esperado: %08h", t.pc),
                    UVM_LOW)
            end
            else begin
                num_errors++;
                `uvm_error("RV32I_P1_PC",
                    $sformatf("Primeiro commit em PC incorreto. Esperado=%08h Observado=%08h",
                              start_pc, t.pc))
            end

            prev_pc_valid = 1'b1;
            prev_pc       = t.pc;
        end
        else begin
            if (t.pc == (prev_pc + 32'd4))
                saw_pc_seq_step = 1'b1;

            prev_pc = t.pc;
        end

        // --------------------------------------------------------
        // Escrita em registradores
        // --------------------------------------------------------
        if (t.regwrite && (t.rd_addr != 5'd0))
            saw_regwrite_nonzero_rd = 1'b1;

        // --------------------------------------------------------
        // x0 deve permanecer sempre zero
        // --------------------------------------------------------
        if (t.x0_value !== 32'h0000_0000) begin
            all_x0_observed_zero = 1'b0;
            num_errors++;
            `uvm_error("RV32I_P1_X0",
                $sformatf("Violacao arquitetural: x0 observado diferente de zero no commit. pc=%08h instr=%08h x0=%08h",
                          t.pc, t.instr, t.x0_value))
        end

        // --------------------------------------------------------
        // Tentativas de escrita em x0
        // --------------------------------------------------------
        if (t.regwrite && (t.rd_addr == 5'd0))
            saw_x0_attempt = 1'b1;

        if (t.regwrite && (t.rd_addr == 5'd0) && is_addi_instr(t.instr))
            saw_x0_addi_attempt = 1'b1;

        if (t.regwrite && (t.rd_addr == 5'd0) &&
            (is_add_instr(t.instr) || is_sub_instr(t.instr)))
            saw_x0_rtype_attempt = 1'b1;

        // --------------------------------------------------------
        // Instruções da Fase 1
        // --------------------------------------------------------
        if (is_addi_instr(t.instr)) begin
            saw_addi = 1'b1;

            if (t.rd_data[31])
                saw_addi_negative = 1'b1;
        end

        if (is_add_instr(t.instr))
            saw_add = 1'b1;

        if (is_sub_instr(t.instr))
            saw_sub = 1'b1;

        // --------------------------------------------------------
        // Faixa de resultados observados
        // --------------------------------------------------------
        if (t.rd_data == 32'h0000_0000)
            saw_zero_result = 1'b1;
        else if (t.rd_data[31])
            saw_negative_result = 1'b1;
        else
            saw_positive_result = 1'b1;
    endfunction

    // ------------------------------------------------------------
    // Relatório da Fase 1
    // ------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("RV32I_P1_REPORT",
            $sformatf("Phase1 summary: reset_release=%0d reset_x0_ok=%0d first_commit=%0d pc_initial_commit=%0d pc_seq=%0d regwrite_nonzero_rd=%0d addi=%0d addi_neg=%0d add=%0d sub=%0d x0_attempt=%0d x0_addi=%0d x0_rtype=%0d result_pos=%0d result_zero=%0d result_neg=%0d x0_always_zero=%0d errors=%0d",
                      saw_reset_release,
                      saw_reset_x0_ok,
                      saw_first_commit,
                      saw_pc_initial_commit,
                      saw_pc_seq_step,
                      saw_regwrite_nonzero_rd,
                      saw_addi,
                      saw_addi_negative,
                      saw_add,
                      saw_sub,
                      saw_x0_attempt,
                      saw_x0_addi_attempt,
                      saw_x0_rtype_attempt,
                      saw_positive_result,
                      saw_zero_result,
                      saw_negative_result,
                      all_x0_observed_zero,
                      num_errors),
            UVM_NONE
        );

        if (!saw_reset_release)
            `uvm_warning("RV32I_P1_REPORT", "Nao foi observada saida de reset")

        if (!saw_reset_x0_ok)
            `uvm_warning("RV32I_P1_REPORT", "x0 apos reset nao foi confirmado")

        if (!saw_pc_initial_commit)
            `uvm_warning("RV32I_P1_REPORT", "O PC inicial arquitetural nao foi confirmado pelo primeiro commit")

        if (!saw_pc_seq_step)
            `uvm_warning("RV32I_P1_REPORT", "Nenhuma evidencia de PC sequencial foi observada")

        if (!saw_addi)
            `uvm_warning("RV32I_P1_REPORT", "Nenhuma instrucao ADDI foi observada")

        if (!saw_add)
            `uvm_warning("RV32I_P1_REPORT", "Nenhuma instrucao ADD foi observada")

        if (!saw_sub)
            `uvm_warning("RV32I_P1_REPORT", "Nenhuma instrucao SUB foi observada")

        if (!saw_x0_addi_attempt)
            `uvm_warning("RV32I_P1_REPORT", "Nenhuma tentativa de escrita em x0 com ADDI foi observada")

        if (!saw_x0_rtype_attempt)
            `uvm_warning("RV32I_P1_REPORT", "Nenhuma tentativa de escrita em x0 com ADD/SUB foi observada")
    endfunction

endclass

`endif