# Fase 4 - jumps básico
# Cobre:
# - jal
# - jalr
# - escrita em link register
# - jump com rd = x0
# - offset positivo

    addi x1, x0, 0          # x1 = 0

    jal  x5, jump_target    # x5 = PC + 4
    addi x10, x0, 99        # nao deve executar

jump_target:
    addi x1, x1, 1          # x1 = 1
    addi x6, x0, 28         # endereco de jalr_target

    jalr x7, x6, 0          # x7 = PC + 4, salto para 28
    addi x11, x0, 88        # nao deve executar

jalr_target:
    addi x2, x0, 2          # x2 = 2

    jal  x0, jump_no_link   # salto sem link
    addi x12, x0, 77        # nao deve executar

jump_no_link:
    addi x3, x0, 3          # x3 = 3