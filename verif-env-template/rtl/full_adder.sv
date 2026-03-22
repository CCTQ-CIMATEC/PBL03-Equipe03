//------------------------------------------------------------------------------
// Full Adder Module
//------------------------------------------------------------------------------
// This module performs the addition of two single-bit numbers with a carry-in 
// and produces a sum and a carry-out.
//
// Author: Nelson Alves
// Date  : October 2023
//------------------------------------------------------------------------------

module full_adder (
    input  logic x,    // Input x
    input  logic y,    // Input y
    input  logic cin,  // Carry-in input
    output logic s,    // Sum output
    output logic cout  // Carry-out output
);
    // Internal wires for half adder outputs
    logic s1, c1, c2;

    // Instantiate two half adders
    half_adder ha1(.x(x), .y(y), .s(s1), .c(c1));
    half_adder ha2(.x(cin), .y(s1), .s(s), .c(c2));

    // Carry-out logic
    assign cout = c1 | c2;
endmodule