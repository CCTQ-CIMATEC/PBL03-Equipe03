# Comandos para rodar os testes da Fase 4

## 1. Teste `phase4_branch_basic.mem`

### Configuração
```bash
./configure \
  --top rv32i_tb \
  --test rv32i_phase4_test \
  --vivado "--R --testplusarg PROG=../tb/programs/phase4/mem/phase4_branch_basic.mem --testplusarg MAX_INSTR=11 --testplusarg START_PC=0x00000000"
```

---

## 2. Teste `phase4_jump_basic.mem`

### Configuração
```bash
./configure \
  --top rv32i_tb \
  --test rv32i_phase4_test \
  --vivado "--R --testplusarg PROG=../tb/programs/phase4/mem/phase4_jump_basic.mem --testplusarg MAX_INSTR=8 --testplusarg START_PC=0x00000000"
```
---

## 3. Teste `phase4_full.mem`

### Configuração
```bash
./configure \
  --top rv32i_tb \
  --test rv32i_phase4_test \
  --vivado "--R --testplusarg PROG=../tb/programs/phase4/mem/phase4_full.mem --testplusarg MAX_INSTR=30 --testplusarg START_PC=0x00000000"
```

---

## 4. Teste `phase4_regression_all.mem`

### Configuração
```bash
./configure \
  --top rv32i_tb \
  --test rv32i_phase4_test \
  --vivado "--R --testplusarg PROG=../tb/programs/phase4/mem/phase4_regression_all.mem --testplusarg MAX_INSTR=76 --testplusarg START_PC=0x00000000"
```

---

## 5. Próximos passos

### Compilação
```bash
make compile
```

### Elaboração
```bash
make elaborate
```

### Simulação
```bash
make sim
```

---

## Ordem recomendada de execução

1. `phase4_branch_basic.mem`
2. `phase4_jump_basic.mem`
3. `phase4_full.mem`

---

## Observação

Os valores de `MAX_INSTR` usados foram:

- `phase4_branch_basic.mem` → `11`
- `phase4_jump_basic.mem` → `8`
- `phase4_full.mem` → `25`
- `phase4_regression_all.mem` → `64`

Eles correspondem à quantidade de eventos arquiteturais esperados em cada programa.
