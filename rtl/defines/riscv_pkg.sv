package  riscv_pkg;

    // RISC-V OPCODE    
    typedef enum logic [6:0] {
        OP_R_TYPE = 7'b0110011,
        OP_I_TYPE = 7'b0010011,
        OP_STORE  = 7'b0100011,
        OP_LOAD   = 7'b0000011,
        OP_BRANCH = 7'b1100011,
        OP_JAL    = 7'b1101111,
        OP_JALR   = 7'b1100111,
        OP_LUI    = 7'b0110111,
        OP_AUI    = 7'b0010111
    } opcode_t;

    // FUNCT3 CODES

    // Load instructions (I-Type)
    localparam FUNCT3_B  = 3'b000;  // load byte
    localparam FUNCT3_H  = 3'b001;  // load halfword
    localparam FUNCT3_W  = 3'b010;  // load word
    localparam FUNCT3_BU = 3'b100;  // load byte unsigned 
    localparam FUNCT3_HU = 3'b101;  // load halfword unsigned

    // Logic and arithmetic instructions (R-Type, I-Type)
    localparam FUNCT3_ADD_SUB = 3'b000;  // add, sub, addi, 
    localparam FUNCT3_SLL     = 3'b001;  // sll, slli
    localparam FUNCT3_SLT     = 3'b010;  // slt, slti
    localparam FUNCT3_SLTU    = 3'b011;  // sltun sltui
    localparam FUNCT3_XOR     = 3'b100;  // xor, xori
    localparam FUNCT3_SRL_SRA = 3'b101;  // srl, sra, srli, srla
    localparam FUNCT3_OR      = 3'b110;  // or, ori
    localparam FUNCT3_AND     = 3'b111;  // and, andi

    // Branch instructions (B-Typee)
    localparam FUNCT3_BEQ     = 3'b000;  // beq
    localparam FUNCT3_BNE     = 3'b001;  // bne
    localparam FUNCT3_BLT     = 3'b100;  // blt
    localparam FUNCT3_BGE     = 3'b101;  // bge
    localparam FUNCT3_BLTU    = 3'b110;  // bltu
    localparam FUNCT3_BGEU    = 3'b111;  // bgeu 
    
    // Store instructions (S-Type)
    localparam FUNCT3_SB      = 3'b000;  // sb
    localparam FUNCT3_SH      = 3'b001;  // sh
    localparam FUNCT3_SW      = 3'b010;  // sw

    // FUNCT7 CODES

    localparam FUNCT7_ADD     = 7'b0000000; // add, srli
    localparam FUNCT7_SUB     = 7'b0100000; // sub, srai

    // ALU OPERATIONS

    typedef enum logic [3:0]{
        ALU_ADD = 4'b0000,
        ALU_SUB = 4'b0001,
        ALU_AND = 4'b0010,
        ALU_OR  = 4'b0011,
        ALU_XOR = 4'b0100,
        ALU_SLT = 4'b0101
        //ALU_SLL = 4'b0101;
        //ALU_SRL = 4'b0110;
        //ALU_SRA = 4'b0111;
    } alu_ops_t;

endpackage