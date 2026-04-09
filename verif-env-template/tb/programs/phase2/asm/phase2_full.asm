# Fase 2 completa
# Cobre:
# - base da Fase 1
# - andi / ori / xori
# - and / or / xor
# - slli / srli / srai
# - sll / srl / sra
# - imediato zero
# - imediato positivo
# - imediato negativo
# - shamt zero
# - shamt não zero
# - shamt alto
# - tentativa de escrita em x0 com instruções I-type e R-type

# ------------------------------------------------------------
# Base da Fase 1
# ------------------------------------------------------------
addi x1,  x0, 15        # x1 = 15
addi x2,  x0, -8        # x2 = -8
addi x3,  x0, 3         # x3 = 3

addi x0,  x1, 7         # x0 deve continuar 0
add  x4,  x1, x3        # x4 = 18
sub  x5,  x3, x1        # x5 = -12
add  x0,  x1, x3        # x0 deve continuar 0

# ------------------------------------------------------------
# Operações lógicas I-type
# ------------------------------------------------------------
andi x6,  x1, 0         # x6 = 0
andi x7,  x1, 6         # x7 = 6
ori  x8,  x6, -1        # x8 = 0xFFFF_FFFF
xori x9,  x1, -1        # x9 = ~15

# ------------------------------------------------------------
# Operações lógicas R-type
# ------------------------------------------------------------
and  x10, x1, x3        # x10 = 3
or   x11, x6, x3        # x11 = 3
xor  x12, x1, x3        # x12 = 12

# ------------------------------------------------------------
# Shifts I-type
# ------------------------------------------------------------
slli x13, x3, 0         # x13 = 3
slli x14, x3, 4         # x14 = 48
srli x15, x14, 1        # x15 = 24
srai x16, x2, 2         # x16 = -2
slli x17, x3, 16        # x17 = 0x0003_0000

# ------------------------------------------------------------
# Shifts R-type
# ------------------------------------------------------------
sll  x18, x3, x1        # x18 = 3 << 15
srl  x19, x14, x3       # x19 = 6
sra  x20, x2, x3        # x20 = -1
