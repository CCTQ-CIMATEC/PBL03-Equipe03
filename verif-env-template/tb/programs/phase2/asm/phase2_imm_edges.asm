addi x1, x0,  2047      # max positivo de 12 bits
addi x2, x0, -2048      # min negativo de 12 bits

andi x3, x1,  2047
xori x4, x1, -1
ori  x5, x0, -2048
andi x6, x2, -1

addi x0, x1, -1         # tentativa de escrita em x0
ori  x0, x0, 2047       # tentativa de escrita em x0 com instrucao da fase 2