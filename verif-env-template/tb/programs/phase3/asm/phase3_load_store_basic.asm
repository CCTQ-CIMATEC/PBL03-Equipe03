# Fase 3 - load/store básico
# Cobre:
# - sw
# - lw
# - offset zero
# - offset positivo
# - offset negativo via base ajustada

    addi x1, x0, 64      # base = 64
    addi x2, x0, 18      # dado = 18

    sw   x2, 0(x1)       # mem[64]  = 18
    lw   x3, 0(x1)       # x3 = 18

    sw   x2, 12(x1)      # mem[76]  = 18
    lw   x4, 12(x1)      # x4 = 18

    addi x5, x1, -4      # x5 = 60
    sw   x2, 4(x5)       # mem[64]  = 18
    lw   x6, 4(x5)       # x6 = 18