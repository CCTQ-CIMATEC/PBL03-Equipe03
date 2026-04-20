# Fase 4 - branches básico
# Cobre:
# - beq / bne / blt / bge / bltu / bgeu
# - branch taken
# - branch not taken
# - offset positivo

    addi x1,  x0, 5       # x1 = 5
    addi x2,  x0, 5       # x2 = 5
    addi x3,  x0, 1       # x3 = 1

    beq  x1,  x2, beq_ok  # taken
    addi x10, x0, 99      # nao deve executar

beq_ok:
    bne  x1,  x2, after_bne # not taken
    addi x4,  x0, 11       # executa

after_bne:
    blt  x3,  x1, blt_ok   # taken
    addi x11, x0, 88      # nao deve executar

blt_ok:
    bge  x1,  x2, bge_ok  # taken
    addi x12, x0, 77      # nao deve executar

bge_ok:
    bltu x3,  x1, bltu_ok # taken
    addi x13, x0, 66      # nao deve executar

bltu_ok:
    bgeu x1,  x3, bgeu_ok # taken
    addi x14, x0, 55      # nao deve executar

bgeu_ok:
    addi x5,  x0, 22      # fim visivel do fluxo
