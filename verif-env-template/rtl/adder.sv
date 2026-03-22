//------------------------------------------------------------------------------
// 4-bit Adder Module
//------------------------------------------------------------------------------
// This module performs the addition of two 4-bit numbers with a carry-in and 
// produces a 4-bit sum and a carry-out.
//
// Author: Nelson Alves
// Date  : October 2023
//------------------------------------------------------------------------------

module adder #(
    parameter DATA_WIDTH = 4
)(
    input  logic [DATA_WIDTH-1:0] x,    // Input x
    input  logic [DATA_WIDTH-1:0] y,    // Input y
    input  logic                  cin,  // Carry-in input
    output logic [DATA_WIDTH-1:0] sum,  // Sum output
    output logic                  cout  // Carry-out output
);
    // Internal carry wires
    logic [DATA_WIDTH:0] carry;

    // Assign carry-in to the first carry bit
    assign carry[0] = cin;

    // Generate block to instantiate full adders
    genvar i;
    generate
        for (i = 0; i < DATA_WIDTH; i++) begin : adder_gen
            full_adder fa(
                .x(x[i]),
                .y(y[i]),
                .cin(carry[i]),
                .s(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    // Assign the final carry-out
    assign cout = carry[DATA_WIDTH];
endmodule


