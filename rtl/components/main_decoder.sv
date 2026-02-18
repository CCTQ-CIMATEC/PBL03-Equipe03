module main_decoder (
    input  logic [6:0] op,

    //output logic pcsrc,
    output logic [1:0] resultsrc,
    output logic memwrite,
    output logic alusrc,
    output logic branch,
    output logic jump,
    output logic is_jalr,        
    output logic [1:0] immsrc,
    output logic regwrite,
    output logic [1:0] alu_op_type
);
    import riscv_pkg::*;

    always_comb begin 
        //pcsrc       = 1'b0; // PC+4 ou PC+Imm
        resultsrc   = 2'b0; // 0: ULA, 1: memória
        memwrite    = 1'b0;
        alusrc      = 1'b0; // 0: RegB, 1: mmediato
        immsrc      = 2'b00;
        regwrite    = 1'b0;
        alu_op_type = 2'b00; // 00: Add/Lw/Sw, 01: Beq, 10: R-Type/I-Type
        branch      = 1'b0;  
        jump        = 1'b0;
        is_jalr     = 1'b0;

        case(op)
            // TIPO R (add, sub, and, or, xor)
            OP_R_TYPE: begin 
                regwrite    = 1'b1;
                alu_op_type = 2'b10; // Instrui ALU Decoder a olhar funct3/7
            end

            // TIPO I - ALU (addi, andi, ori, xori) 
            OP_I_TYPE: begin 
                regwrite    = 1'b1;
                alusrc      = 1'b1;  
                alu_op_type = 2'b10; 
            end

            // TIPO S (sw)
            OP_STORE: begin 
                memwrite    = 1'b1;
                alusrc      = 1'b1;  // Endereço = RegA + Imediato
                immsrc      = 2'b01; // Formato S-Type
                alu_op_type = 2'b00; // ULA faz soma para endereço
            end

            // TIPO I - LOAD (lw)
            OP_LOAD: begin 
                regwrite    = 1'b1;  // Load PRECISA escrever no registrador
                alusrc      = 1'b1;  // Endereço = RegA + Imediato
                resultsrc   = 2'b1;  // Dado vem da Memória, não da ULA
                immsrc      = 2'b00; // Formato I-Type
                alu_op_type = 2'b00; // ULA faz soma para endereço
            end

            // TIPO B (beq)
            OP_BRANCH: begin 
                alusrc      = 1'b0;  // Compara RegA e RegB
                alu_op_type = 2'b01; // ULA faz subtração
                immsrc      = 2'b10; // Formato B-Type
                regwrite    = 1'b0;
                branch      = 1'b1;
            end

            // TIPO JAL (jump and link)
            OP_JAL: begin 
                immsrc      = 2'b11; // Formato do jump
                regwrite    = 1'b1;
                jump        = 1'b1; 
                resultsrc   = 2'b10;
            end
            
            // TIPO JALR
            OP_JALR: begin
                immsrc      = 2'b00;
                regwrite    = 1'b1;
                jump        = 1'b1;
                resultsrc   = 2'b10;
                alusrc      = 1'b1;
                alu_op_type = 2'b00;
                is_jalr     = 1'b1;
            end

        endcase
    end

endmodule