
addi x1, x0, 1
addi x2, x0, -1
addi x3, x0, 31

slli x4, x1, 0          # shamt = 0
slli x5, x1, 31         # 0x80000000
srli x6, x5, 31         # 1
srai x7, x5, 31         # 0xffffffff

sll  x8,  x1, x3        # shift por registrador = 31
srl  x9,  x5, x3        # 1
sra  x10, x5, x3        # 0xffffffff

srai x0, x2, 31         # tentativa de escrita em x0