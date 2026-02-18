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

    always_ff @(posedge clk) begin
        if(we3)
            rf[a3] <= wd3;
    end

    assign rd1 = (a1 != 5'b0) ? rf[a1] : 32'b0;
    assign rd2 = (a2 != 5'b0) ? rf[a2] : 32'b0;

    // =================================================================
    // DEBUG PARA O GTKWAVE: "Desempacotando" a matriz para o VCD
    // =================================================================
    logic [31:0] x1, x2, x3, x4, x5, x6, x7, x8, x9, x10;
    logic [31:0] x11, x12, x13, x14, x15, x16, x17, x18, x19, x20;
    logic [31:0] x21, x22, x23, x24, x25, x26;

    always_comb begin
        x1 = rf[1];   x2 = rf[2];   x3 = rf[3];   x4 = rf[4];   x5 = rf[5];
        x6 = rf[6];   x7 = rf[7];   x8 = rf[8];   x9 = rf[9];   x10 = rf[10];
        x11 = rf[11]; x12 = rf[12]; x13 = rf[13]; x14 = rf[14]; x15 = rf[15];
        x16 = rf[16]; x17 = rf[17]; x18 = rf[18]; x19 = rf[19]; x20 = rf[20];
        x21 = rf[21]; x22 = rf[22]; x23 = rf[23]; x24 = rf[24]; x25 = rf[25];
        x26 = rf[26];
    end
    // =================================================================
endmodule