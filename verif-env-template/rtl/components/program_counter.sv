module program_counter (
    input  logic clk,
    input  logic rst_n,
    input  logic ena,
    input  logic  [31:0] pcnext,
    output logic  [31:0] pc 
);
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            pc <= 32'b0;
        else if(ena)
                pc <= pc;
            else
                pc <= pcnext;
    end

    always @(posedge clk) begin
        `ifdef DEBUG
        $display("PC DEBUG: clk=%b, rst=%b, ena=%b, pcnext=%h, pc=%h", 
                clk, rst_n, ena, pcnext, pc);
        `endif 
    end
endmodule