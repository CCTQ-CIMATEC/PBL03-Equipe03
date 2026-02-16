module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  riscv_pkg::alu_ops_t ctrl,
    output logic [31:0] result,
    output logic        zero
);
    import riscv_pkg::*;

    // SINAIS INTERNOS
    logic [32:0] sum;
    logic        n;      // Pega result[31] para verificar o sinal do resultado
    logic        v;      // detecta se ocorreu ou não um overflow
    logic        is_sub; // verifica se a operação recai em uma subtração
    logic        brw;      // detecta borrow

    always_comb begin 
        if(ctrl == ALU_SUB || ctrl == ALU_SLT || ctrl == ALU_SLTU) // futuramente acredito que outras instruções recairão aqui
            is_sub = 1'b1;
        else 
            is_sub = 1'b0;
    end

    assign n   = sum[31];               // capturando o bit mais significativo para checagem de sinal
    assign sum = is_sub ? ({1'b0, a} - {1'b0, b}) : ({1'b0, a} + {1'b0, b}); // estrutura única para tratar
    assign v   = ((a[31] != b[31]) && (a[31] != sum[31])); // verifica se houve overflow na subtração, implementar para a soma.
    assign brw   = sum[32];

    always_comb begin
        case (ctrl)
        ALU_ADD:  result = sum;
        ALU_SUB:  result = sum;
        ALU_AND:  result = a & b;
        ALU_OR:   result = a | b;
        ALU_XOR:  result = a ^ b;
        ALU_SLT:  result = {31'b0, (n^v)};
        ALU_SLTU: result = {31'b0, sum[32]};
        default:  result = 32'b0;
        endcase
    end

    assign zero = (result == 32'd0);
endmodule