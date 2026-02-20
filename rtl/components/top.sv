module top (
    input clk,
    input rst_n
);

// SINAIS INTERNOS
logic [31:0] pc;
logic [31:0] instr;
logic [31:0] aluresult;
logic [31:0] writedata; 
logic [31:0] readdata;
logic [3:0]  write_enable;

riscv_core u_riscv_core (
    .clk(clk),
    .rst_n(rst_n),
    .instr(instr),
    .readdata(readdata),
    .pc(pc),
    .write_enable(write_enable),
    .aluresult(aluresult),
    .writedata(writedata)
);

data_memory u_data_memory(
    .clk(clk),
    .we(write_enable),
    .a(aluresult),
    .wd(writedata),
    .rd(readdata)
);

instruction_memory u_instruction_memory(
    .a(pc),
    .rd(instr)
);
endmodule