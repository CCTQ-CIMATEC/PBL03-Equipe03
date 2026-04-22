# Comandos para rodar os testes da Fase 2

## 1. Teste `phase2_imm_edges.mem`
### Configuração

```bash
./configure \
  --top rv32i_tb \
  --test rv32i_phase2_test \
  --vivado "--R --testplusarg PROG=../tb/programs/phase2/mem/phase2_imm_edges.mem --testplusarg MAX_INSTR=8 --testplusarg START_PC=0x00000000"
```

---

## 2. Teste `phase2_logic_patterns.mem`
### Configuração

```bash
./configure \
  --top rv32i_tb \
  --test rv32i_phase2_test \
  --vivado "--R --testplusarg PROG=../tb/programs/phase2/mem/phase2_logic_patterns.mem --testplusarg MAX_INSTR=11 --testplusarg START_PC=0x00000000"
```

---

## 3. Teste `phase2_shift_edges.mem`
### Configuração

```bash
./configure \
  --top rv32i_tb \
  --test rv32i_phase2_test \
  --vivado "--R --testplusarg PROG=../tb/programs/phase2/mem/phase2_shift_edges.mem --testplusarg MAX_INSTR=11 --testplusarg START_PC=0x00000000"
```

---

## 4. Teste `phase2_full.mem`
### Configuração

```bash
./configure \
  --top rv32i_tb \
  --test rv32i_phase2_test \
  --vivado "--R --testplusarg PROG=../tb/programs/phase2/mem/phase2_full.mem --testplusarg MAX_INSTR=28 --testplusarg START_PC=0x00000000"
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

1. `phase2_imm_edges.mem`
2. `phase2_logic_patterns.mem`
3. `phase2_shift_edges.mem`
4. `phase2_full.mem`

---

## Observação

Os valores de `MAX_INSTR` usados foram:

- `phase2_imm_edges.mem` → `8`
- `phase2_logic_patterns.mem` → `11`
- `phase2_shift_edges.mem` → `11`
- `phase2_full.mem` → `22`

Eles correspondem à quantidade de instruções de cada programa.
