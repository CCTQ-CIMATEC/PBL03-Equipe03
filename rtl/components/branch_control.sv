module branch_control (
    input  logic [2:0] funct3,
    input  logic       branch,
    input  logic       zero,
    input  logic       is_less,
    input  logic       is_less_u,
    output logic       pcsrc   
);

    import riscv_pkg::*;

    // SINAIS INTERNOS
    logic take_branch;



    always_comb begin
        if(!branch)
            take_branch = 1'b0;
        else begin 
            case(funct3)
            FUNCT3_BEQ: take_branch = zero;
            FUNCT3_BNE: take_branch = ~zero;

            FUNCT3_BLT: take_branch = is_less;
            FUNCT3_BGE: take_branch = ~is_less;

            FUNCT3_BLTU: take_branch = is_less_u;
            FUNCT3_BGEU: take_branch = ~is_less_u;

            default: take_branch = 1'b0;
            endcase
        end
    end 

    assign pcsrc = take_branch;
endmodule