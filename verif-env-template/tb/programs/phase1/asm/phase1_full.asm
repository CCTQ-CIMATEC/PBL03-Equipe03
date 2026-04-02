# Fase 1 completa
# Cobre:
# - addi positivo
# - addi com rs1=x0 e imediato negativo
# - add
# - sub
# - escrita/leitura de registradores
# - tentativa de escrita em x0 com ADDI
# - tentativa de escrita em x0 com ADD/SUB
# - resultados positivo, zero e negativo

addi x1, x0, 5      # x1 = 5
addi x2, x0, 7      # x2 = 7

add  x3, x1, x2     # x3 = 12   -> leitura de x1/x2, escrita em x3
sub  x4, x2, x1     # x4 = 2    -> leitura de x2/x1, escrita em x4

addi x5, x0, -1     # x5 = -1   -> addi com zero e imediato negativo

add  x0, x1, x2     # tentativa de escrita em x0 com ADD  -> x0 deve continuar 0
sub  x0, x2, x1     # tentativa de escrita em x0 com SUB  -> x0 deve continuar 0
addi x0, x1, 9      # tentativa de escrita em x0 com ADDI -> x0 deve continuar 0

sub  x6, x1, x1     # x6 = 0    -> resultado zero
add  x7, x5, x1     # x7 = 4    -> resultado positivo com operando negativo
sub  x8, x5, x2     # x8 = -8   -> resultado negativo
addi x9, x0, 0      # x9 = 0    -> valor zero via addi