`timescale 1ns/1ps

module reg_file(
    input  logic       clk,
    input  logic       we3,
    input  logic [4:0]  a1,
    input  logic [4:0]  a2,
    input  logic [4:0]  a3,
    input  logic [31:0] wd3,
    output logic [31:0] rd1,
    output logic [31:0] rd2
);
    
    logic [31:0] rf [31:0];

    initial begin
        for (int i = 0; i < 32; i++) rf[i] = 32'b0;
    end

    always_ff @(negedge clk) begin
        if(we3)
            rf[a3] <= wd3;
            $display("DEBUG RF: Escrita em x%d = %h no tempo %t", a3, wd3, $time);
    end

    assign rd1 = (a1 != 5'b0) ? rf[a1] : 32'b0;
    assign rd2 = (a2 != 5'b0) ? rf[a2] : 32'b0;


endmodule