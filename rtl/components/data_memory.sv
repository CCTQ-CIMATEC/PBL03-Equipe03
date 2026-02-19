module data_memory #( 
    parameter DEPTH = 1024
)(
    input  logic clk,
    input  logic [3:0] we,          // write enable   
    input  logic [31:0] a,    // address
    input  logic [31:0] wd,   // data to write
    output logic [31:0] rd    // data read
);
    logic [31:0] datamem [0:DEPTH-1];

    
    //always_ff @(posedge clk) begin
    //    if(we)
    //        datamem[a[31:2]] <= wd; 
    //end

    always_ff @(posedge clk) begin
        if(we[0])  datamem[a[31:2]] [7:0] <= wd[7:0];
        if(we[1])  datamem[a[31:2]] [15:8] <= wd[15:8];
        if(we[2])  datamem[a[31:2]] [23:16] <= wd[23:16];
        if(we[3])  datamem[a[31:2]] [31:24] <= wd[31:24];
    end

    assign rd = datamem[a[31:2]];
endmodule 