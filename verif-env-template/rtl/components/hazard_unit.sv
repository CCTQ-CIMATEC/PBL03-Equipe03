module hazard_unit (
    input  logic [4:0] rs1D,
    input  logic [4:0] rs2D,
    input  logic [4:0] rdE,
    input  logic [4:0] rs1E,
    input  logic [4:0] rs2E,
    input  logic [4:0] rdM,
    input  logic [4:0] rdW,
    input  logic       regwriteM,
    input  logic       regwriteW,
    input  logic [2:0] resultsrcE,  

    output logic [1:0 ] fowardAE,
    output logic [1:0 ] fowardBE,
    output logic        stallF,
    output logic        stallD,
    output logic        flushE          
);
    // +--------------------------------------+
    // |               FOWARDING              |
    // +--------------------------------------+

    // FOWARDING COMBINATIONAL HANDLER SRCA
    always_comb begin
        if((rs1E == rdM) && (regwriteM) && (rdM!=5'b0))
            fowardAE = 2'b01;
        else begin 
            if((rs1E == rdW) && (regwriteW) && (rdW!=5'b0))
                fowardAE = 2'b10;
            else
                fowardAE = 2'b00;
        end 
    end

    // FOWARDING COMBINATIONAL HANDLER SRCB
    always_comb begin
        if((rs2E == rdM) && (regwriteM) && (rdM!=5'b0))
            fowardBE = 2'b01;
        else begin 
            if((rs2E == rdW) && (regwriteW) && (rdW!=5'b0))
                fowardBE = 2'b10;
            else
                fowardBE = 2'b00;
        end
        $display("HAZARD: rs2E=%d, rdM=%d, regwriteM=%b, fowardBE=%b", rs2E, rdM, regwriteM, fowardBE);
    end

    // +--------------------------------------+
    // |               LW STALL               |
    // +--------------------------------------+

    // always_comb begin 
    //     if ((resultsrcE == 3'b001) && ((rs1D == rdE) || (rs2D == rdE))) begin
    //         stallF = 1'b0;   // trava PC
    //         stallD = 1'b0;   // trava registrador F/D
    //         flushE = 1'b1;   // insere bolha no D/E
    //     end else begin
    //         stallF = 1'b1;
    //         stallD = 1'b1;
    //         flushE = 1'b0;
    //     end 
    // end

    always_comb begin 
    // Valores padrão
    stallF = 1'b0;
    stallD = 1'b0;
    flushE = 1'b0;
    
    if ((resultsrcE == 3'b001) && ((rs1D == rdE) || (rs2D == rdE))) begin
        stallF = 1'b1;   // TRAVAR
        stallD = 1'b1;
        flushE = 1'b1;
    end
    end

    

    

    
endmodule

// escrever bem mais sobre a lógica de funcionamento do 