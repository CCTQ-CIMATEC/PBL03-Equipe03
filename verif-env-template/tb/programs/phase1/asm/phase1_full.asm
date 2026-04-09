# Fase 1 completa
# Cobre:
# - addi positivo
# - addi com rs1 = x0 e imediato negativo
# - add
# - sub
# - escrita e leitura de registradores
# - tentativa de escrita em x0 com ADDI
# - tentativa de escrita em x0 com ADD / SUB
# - resultado positivo
# - resultado zero
# - resultado negativo

# ------------------------------------------------------------
# Inicialização básica
# ------------------------------------------------------------
addi x1, x0, 5          # x1 = 5
addi x2, x0, 7          # x2 = 7

# ------------------------------------------------------------
# Operações aritméticas básicas
# ------------------------------------------------------------
add  x3, x1, x2         # x3 = 12
sub  x4, x2, x1         # x4 = 2

# ------------------------------------------------------------
# ADDI com imediato negativo
# ------------------------------------------------------------
addi x5, x0, -1         # x5 = -1

# ------------------------------------------------------------
# Tentativas de escrita em x0
# ------------------------------------------------------------
add  x0, x1, x2         # x0 deve continuar 0
sub  x0, x2, x1         # x0 deve continuar 0
addi x0, x1, 9          # x0 deve continuar 0

# ------------------------------------------------------------
# Casos de resultado zero, positivo e negativo
# ------------------------------------------------------------
sub  x6, x1, x1         # x6 = 0
add  x7, x5, x1         # x7 = 4
sub  x8, x5, x2         # x8 = -8
addi x9, x0, 0          # x9 = 0