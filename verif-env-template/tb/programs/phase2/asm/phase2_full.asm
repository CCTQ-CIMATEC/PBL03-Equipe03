# Fase 2 completa
# Cobre:
# addi: sim
# add: sim
# sub: sim
# escrita em x0: sim, I-type e R-type
# andi, ori, xori: sim
# and, or, xor: sim
# slli, srli, srai: sim
# sll, srl, sra: sim
# imediato zero: sim
# imediato positivo: sim
# imediato negativo: sim
# shamt = 0: sim
# shamt > 0: sim
# shamt alto: sim

    # ------------------------------------------------------------
    # Base da Fase 1
    # ------------------------------------------------------------
    addi x1,  x0,  15      # x1  = 15
    addi x2,  x0,  -8      # x2  = -8
    addi x3,  x0,  3       # x3  = 3

    addi x0,  x1,  7       # tentativa de escrita em x0
    add  x4,  x1,  x3      # x4  = 18
    sub  x5,  x3,  x1      # x5  = -12
    add  x0,  x1,  x3      # tentativa de escrita em x0 (R-type)

    # ------------------------------------------------------------
    # Lógica I-type
    # ------------------------------------------------------------
    andi x6,  x1,  0       # imm zero   -> x6  = 0
    andi x7,  x1,  6       # imm positivo -> x7 = 15 & 6 = 6
    ori  x8,  x6,  -1      # imm negativo -> x8 = 0xFFFF_FFFF
    xori x9,  x1,  -1      # imm negativo -> x9 = ~15

    # ------------------------------------------------------------
    # Lógica R-type
    # ------------------------------------------------------------
    and  x10, x1,  x3      # x10 = 15 & 3 = 3
    or   x11, x6,  x3      # x11 = 0 | 3 = 3
    xor  x12, x1,  x3      # x12 = 15 ^ 3 = 12

    # ------------------------------------------------------------
    # Shift I-type
    # ------------------------------------------------------------
    slli x13, x3,  0       # shamt zero   -> x13 = 3
    slli x14, x3,  4       # shamt não zero -> x14 = 48
    srli x15, x14, 1       # x15 = 24
    srai x16, x2,  2       # x16 = -2
    slli x17, x3,  16      # shamt alto -> x17 = 0x0003_0000

    # ------------------------------------------------------------
    # Shift R-type
    # ------------------------------------------------------------
    sll  x18, x3,  x1      # x18 = 3 << 15
    srl  x19, x14, x3      # x19 = 48 >> 3 = 6
    sra  x20, x2,  x3      # x20 = -8 >>> 3 = -1