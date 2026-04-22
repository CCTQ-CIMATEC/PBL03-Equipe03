`ifndef RV32I_PHASE5_CHECKER_SV
`define RV32I_PHASE5_CHECKER_SV

class rv32i_phase5_checker extends rv32i_phase4_checker;
    `uvm_component_utils(rv32i_phase5_checker)

    bit saw_forward_a_from_m;
    bit saw_forward_a_from_w;
    bit saw_forward_b_from_m;
    bit saw_forward_b_from_w;
    bit saw_forward_any;

    bit saw_load_use_stall;
    bit saw_stall_signature;

    bit saw_control_flush;
    bit saw_hazard_event;

    function new(string name = "rv32i_phase5_checker", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        saw_forward_a_from_m = 0;
        saw_forward_a_from_w = 0;
        saw_forward_b_from_m = 0;
        saw_forward_b_from_w = 0;
        saw_forward_any      = 0;

        saw_load_use_stall   = 0;
        saw_stall_signature  = 0;

        saw_control_flush    = 0;
        saw_hazard_event     = 0;
    endfunction

    function bit is_load_instr(bit [31:0] instr);
        return is_lb_instr(instr)  ||
               is_lh_instr(instr)  ||
               is_lw_instr(instr)  ||
               is_lbu_instr(instr) ||
               is_lhu_instr(instr);
    endfunction

    virtual function void write(rv32i_commit_tr t);
        if (t == null)
            return;

        // Mantém toda a cobertura/checagem anterior
        if (t.evt_kind != RV32I_EVT_HAZARD)
            super.write(t);

        // Qualquer sample útil de hazard
        if (t.stallF || t.stallD || t.flushD || t.flushE ||
            (t.fowardAE != 2'b00) || (t.fowardBE != 2'b00)) begin
            saw_hazard_event = 1'b1;
        end

        // Forwarding
        case (t.fowardAE)
            2'b01: begin
                saw_forward_a_from_m = 1'b1;
                saw_forward_any      = 1'b1;
            end
            2'b10: begin
                saw_forward_a_from_w = 1'b1;
                saw_forward_any      = 1'b1;
            end
            default: ;
        endcase

        case (t.fowardBE)
            2'b01: begin
                saw_forward_b_from_m = 1'b1;
                saw_forward_any      = 1'b1;
            end
            2'b10: begin
                saw_forward_b_from_w = 1'b1;
                saw_forward_any      = 1'b1;
            end
            default: ;
        endcase

        // Assinatura típica do load-use stall
        if (t.stallF && t.stallD && t.flushE) begin
            saw_stall_signature = 1'b1;
            saw_load_use_stall  = 1'b1;
        end

        // Flush de controle
        if (t.flushD)
            saw_control_flush = 1'b1;
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("RV32I_P5_REPORT",
            $sformatf(
                "Phase5 summary: hazard_evt=%0d fwd_any=%0d fwdA_M=%0d fwdA_W=%0d fwdB_M=%0d fwdB_W=%0d stall_sig=%0d load_use_stall=%0d ctrl_flush=%0d",
                saw_hazard_event,
                saw_forward_any,
                saw_forward_a_from_m,
                saw_forward_a_from_w,
                saw_forward_b_from_m,
                saw_forward_b_from_w,
                saw_stall_signature,
                saw_load_use_stall,
                saw_control_flush
            ),
            UVM_NONE
        );

        if (!saw_hazard_event)
            `uvm_warning("RV32I_P5_REPORT", "Nenhum evento de hazard foi observado")

        if (!saw_forward_any)
            `uvm_warning("RV32I_P5_REPORT", "Nenhuma evidencia de forwarding foi observada")

        if (!saw_forward_a_from_m)
            `uvm_warning("RV32I_P5_REPORT", "Nenhuma evidencia de forwarding M->E em srcA foi observada")

        if (!saw_forward_a_from_w)
            `uvm_warning("RV32I_P5_REPORT", "Nenhuma evidencia de forwarding W->E em srcA foi observada")

        if (!saw_forward_b_from_m)
            `uvm_warning("RV32I_P5_REPORT", "Nenhuma evidencia de forwarding M->E em srcB foi observada")

        if (!saw_forward_b_from_w)
            `uvm_warning("RV32I_P5_REPORT", "Nenhuma evidencia de forwarding W->E em srcB foi observada")

        if (!saw_stall_signature)
            `uvm_warning("RV32I_P5_REPORT", "Nenhuma assinatura de stall foi observada")

        if (!saw_load_use_stall)
            `uvm_warning("RV32I_P5_REPORT", "Nenhuma evidencia de load-use stall foi observada")

        if (!saw_control_flush)
            `uvm_warning("RV32I_P5_REPORT", "Nenhuma evidencia de flush de controle foi observada")
    endfunction

endclass

`endif