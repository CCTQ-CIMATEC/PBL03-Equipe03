// Módulo genérico para soma de dois números de 32 bits e resultado de 32 bits.

module adder(
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y 
);
    assign y = a + b;

endmodule