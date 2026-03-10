`timescale 1ns/1ps

module pipelined (
    input logic clk,
    input logic rst
);

    import riscv_pkg::*;

    //----------------------------------------------------
    //        SINAIS INTERNOS DE CONTROLE E DADOS       //
    //----------------------------------------------------

    // SINAIS INTERNOS FETCH
    logic [31:0] instrF;
    logic [31:0] pcF;
    logic [31:0] pcplus4F;


    //SINAIS INTERNOS DECODE
    // control signals
    logic        jumpD;
    logic        branchD;
    logic        is_jalrD;
    logic        regwriteD;
    logic [2:0 ] resultsrcD;
    logic        memwriteD;
    riscv_pkg::alu_ops_t aluctrlD;
    logic        alusrcD;
    logic [2:0]  immsrcD;
    // data signals
    logic [31:0] instrD;
    logic [31:0] rd1D;
    logic [31:0] rd2D;
    logic [2:0 ] funct3D;
    logic [4:0 ] rdD;
    logic [31:0] immextD;
    logic [31:0] pcD;
    logic [31:0] pcplus4D;

    // SINAIS INTERNOS EXECUTE
    // control signals
    logic        jumpE;
    logic        branchE;
    logic        is_jalrE;
    logic        regwriteE;
    logic [2:0 ] resultsrcE;
    logic        memwriteE;
    riscv_pkg::alu_ops_t  aluctrlE;
    logic        alusrcE;
    // data signals
    logic [31:0] instrE;
    logic [31:0] rd1E;
    logic [31:0] rd2E;
    logic [2:0 ] funct3E;
    logic [4:0 ] rdE;
    logic [31:0] immextE;
    logic [31:0] pcE;
    logic [31:0] pcplus4E;
    logic [31:0] aluresultE;
    logic [31:0] pctargetE;

    //SINAIS INTERNOS MEMORY
    // control signals
    logic        regwriteM;
    logic [2:0 ] resultsrcM;
    logic        memwriteM;

    // data signals
    logic [31:0]  aluresultM;
    logic [31:0]  rd2M;
    logic [2:0 ]  funct3M;
    logic [4:0 ]  rdM;
    logic [31:0]  pctargetM;
    logic [31:0]  immextM;
    logic [31:0]  pcplus4M;
    logic [31:0]  dataM;


    // SINAIS INTERNOS WRITEBACK
    // control signals
    logic         regwriteW;
    logic [2:0]   resultsrcW;

    // data signals
    logic [31:0]  aluresultW;
    logic [31:0]  dataW;
    logic [4:0 ]  rdW;
    logic [31:0]  pctargetW;
    logic [31:0]  immextW;
    logic [31:0]  pcplus4W;


    //----------------------------------------------------
    //             REGISTRADORES DE PIPELINE            //
    //----------------------------------------------------

    // FETCH/DECODE REGISTER
    always_ff @(posedge clk or negedge rst) begin 
        if (!rst) begin
            instrD    <= 32'h00000013; 
            pcD       <= 32'b0;
            pcplus4D  <= 32'b0;
        end else begin
            instrD    <= instrF;
            pcD       <= pcF;
            pcplus4D  <= pcplus4F;
        end
    end


    // DECODE/EXECUTE REGISTER
    always_ff @(posedge clk or negedge rst) begin
        if(!rst) begin 
            regwriteE  <= 1'b0;
            memwriteE  <= 1'b0;
            jumpE      <= 1'b0;
            branchE    <= 1'b0;
        end else begin
            jumpE      <= jumpD;
            branchE    <= branchD;
            is_jalrE   <= is_jalrD;
            regwriteE  <= regwriteD;
            resultsrcE <= resultsrcD;
            memwriteE  <= memwriteD;
            aluctrlE   <= aluctrlD;
            alusrcE    <= alusrcD;

            rd1E       <= rd1D;
            rd2E       <= rd2D;
            funct3E    <= funct3D;
            rdE        <= rdD;
            pcE        <= pcD;
            immextE    <= immextD;
            pcplus4E   <= pcplus4D;
        end
         
    end

    // EXECUTE/MEMORY REGISTER
    always_ff @(posedge clk) begin
        if(!rst) begin 
            regwriteM <= 1'b0;
            memwriteM <= 1'b0;
        end else begin 
            regwriteM  <= regwriteE;
            resultsrcM <= resultsrcE;
            memwriteM  <= memwriteE;

            aluresultM <= aluresultE;
            rd2M       <= rd2E;
            funct3M    <= funct3E;
            rdM        <= rdE;
            pctargetM  <= pctargetE;
            immextM    <= immextE;
            pcplus4M   <= pcplus4E;
        end 
 

    end

    // MEMORY/WRITEBACK REGISTER
    always_ff @(posedge clk) begin
        if(!rst) begin 
            regwriteW <= 1'b0;
        end else begin 
            regwriteW  <= regwriteM;
            resultsrcW <= resultsrcM;

            aluresultW <= aluresultM;
            dataW      <= dataM;
            rdW        <= rdM;
            pctargetW  <= pctargetM;
            immextW    <= immextM;
            pcplus4W   <= pcplus4M;
        end
        
    end


    //----------------------------------------------------
    //                DATAPATH E CONTROLE               //
    //----------------------------------------------------


    // CONTROL UNIT
    // SINAIS CONTROL_UNIT

    full_decoder u_full_decoder (
        .instr(instrD),
        .jump(jumpD),
        .branch(branchD),
        .regwrite(regwriteD),
        .resultsrc(resultsrcD),
        .memwrite(memwriteD),
        .aluctrl(aluctrlD),
        .alusrc(alusrcD),
        .immsrc(immsrcD),
        .is_jalr(is_jalrD),
        .funct3(funct3D)    

    );

    // PROGRAM COUNTER
    // SINAIS PROGRAM COUNTER
    logic        pcsrc;
    logic [31:0] pcnext;
    logic [31:0] pc;
    logic [1:0]  pcmux;

    assign pcmux = {is_jalrE, (pcsrc || jumpE)};  

    assign pcplus4F  = pc + 32'd4;
    assign pctargetE = pcE + immextE;
    always_comb begin 
        case(pcmux) 
            2'b00:   pcnext = pcplus4F;
            2'b01:   pcnext = pctargetE;
            2'b10:   pcnext = aluresultE;
            2'b11:   pcnext = aluresultE;    
            default: pcnext = pcplus4F; 
        endcase
    end

    program_counter u_program_counter (
        .clk(clk), .rst_n(rst), .pcnext(pcnext), .pc(pc)
    );

    assign pcF = pc;

    // ULA
    // SINAIS ULA
    logic         zero;
    logic         is_less;
    logic         is_less_u;
    logic [31:0]  srcb;
    assign srcb = alusrcE ? immextE : rd2E;

    alu u_alu(
        .a(rd1E), 
        .b(srcb), 
        .ctrl(aluctrlE), 
        .result(aluresultE), 
        .zero(zero),
        .is_less(is_less),
        .is_less_u(is_less_u)
    );

    // BRANCH CONTROL
    // SINAIS BRANCH CONTROL

    branch_control u_branch_control(
        .funct3(funct3E),
        .branch(branchE),
        .zero(zero),
        .is_less(is_less),
        .is_less_u(is_less_u),
        .pcsrc(pcsrc)
    );

    // INSTRUCTION MEMORY
    // SINAIS INSTRUCTION MEMORY

    instruction_memory u_instruction_memory(
        .a(pc),
        .rd(instrF)
    );
    // REGFILE
    // SINAIS REGFILE
    logic [31:0] resultW;

    reg_file u_reg_file_n (
        .clk(clk),
        .we3(regwriteW),     // escrita somente no writeback e na borda negativa do clock, negedge
        .a1(instrD[19:15]), 
        .a2(instrD[24:20]), 
        .a3(rdW),            // vindo do writeback rapaz
        .rd1(rd1D),          // no single cycle: .rd1(srca),
        .rd2(rd2D),          // no single cycle: .rd2(rd2_pure),
        .wd3(resultW)        // não esquecer de declarar esse sinal e apagar o comentário
    );

    assign rdD = instrD[11:7];

    // EXTEND
    // SINAIS EXTEND
    extend u_extend (
        .instr(instrD[31:7]), 
        .immsrc(immsrcD),     
        .immext(immextD)
    );

    // DATA MASKER
    // SINAIS DATA MASKER
    logic [3:0 ]  writeenableM;
    logic [31:0]  writedataM;

    data_masker u_data_masker(
        .writedata_in(rd2M),
        .funct3(funct3M),
        .d_select(aluresultM[1:0]),
        .we(memwriteM),
        .writedata_out(writedataM),
        .write_enable(writeenableM)
    );

    // DATA MEMORY
    // SINAIS DATA MEMORY
    logic [31:0]  readdataM;

    data_memory u_data_memory(
        .clk(clk),
        .we(writeenableM),
        .a(aluresultM),
        .wd(writedataM),
        .rd(readdataM)
    );

    // DATA SLICER
    // SINAIS DATA SLICER

    data_slicer u_data_slicer(
        .readdata(readdataM),
        .funct3(funct3M),
        .d_select(aluresultM[1:0]),
        .data(dataM)
    );

    // MUX RESULTW
    // SINAIS MUX RESULTW      
    always_comb begin
        case(resultsrcW)
            3'b000:   resultW = aluresultW;
            3'b001:   resultW = dataW;
            3'b010:   resultW = pcplus4W;
            3'b011:   resultW = immextW;
            3'b100:   resultW = pctargetW;
        default: resultW = 32'b0;
        endcase 
    end


endmodule 