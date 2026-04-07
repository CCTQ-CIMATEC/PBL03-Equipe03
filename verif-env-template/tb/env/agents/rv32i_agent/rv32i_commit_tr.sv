`ifndef RV32I_COMMIT_TR_SV
`define RV32I_COMMIT_TR_SV

class rv32i_commit_tr extends uvm_sequence_item;
    `uvm_object_utils(rv32i_commit_tr)

    // ------------------------------------------------------------
    // Identificação temporal
    // ------------------------------------------------------------
    longint unsigned cycle;

    // ------------------------------------------------------------
    // Estado arquitetural observado / esperado
    // ------------------------------------------------------------
    bit [31:0] pc;
    bit [31:0] instr;

    bit        regwrite;
    bit [4:0]  rd_addr;
    bit [31:0] rd_data;

    bit [31:0] x0_value;

    // ------------------------------------------------------------
    // Sinais auxiliares de debug
    // ------------------------------------------------------------
    bit        stallF;
    bit        stallD;
    bit        flushE;

    bit [31:0] pc_fetch;
    bit [31:0] instr_fetch;
    bit [31:0] instr_dec;
    bit [31:0] instr_ex;

    // ------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------
    function new(string name = "rv32i_commit_tr");
        super.new(name);
    endfunction

    // ------------------------------------------------------------
    // Print amigável
    // ------------------------------------------------------------
    function string convert2string();
        return $sformatf(
            "cycle=%0d pc=%08h instr=%08h regwrite=%0b rd=x%0d rd_data=%08h x0=%08h stallF=%0b stallD=%0b flushE=%0b",
            cycle, pc, instr, regwrite, rd_addr, rd_data, x0_value,
            stallF, stallD, flushE
        );
    endfunction

    // ------------------------------------------------------------
    // Comparação básica
    // ------------------------------------------------------------
    function bit compare_commit(rv32i_commit_tr rhs, output string msg);
        msg = "";

        if (rhs == null) begin
            msg = "rhs é null";
            return 0;
        end

        if (pc !== rhs.pc) begin
            msg = $sformatf("PC mismatch: exp=%08h obs=%08h", rhs.pc, pc);
            return 0;
        end

        if (instr !== rhs.instr) begin
            msg = $sformatf("INSTR mismatch: exp=%08h obs=%08h", rhs.instr, instr);
            return 0;
        end

        if (regwrite !== rhs.regwrite) begin
            msg = $sformatf("REGWRITE mismatch: exp=%0b obs=%0b", rhs.regwrite, regwrite);
            return 0;
        end

        if (rd_addr !== rhs.rd_addr) begin
            msg = $sformatf("RD mismatch: exp=x%0d obs=x%0d", rhs.rd_addr, rd_addr);
            return 0;
        end

        if (rd_data !== rhs.rd_data) begin
            msg = $sformatf("RDDATA mismatch: exp=%08h obs=%08h", rhs.rd_data, rd_data);
            return 0;
        end

        if (x0_value !== rhs.x0_value) begin
            msg = $sformatf("X0 mismatch: exp=%08h obs=%08h", rhs.x0_value, x0_value);
            return 0;
        end

        return 1;
    endfunction

endclass

`endif