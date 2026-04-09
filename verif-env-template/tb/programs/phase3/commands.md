# Comandos para rodar os testes da Fase 3

## 1. Teste `phase3_load_store_basic.mem`

### Configuração
```bash
./configure \
  --top rv32i_tb \
  --test rv32i_phase3_test \
  --vivado "--R --testplusarg PROG=../tb/programs/phase3/mem/phase3_load_store_basic.mem --testplusarg MAX_INSTR=9 --testplusarg START_PC=0x00000000"
```

---

## 2. Teste `phase3_sign_zero_ext.mem`

### Configuração
```bash
./configure \
  --top rv32i_tb \
  --test rv32i_phase3_test \
  --vivado "--R --testplusarg PROG=../tb/programs/phase3/mem/phase3_sign_zero_ext.mem --testplusarg MAX_INSTR=9 --testplusarg START_PC=0x00000000"
```

---

## 3. Teste `phase3_full.mem`

### Configuração
```bash
./configure \
  --top rv32i_tb \
  --test rv32i_phase3_test \
  --vivado "--R --testplusarg PROG=../tb/programs/phase3/mem/phase3_full.mem --testplusarg MAX_INSTR=19 --testplusarg START_PC=0x00000000"
```

## 4. Próximos passos

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

1. `phase3_load_store_basic.mem`
2. `phase3_sign_zero_ext.mem`
3. `phase3_full.mem`

---

## Observação

Os valores de `MAX_INSTR` usados foram:

- `phase3_load_store_basic.mem` → `9`
- `phase3_sign_zero_ext.mem` → `9`
- `phase3_full.mem` → `19`

Eles correspondem à quantidade de instruções de cada programa.
