# Fase 5 completa
# Cobre:
# - forwarding M->E em srcA
# - forwarding M->E em srcB
# - forwarding W->E em srcA
# - forwarding W->E em srcB
# - load-use stall
# - flush por branch taken
# - flush por jal

addi x1,  x0, 10
addi x2,  x0, 3

# ------------------------------------------------------------
# FORWARDING M -> E (srcA)
# ------------------------------------------------------------
add  x3,  x1, x2       # x3 = 13
sub  x4,  x3, x2       # usa x3 imediatamente em rs1

# ------------------------------------------------------------
# FORWARDING M -> E (srcB)
# ------------------------------------------------------------
add  x5,  x1, x2       # x5 = 13
sub  x6,  x2, x5       # usa x5 imediatamente em rs2

# ------------------------------------------------------------
# FORWARDING W -> E (srcA)
# ------------------------------------------------------------
add  x7,  x1, x2       # x7 = 13
addi x0,  x0, 0        # nop
sub  x8,  x7, x2       # usa x7 quando produtor está em W

# ------------------------------------------------------------
# FORWARDING W -> E (srcB)
# ------------------------------------------------------------
add  x9,  x1, x2       # x9 = 13
addi x0,  x0, 0        # nop
sub  x10, x2, x9       # usa x9 quando produtor está em W

# ------------------------------------------------------------
# LOAD-USE STALL
# ------------------------------------------------------------
addi x11, x0, 256       # base = 256
addi x12, x0, 9        # dado = 9
sw   x12, 0(x11)       # mem[64] = 9
lw   x13, 0(x11)       # x13 = 9
add  x14, x13, x12     # dependência imediata do load

# ------------------------------------------------------------
# FLUSH POR BRANCH TAKEN
# ------------------------------------------------------------
addi x15, x0, 1
addi x16, x0, 1
beq  x15, x16, branch_ok
addi x17, x0, 99       # deve ser flushado
branch_ok:
addi x17, x0, 42

# ------------------------------------------------------------
# FLUSH POR JAL
# ------------------------------------------------------------
jal  x18, jal_ok
addi x19, x0, 77       # deve ser flushado
jal_ok:
addi x19, x0, 33