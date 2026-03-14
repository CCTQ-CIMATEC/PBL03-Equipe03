module hazard_unit (
    input  logic [4:0] rs1E,
    input  logic [4:0] rs2E,
    input  logic [4:0] rdM,
    input  logic [4:0] rdW,
    input  logic        regwriteM,
    input  logic        regwriteW,

    output logic [1:0 ] fowardAE,
    output logic [1:0 ] fowardBE
);

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
    end

    
endmodule

// escrever bem mais sobre a lógica de funcionamento do 