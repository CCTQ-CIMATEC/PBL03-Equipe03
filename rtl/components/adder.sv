// Módulo genérico para soma de dois números de 32 bits e resultado de 32 bits.
`timescale 1ns/1ps

module adder(
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y 
);
    assign y = a + b;

endmodule