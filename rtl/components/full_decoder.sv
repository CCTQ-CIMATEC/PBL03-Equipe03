`timescale 1ns/1ps

module full_decoder (
    input  logic [31:0] instr,

    output logic        jump,
    output logic        branch,
    output logic        regwrite,
    output logic [2:0]  resultsrc,
    output logic        memwrite,
    output riscv_pkg::alu_ops_t aluctrl,
    output logic        alusrc,
    output logic [2:0]  immsrc,
    output logic        is_jalr,
    output logic [2:0]  funct3
);

    import riscv_pkg::*;

    //SINAIS INTERNOS
    logic [1:0] aluop;

    assign funct3 = instr[14:12];

    main_decoder u_main_decoder (
        .op(instr[6:0]),
        .branch(branch),
        .jump(jump),
        .is_jalr(is_jalr),
        .resultsrc(resultsrc),
        .memwrite(memwrite),
        .alusrc(alusrc),
        .immsrc(immsrc),
        .regwrite(regwrite),
        .alu_op_type(aluop)
    );

    alu_decoder u_alu_decoder (
        .funct3(instr[14:12]),
        .funct7_b5(instr[30]),
        .opb5(instr[5]),
        .alu_op_type(aluop),
        .alu_ctrl(aluctrl)
    );


endmodule


