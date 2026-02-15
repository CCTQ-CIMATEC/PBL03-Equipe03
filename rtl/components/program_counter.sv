module program_counter (
    input  logic clk,
    input  logic rst_n,
    input  logic  [31:0] pcnext,
    output logic  [31:0] pc 
);
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            pc <= 32'b0;
        else
            pc <= pcnext;
    end
endmodule