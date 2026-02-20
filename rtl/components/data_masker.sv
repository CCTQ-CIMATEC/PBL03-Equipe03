module data_masker (
    input  logic [31:0] writedata_in,
    input  logic [2:0]  funct3,
    input  logic [1:0]  d_select,
    input  logic        we,

    output logic [31:0] writedata_out,
    output logic [3:0]  write_enable
);
    import riscv_pkg::*;

    // REPLICAÇÂO DOS DADOS DE ACORDO COM A INSTRUCAO
    always_comb begin 
        case(funct3)
        FUNCT3_SB: writedata_out = {4{writedata_in[ 7:0]}};
        FUNCT3_SH: writedata_out = {2{writedata_in[15:0]}};
        FUNCT3_SW: writedata_out = writedata_in;
        default:   writedata_out = writedata_in;
        endcase
    end

    // FORMATAÇÂO
    always_comb begin 
        if(!we)
            write_enable = 4'b0000;
        else begin 
            case(funct3) 

                // STORE BYTE
                FUNCT3_SB: begin 
                    case(d_select)
                        2'b00: write_enable = 4'b0001;
                        2'b01: write_enable = 4'b0010;
                        2'b10: write_enable = 4'b0100;
                        2'b11: write_enable = 4'b1000;
                    endcase
                end
                
                // STORE HALF-WORD
                FUNCT3_SH: begin 
                    case(d_select[1])
                        1'b0:  write_enable = 4'b0011;
                        1'b1:  write_enable = 4'b1100;
                    endcase
                end

                // STORE WORD
                FUNCT3_SW: begin 
                    write_enable = 4'b1111;
                end

                default: write_enable = 4'b0000;

            endcase
        end
    end
endmodule 