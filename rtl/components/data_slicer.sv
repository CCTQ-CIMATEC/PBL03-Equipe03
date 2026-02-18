module data_slicer (
    input  logic [31:0] readdata,
    input  logic [2:0]  funct3,
    input  logic [1:0]  d_select,
    output logic [31:0] data
);

    import riscv_pkg::*;

    // CONTAINERS PARA AS PORCOES DE MEMORIAA
    logic [6:0]  byte_data;
    logic [15:0] half_data;

    // SELECIONA QUAL BYTE DEVE SER PEGO DE ACORDO COM OS 2 BITS MEMOS SIGNIFICATIVOS  DO ENDERECO CALCULADOS PELA ULA
    always_comb begin 
        case(d_select)
            2'b00: byte_data = readdata[7:0];
            2'b01: byte_data = readdata[15:8];
            2'b10: byte_data = readdata[23:16];
            2'b11: byte_data = readdata[31:24];
        endcase
    end

    // SELECIONA QUAL HALF WORD DEVE SER PEGO DE ACORDO COM O SEGUNDO BIT MEMOS SIGNIFICATIVOS  DO ENDERECO CALCULADOS PELA ULA
    always_comb begin 
        case(d_select[1])
            1'b0: half_data = readdata[15:0];
            1'b1: half_data = readdata[31:16];
        endcase
    end

    always_comb begin 
        case(funct3)
            FUNCT3_B:  data = {{24{byte_data[7]}}, byte_data};
            FUNCT3_BU: data = {24'b0, byte_data};
            FUNCT3_H:  data = {{16{half_data[15]}}, half_data};
            FUNCT3_HU: data = {16'b0, half_data};
            FUNCT3_W:  data = readdata;
            default:   data = readdata;
        endcase
    end

endmodule