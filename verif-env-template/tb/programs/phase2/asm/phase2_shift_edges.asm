# Fase 2 - extremos de shift
# Cobre:
# - shift imediato com shamt = 0
# - shift imediato com shamt = 31
# - shift lógico à direita
# - shift aritmético à direita
# - shift por registrador com valor alto
# - tentativa de escrita em x0 com SRAI

# ------------------------------------------------------------
# Inicialização
# ------------------------------------------------------------
addi x1, x0, 1          # x1 = 1
addi x2, x0, -1         # x2 = 0xFFFFFFFF
addi x3, x0, 31         # x3 = 31

# ------------------------------------------------------------
# Shifts I-type
# ------------------------------------------------------------
slli x4, x1, 0          # x4 = 1
slli x5, x1, 31         # x5 = 0x80000000
srli x6, x5, 31         # x6 = 1
srai x7, x5, 31         # x7 = 0xFFFFFFFF

# ------------------------------------------------------------
# Shifts R-type
# ------------------------------------------------------------
sll  x8,  x1, x3        # x8 = 1 << 31
srl  x9,  x5, x3        # x9 = 1
sra  x10, x5, x3        # x10 = 0xFFFFFFFF

# ------------------------------------------------------------
# Tentativa de escrita em x0
# ------------------------------------------------------------
srai x0, x2, 31         # x0 deve continuar 0
