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
    logic        regwriteD;
    logic [2:0 ] resultsrcD;
    logic        memwriteD;
    logic [2:0]  aluctrlD;
    logic        alusrcD;
    // data signals
    logic [31:0] instrD;
    logic [31:0] rd1D;
    logic [31:0] rd2D;
    logic [2:0 ] funct3D;
    logic [31:0] rdD;
    logic [31:0] immextD;
    logic [31:0] pcD;
    logic [31:0] pcplus4D;

    // SINAIS INTERNOS EXECUTE
    // control signals
    logic        jumpE;
    logic        branchE;
    logic        regwriteE;
    logic [2:0 ] resultsrcE;
    logic        memwriteE;
    logic [2:0]  aluctrlE;
    logic        alusrcE;
    // data signals
    logic [31:0] instrE;
    logic [31:0] rd1E;
    logic [31:0] rd2E;
    logic [2:0 ] funct3E;
    logic [31:0] rdE;
    logic [31:0] immextE;
    logic [31:0] pcE;
    logic [31:0] pcplus4E;
    logic [31:0] aluresultE;
    logic [31:0] pctargetE;

    //SINAIS INTERNOS MEMORY
    // control signals
    logic        regwriteM;
    logic        resulsrcM;
    logic        memwriteM;

    // data signals
    logic [31:0]  aluresultM;
    logic [31:0]  rd2M;
    logic [2:0 ]  funct3M;
    logic [31:0]  rdM;
    logic [31:0]  pctargetM;
    logic [31:0]  immextM;
    logic [31:0]  pcplus4M;
    logic [31:0]  dataM;


    // SINAIS INTERNOS WRITEBACK
    // control signals
    logic         regwriteW;
    logic         resultsrcW;

    // data signals
    logic [31:0]  aluresultW;
    logic [31:0]  dataW;
    logic [31:0]  rdW;
    logic [31:0]  pctargetW;
    logic [31:0]  immextW;
    logic [31:0]  pcplus4W;


    //----------------------------------------------------
    //             REGISTRADORES DE PIPELINE            //
    //----------------------------------------------------

    // FETCH/DECODE REGISTER
    always_ff @(posedge clk) begin 
        instrD    <= instrF;
        pcD       <= pcF;
        pcplus4D  <= pcplus4F;
    end


    // DECODE/EXECUTE REGISTER
    always_ff @(posedgeclk) begin
        jumpE     <= jumpD;
        branchE   <= branchD;
        regwriteE <= regwriteD;
        resulsrcE <= resultsrcD;
        memwriteE <= memwriteD;
        aluctrlE  <= aluctrlD;
        alusrcE   <= alusrcD;

        rd1E      <= rd1D;
        rd2E      <= rd2D;
        funct3E   <= funct3D;
        rdE       <= rdD;
        pcE       <= pcD;
        immextE   <= immextD;
        pcplus4E  <= pcplus4D; 

    end

    // EXECUTE/MEMORY REGISTER
    always_ff @(posedge clk) begin 
        regwriteM  <= regwriteE;
        resultsrcM <= resultsrcE;
        memwriteM  <= memwriteE;

        aluresulM  <= aluresultE;
        rd2M       <= rd2E;
        funct3M    <= funct3E;
        rdM        <= rdE;
        pctargetM  <= pctargetE;
        immextM    <= immextE
        pcplus4M   <= pcplus4E; 

    end

    // MEMORY/WRITEBACK REGISTER
    always_ff @(posedge clk) begin 
        regwriteW  <= regwriteM;
        resultsrcW <= resultsrcM;

        aluresultW <= aluresulM;
        dataW      <= dataM;
        rdW        <= rdM;
        pctargetW  <= pctargetM;
        immextW    <= immextM;
        pcplus4W   <= pcplus4M;
    end


    //----------------------------------------------------
    //                DATAPATH E CONTROLE               //
    //----------------------------------------------------

    


endmodule 