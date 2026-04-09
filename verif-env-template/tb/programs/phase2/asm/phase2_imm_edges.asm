# Fase 2 - imediatos extremos
# Cobre:
# - addi com limite positivo de 12 bits
# - addi com limite negativo de 12 bits
# - andi com imediato positivo
# - xori com imediato negativo
# - ori com imediato negativo
# - andi com imediato -1
# - tentativa de escrita em x0 com ADDI
# - tentativa de escrita em x0 com ORI

# ------------------------------------------------------------
# Limites de imediato em 12 bits
# ------------------------------------------------------------
addi x1, x0, 2047       # máximo positivo de 12 bits
addi x2, x0, -2048      # mínimo negativo de 12 bits

# ------------------------------------------------------------
# Lógicas com imediatos extremos
# ------------------------------------------------------------
andi x3, x1, 2047       # mantém os bits válidos
xori x4, x1, -1         # inverte os bits de x1
ori  x5, x0, -2048      # carrega imediato negativo
andi x6, x2, -1         # preserva x2

# ------------------------------------------------------------
# Tentativas de escrita em x0
# ------------------------------------------------------------
addi x0, x1, -1         # x0 deve continuar 0
ori  x0, x0, 2047       # x0 deve continuar 0
