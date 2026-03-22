//------------------------------------------------------------------------------
// Half Adder Module
//------------------------------------------------------------------------------
// This module performs the addition of two single-bit numbers and produces a 
// sum and a carry-out.
//
// Author: Nelson Alves
// Date  : October 2023
//------------------------------------------------------------------------------

module half_adder (
    input  logic x,    // Input x
    input  logic y,    // Input y
    output logic s,    // Sum output
    output logic c     // Carry-out output
);
    // Sum and carry-out logic
    assign s = x ^ y;
    assign c = x & y;
endmodule
