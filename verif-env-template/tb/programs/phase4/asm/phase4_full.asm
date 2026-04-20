# Fase 4 completa
# Cobre:
# - beq / bne / blt / bge / bltu / bgeu
# - jal / jalr
# - branch taken e not taken
# - offset positivo e negativo
# - jump forward e backward
# - escrita em link register
# - jump com rd = x0
# - comparacao signed e unsigned

    addi x1,  x0, 2          # limite do loop = 2
    addi x2,  x0, 0          # contador = 0
    addi x3,  x0, -1         # valor negativo
    addi x17, x0, 1          # flag para o backward jalr

    beq  x2,  x3, beq_taken  # not taken
    bne  x2,  x3, bne_taken  # taken
    addi x10, x0, 111        # nao deve executar

bne_taken:
    blt  x3,  x2, blt_taken  # taken  (-1 < 0)
    addi x11, x0, 112        # nao deve executar

blt_taken:
    bge  x2,  x3, bge_taken  # taken  (0 >= -1)
    addi x12, x0, 113        # nao deve executar

bge_taken:
    bltu x2,  x1, bltu_taken # taken  (0 < 2)
    addi x13, x0, 114        # nao deve executar

bltu_taken:
    bgeu x1,  x2, bgeu_taken # taken  (2 >= 0)
    addi x14, x0, 115        # nao deve executar

bgeu_taken:
    jal  x6, jal_forward     # link em x6
    addi x15, x0, 116        # nao deve executar

jal_forward:
    addi x7,  x0, 92         # endereco do alvo do jalr forward
    jalr x8,  0(x7)          # link em x8, salto para 92
    addi x16, x0, 117        # nao deve executar
    addi x18, x0, 118        # nao deve executar
    addi x19, x0, 119        # nao deve executar
    addi x20, x0, 120        # nao deve executar

jalr_forward_target:
    addi x9,  x0, 9          # ponto visivel apos jalr
    addi x2,  x2, 1          # contador++
    bne  x2,  x1, jalr_forward_target  # backward: taken na 1a vez, not taken na 2a

    beq  x17, x0, after_backward_jalr  # 1a vez: not taken | 2a vez: taken
    addi x17, x17, -1        # flag -> 0
    addi x5,  x0, 104        # endereco do branch de saida
    jalr x0,  0(x5)          # backward jalr sem link
    addi x21, x0, 121        # nao deve executar

beq_taken:
    addi x22, x0, 222        # rotulo nao usado neste teste

after_backward_jalr:
    addi x23, x0, 1          # habilita o backward jal uma unica vez

backward_jal_target:
    beq  x23, x0, done       # 1a vez: not taken | 2a vez: taken
    addi x23, x0, 0          # flag -> 0
    jal  x24, backward_jal_target   # backward jal com offset negativo e link

done:
    addi x22, x0, 22         # fim visivel do fluxo