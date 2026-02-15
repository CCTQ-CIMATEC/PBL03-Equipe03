module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  riscv_pkg::alu_ops_t ctrl,
    output logic [31:0] result,
    output logic        zero
);
    import riscv_pkg::*; 

    always_comb begin
        case (ctrl)
        ALU_ADD: result = a + b;
        ALU_SUB: result = a - b;
        ALU_AND: result = a & b;
        ALU_OR:  result = a | b;
        ALU_XOR: result = a ^ b;
        default: result = 32'b0;
        endcase
    end

    assign zero = (result == 32'd0);
endmodule