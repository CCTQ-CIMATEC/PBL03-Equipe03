
addi x1, x0, 15         # 0x0000000f
addi x2, x0, -1         # 0xffffffff
addi x3, x1, 0
slli x3, x3, 4          # 0x000000f0

xori x4, x2, 15         # 0xfffffff0

and  x5, x3, x4         # 0x000000f0
or   x6, x1, x3         # 0x000000ff
xor  x7, x6, x4         # 0xffffff0f

andi x8, x6, 15         # 0x0000000f
ori  x9, x1, 16         # 0x0000001f

xor  x0, x6, x1         # tentativa de escrita em x0 com R-type da fase 2