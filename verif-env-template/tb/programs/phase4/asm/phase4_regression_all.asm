# Regressao fases 1 a 4
# Cobre:
# - Fase 1: addi, add, sub, x0, resultados pos/zero/neg
# - Fase 2: andi/ori/xori, and/or/xor, slli/srli/srai, sll/srl/sra
# - Fase 3: lb/lh/lw/lbu/lhu, sb/sh/sw, sign/zero extension, offsets 0/+/-
# - Fase 4: beq/bne/blt/bge/bltu/bgeu, jal/jalr, taken/not taken, offsets +/-, link, rd=x0

    ############################################################
    # FASE 1 - ARITMETICA BASICA
    ############################################################
    addi x1,  x0, 5          # positivo
    addi x2,  x0, -3         # negativo

    add  x3,  x1, x2         # 5 + (-3) = 2   (ADD, resultado positivo)
    sub  x4,  x1, x1         # 5 - 5 = 0      (SUB, resultado zero)
    sub  x5,  x2, x1         # -3 - 5 = -8    (resultado negativo)

    addi x0,  x1, 7          # tentativa de escrita em x0 com ADDI
    add  x0,  x1, x2         # tentativa de escrita em x0 com R-type

    ############################################################
    # FASE 2 - LOGICA E SHIFTS
    ############################################################
    andi x6,  x1, 0          # imm zero
    ori  x7,  x0, 15         # imm positivo
    xori x8,  x7, -1         # imm negativo

    and  x9,  x7, x8
    or   x10, x7, x1
    xor  x11, x7, x1

    slli x12, x1, 0          # shamt zero
    slli x13, x1, 4          # shamt nao-zero
    srli x14, x13, 4
    srai x15, x2, 1

    addi x16, x0, 31
    slli x17, x1, 31         # shamt grande

    sll  x18, x1, x1
    srl  x19, x17, x1
    sra  x20, x2, x1

   ############################################################
    # FASE 3 - LOAD / STORE
    ############################################################
    addi x21, x0, 512        # base = 0x200
    addi x22, x0, 18         # dado positivo

    sw   x22, 0(x21)         # store offset 0
    lw   x23, 0(x21)         # load offset 0, resultado positivo

    addi x24, x0, -1
    sb   x24, 4(x21)         # store offset positivo
    lb   x25, 4(x21)         # sign extension byte, resultado negativo
    lbu  x26, 4(x21)         # zero extension byte, resultado positivo

    addi x27, x0, -2
    sh   x27, 8(x21)         # store offset positivo
    lh   x28, 8(x21)         # sign extension halfword, resultado negativo
    lhu  x29, 8(x21)         # zero extension halfword, resultado positivo

    sw   x0, 12(x21)
    lw   x30, 12(x21)        # resultado zero

    addi x31, x21, 16
    addi x22, x0, 7
    sw   x22, -4(x31)        # store offset negativo
    lw   x23, -4(x31)        # load offset negativo, resultado positivo

    ############################################################
    # FASE 4 - BRANCHES E JUMPS
    ############################################################
    addi x1,  x0, 2          # limite do loop = 2
    addi x2,  x0, 0          # contador = 0
    addi x3,  x0, -1         # valor negativo
    addi x17, x0, 1          # flag

    beq  x2,  x3, beq_taken  # not taken
    bne  x2,  x3, bne_taken  # taken
    addi x10, x0, 111        # nao deve executar

bne_taken:
    blt  x3,  x2, blt_taken  # taken
    addi x11, x0, 112        # nao deve executar

blt_taken:
    bge  x2,  x3, bge_taken  # taken
    addi x12, x0, 113        # nao deve executar

bge_taken:
    bltu x2,  x1, bltu_taken # taken
    addi x13, x0, 114        # nao deve executar

bltu_taken:
    bgeu x1,  x2, bgeu_taken # taken
    addi x14, x0, 115        # nao deve executar

bgeu_taken:
    jal  x6, jal_forward     # jump forward com link
    addi x15, x0, 116        # nao deve executar

jal_forward:
    addi x7,  x6, 24         # endereco relativo do alvo do jalr
    jalr x8,  x7, 0          # jump forward com link
    addi x16, x0, 117        # nao deve executar
    addi x18, x0, 118        # nao deve executar
    addi x19, x0, 119        # nao deve executar

jalr_forward_target:
    addi x9,  x0, 9
    addi x2,  x2, 1
    bne  x2,  x1, jalr_forward_target  # branch backward: taken e depois not taken

    beq  x17, x0, no_link_target        # 1a vez: not taken
    addi x17, x17, -1
    jal  x0, no_link_target            # jump com rd = x0
    addi x20, x0, 120                  # nao deve executar

no_link_target:
    addi x23, x0, 1

backward_jal_target:
    beq  x23, x0, after_backward_jal   # 1a vez: not taken | 2a vez: taken
    addi x23, x0, 0
    jal  x24, backward_jal_target      # jump backward com offset negativo
    addi x21, x0, 121                  # nao deve executar

beq_taken:
    addi x25, x0, 222                  # rotulo nao esperado neste teste

after_backward_jal:
    addi x22, x0, 22                   # fim visivel