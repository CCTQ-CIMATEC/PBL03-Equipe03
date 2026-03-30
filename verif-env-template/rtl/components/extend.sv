`timescale 1ns/1ps

module extend(
    input  logic [2:0] immsrc,
    input  logic [31:7] instr,
    output logic [31:0] immext
);

    // always_comb begin 
    //     case(immsrc)
    //     3'b000: immext = {{20{instr[31]}}, instr[31:20]};                                // i type
    //     3'b001: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};                   // s type
    //     3'b010: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};   // b type instructions
    //     3'b011: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // j type
    //     3'b100: immext = {{{instr[31:12]}}, 12'b0};                                    // u type
    //     default: immext = 32'b0;
    //     endcase

    // end
    always_comb begin 
        case(immsrc)
            // I-type: imediato de 12 bits [31:20]
            3'b000:  immext = {{20{instr[31]}}, instr[31:20]};
            
            // S-type: imediato de 12 bits [31:25] e [11:7]
            3'b001:  immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            
            // B-type: 13 bits (bit 0 é sempre 0)
            3'b010:  immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            
            // J-type: 21 bits (bit 0 é sempre 0)
            3'b011:  immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            
            // U-type: 20 bits deslocados para a esquerda (bits 11:0 são 0)
            3'b100:  immext = {instr[31:12], 12'b0}; 
            
            default: immext = 32'b0;
        endcase
    end
endmodule