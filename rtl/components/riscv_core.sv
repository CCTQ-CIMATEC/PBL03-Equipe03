module riscv_core (
    input  logic clk,
    input  logic rst_n,

    input  logic [31:0] instr,
    input  logic [31:0] readdata,

    output logic [31:0] pc,
    output logic        memwrite,
    output logic [31:0] aluresult,
    output logic [31:0] writedata

);
    import riscv_pkg::*;

    // SINAIS INTERNOS PROGRAM COUNTER
    logic [31:0] pcnext;
    logic [31:0] pcplus4;
    logic [31:0] pctarget;
    logic [31:0] result;
    logic        branch;
    logic        jump;
    logic        is_jalr;
    logic        [1:0] pc_mux;

    // SAIDA DATA SLICER
    logic [31:0] s_data;

    //SINAIS EXTEND
    logic [31:0] immext;

    // SINAIS INTERNOS ULA
    logic [31:0] srca;
    logic [31:0] srcb;
    logic        zero;
    logic     is_less;
    logic   is_less_u;
    

    // SINAIS DE CONTROLE
    logic pcsrc;
    logic [2:0] resultsrc;
    logic alusrc;   
    logic regwrite;
    logic [1:0] aluop;
    logic [2:0] immsrc;
    alu_ops_t aluctrl;

    
    
    //
    program_counter u_program_counter (
        .clk(clk), .rst_n(rst_n), .pcnext(pcnext), .pc(pc)
    );

    assign pcplus4  = pc + 32'd4;
    assign pctarget = pc + immext;

    //MUX PROGRAM COUNTER
    //assign pcsrc = branch & zero;
    assign pc_mux = {is_jalr, (pcsrc || jump)};
    always_comb begin 
        case(pc_mux)
        2'b00:   pcnext = pcplus4;
        2'b01:   pcnext = pctarget;
        2'b10:   pcnext = aluresult;
        2'b11:   pcnext = aluresult;    // retirar isso
        default: pcnext = pcplus4;
        endcase
    end
    //assign pcnext  = (pcsrc) ? pctarget : pcplus4; // pensar um pouco mais nessa lógica
    

    // REG FILE 
    reg_file u_reg_file (
        .clk(clk),
        .we3(regwrite),
        .a1(instr[19:15]), 
        .a2(instr[24:20]), 
        .a3(instr[11:7]),
        .rd1(srca),
        .rd2(writedata),
        .wd3(result)
    );

    //IMEDDIATE GENERATOR
    extend u_extend (
        .instr(instr[31:7]), .immsrc(immsrc), .immext(immext)
    );

    // MUX DA ULA
    assign srcb = alusrc ? immext : writedata;

    // ULA
    alu u_alu(
        .a(srca), 
        .b(srcb), 
        .ctrl(aluctrl), 
        .result(aluresult), 
        .zero(zero),
        .is_less(is_less),
        .is_less_u(is_less_u)
    );

    // MUX WRITE BACK
    always_comb begin 
        case(resultsrc)
            3'b000:   result = aluresult;
            3'b001:   result = s_data;
            3'b010:   result = pcplus4;
            3'b011:   result = immext;
            3'b100:   result = pctarget;
        default: result = 32'b0;
        endcase
    end

    // UNIDADE DE CONTROLE
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

    branch_control u_branch_control(
        .funct3(instr[14:12]),
        .branch(branch),
        .zero(zero),
        .is_less(is_less),
        .is_less_u(is_less_u),
        .pcsrc(pcsrc)
    );

    data_slicer u_data_slicer(
        .readdata(readdata),
        .funct3(instr[14:12]),
        .d_select(aluresult[1:0]),
        .data(s_data)
    );


endmodule