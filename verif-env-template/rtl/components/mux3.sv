//Mux genérico 3to1

`timescale 1ns/1ps


module mux3 (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c,
    input  logic [1:0 ] s,
    output logic [31:0] y
);
    always_comb begin
        case (s)
        2'b00: y = a;
        2'b01: y = b;
        2'b10: y = c;
        default: y = 32'b0;
        endcase
    end
endmodule