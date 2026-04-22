# Fase 5 - regressão completa
# Cobre cumulativamente:
# - Fase 1: reset/PC/register file/addi/add/sub/x0
# - Fase 2: lógica, shifts, imediato e decode
# - Fase 3: load/store, sign/zero extension e offsets 0/+/-
# - Fase 4: branches e jumps
# - Fase 5: forwarding, stall e flush
#
# Observação:
# - usa base de dados em 0x200 para evitar colisão com a memória de programa
#   em simulações no Ripes

    # ------------------------------------------------------------
    # Base de dados
    # ------------------------------------------------------------
    addi x20, x0, 512      # x20 = 0x200

    # ------------------------------------------------------------
    # Fase 1
    # ------------------------------------------------------------
    addi x1,  x0, 5        # addi positivo
    addi x2,  x0, 7
    add  x3,  x1, x2       # add
    sub  x4,  x2, x1       # sub
    addi x5,  x0, -1       # addi negativo

    add  x0,  x1, x2       # tentativa de escrita em x0 (R-type)
    sub  x0,  x2, x1       # tentativa de escrita em x0 (R-type)
    addi x0,  x1, 9        # tentativa de escrita em x0 (I-type)

    sub  x6,  x1, x1       # resultado zero
    add  x7,  x5, x1       # resultado positivo
    sub  x8,  x5, x2       # resultado negativo
    addi x9,  x0, 0

    # ------------------------------------------------------------
    # Fase 2 - lógica e shifts
    # ------------------------------------------------------------
    andi x10, x3, 0        # imm zero
    andi x11, x3, 6        # imm positivo
    ori  x12, x10, -1      # imm negativo
    xori x13, x3, -1       # imm negativo
    slti x14, x9, 1        # signed compare imediato
    sltiu x15, x5, 1       # unsigned compare imediato

    and  x14, x1, x2
    or   x15, x10, x1
    xor  x16, x1, x2
    slt  x17, x5, x1       # signed compare registrador
    sltu x18, x5, x1       # unsigned compare registrador

    slli x17, x1, 0        # shamt zero
    slli x18, x1, 4        # shamt não zero
    srli x19, x18, 1
    srai x21, x5, 2
    slli x22, x1, 16       # shamt alto

    sll  x23, x1, x1
    srl  x24, x18, x1
    sra  x25, x5, x1

    # ------------------------------------------------------------
    # Fase 3 - load/store + extensões
    # ------------------------------------------------------------
    addi x26, x0, -1
    lui  x27, 0x8
    addi x27, x27, 1       # x27 = 0x00008001
    addi x28, x0, 18

    sw   x28, 0(x20)       # store offset 0
    lw   x29, 0(x20)       # load offset 0 / resultado positivo

    sw   x0, 12(x20)       # store offset positivo
    lw   x30, 12(x20)      # load offset positivo / resultado zero

    addi x31, x20, 4
    sw   x28, -4(x31)      # store offset negativo
    lw   x1,  -4(x31)      # load offset negativo

    sb   x26, 16(x20)      # byte = 0xFF
    lb   x2,  16(x20)      # sign extension byte -> negativo
    lbu  x3,  16(x20)      # zero extension byte -> positivo

    sh   x27, 20(x20)      # halfword = 0x8001
    lh   x4,  20(x20)      # sign extension halfword -> negativo
    lhu  x5,  20(x20)      # zero extension halfword -> positivo

    # ------------------------------------------------------------
    # Fase 4 - branches e jumps
    # ------------------------------------------------------------
    addi x6,  x0, 1
    addi x7,  x0, 1

    beq  x6,  x7, beq_taken_pos
    addi x8,  x0, 99       # flushado
beq_taken_pos:
    addi x8,  x0, 42

    bne  x6,  x7, bne_not_taken_label
    addi x9,  x0, 9
bne_not_taken_label:

    addi x10, x0, -1
    addi x11, x0, 1

    blt  x10, x11, blt_taken_pos
    addi x12, x0, 99       # flushado
blt_taken_pos:
    addi x12, x0, 12

    bge  x10, x11, bge_not_taken_label
    addi x13, x0, 13
bge_not_taken_label:

    bltu x11, x10, bltu_taken_pos
    addi x14, x0, 99       # flushado
bltu_taken_pos:
    addi x14, x0, 14

    bgeu x11, x10, bgeu_not_taken_label
    addi x15, x0, 15
bgeu_not_taken_label:

    # branch com offset negativo
    addi x16, x0, 2
bne_neg_loop:
    addi x16, x16, -1
    bne  x16, x0, bne_neg_loop

    # jump com offset positivo + link register
    jal  x17, jal_pos_target
    addi x18, x0, 99       # flushado
jal_pos_target:
    addi x18, x0, 18

    # jump com rd=x0 e offset negativo
    addi x19, x0, 0
    jal  x0,  jal_neg_prepare
jal_neg_target:
    addi x19, x19, 1
jal_neg_prepare:
    beq  x19, x0, do_backward_jal
    jal  x0,  after_backward_jal
do_backward_jal:
    jal  x0,  jal_neg_target
after_backward_jal:

    # auipc
    auipc x21, 0           # captura PC atual

    # jalr com link register
    jal  x21, jalr_setup
    addi x23, x0, 99       # flushado
jalr_setup:
    addi x21, x21, 16      # endereco de jalr_target
    jalr x22, x21, 0
    addi x23, x0, 99       # flushado
jalr_target:
    addi x23, x0, 23

    # ------------------------------------------------------------
    # Fase 5 - hazards
    # ------------------------------------------------------------
    addi x1,  x0, 10
    addi x2,  x0, 3

    # forwarding M -> E (srcA)
    add  x3,  x1, x2
    sub  x4,  x3, x2

    # forwarding M -> E (srcB)
    add  x5,  x1, x2
    sub  x6,  x2, x5

    # forwarding W -> E (srcA)
    add  x7,  x1, x2
    addi x0,  x0, 0
    sub  x8,  x7, x2

    # forwarding W -> E (srcB)
    add  x9,  x1, x2
    addi x0,  x0, 0
    sub  x10, x2, x9

    # load-use stall
    addi x11, x0, 9
    sw   x11, 32(x20)
    lw   x12, 32(x20)
    add  x13, x12, x11