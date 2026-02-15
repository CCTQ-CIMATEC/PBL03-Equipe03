module data_memory #( 
    parameter DEPTH = 1024
)(
    input  logic clk,
    input  logic we,          // write enable   
    input  logic [31:0] a,    // address
    input  logic [31:0] wd,   // data to write
    output logic [31:0] rd    // data read
);
    logic [31:0] datamem [0:DEPTH-1];

    
    always_ff @(posedge clk) begin
        if(we)
            datamem[a[31:2]] <= wd; 
    end

    assign rd = datamem[a[31:2]];
endmodule 