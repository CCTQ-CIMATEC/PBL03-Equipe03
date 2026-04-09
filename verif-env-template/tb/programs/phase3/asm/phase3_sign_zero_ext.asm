# Fase 3 - sign/zero extension
# Cobre:
# - sb
# - sh
# - lbu / lb
# - lhu / lh
# - extensão por zero
# - extensão com sinal

    addi x1, x0, 64      # base = 64

    addi x2, x0, -1      # x2 = 0xFFFF_FFFF
    sb   x2, 0(x1)       # mem[64] = 0xFF
    lbu  x3, 0(x1)       # x3 = 0x000000FF
    lb   x4, 0(x1)       # x4 = 0xFFFFFFFF

    addi x5, x0, -16     # x5 = 0xFFFF_FFF0
    sh   x5, 4(x1)       # mem[68..69] = 0xFFF0
    lhu  x6, 4(x1)       # x6 = 0x0000FFF0
    lh   x7, 4(x1)       # x7 = 0xFFFFFFF0