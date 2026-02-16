module alu_decoder (
    input  logic [2:0] funct3, 
    input  logic       funct7_b5,
    input  logic       opb5,
    input  logic [1:0] alu_op_type,
    output riscv_pkg::alu_ops_t alu_ctrl
);

    import riscv_pkg::*;

    always_comb begin 
        case(alu_op_type)
        2'b00: alu_ctrl = ALU_ADD;
        2'b01: alu_ctrl = ALU_SUB;
        2'b10: begin 
            case (funct3)
            FUNCT3_ADD_SUB: begin 
                if(funct7_b5 && opb5)
                    alu_ctrl = ALU_SUB;
                else
                    alu_ctrl = ALU_ADD;
            end
            FUNCT3_AND:        alu_ctrl = ALU_AND;
            FUNCT3_OR:         alu_ctrl = ALU_OR;
            FUNCT3_XOR:        alu_ctrl = ALU_XOR;
            FUNCT3_SLT:        alu_ctrl = ALU_SLT;
            FUNCT3_SLTU_SLTUI: alu_ctrl = ALU_SLTU;
            endcase
        end
        default: alu_ctrl = ALU_ADD;
        endcase
    end
endmodule