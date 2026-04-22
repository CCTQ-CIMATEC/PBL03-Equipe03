# Comandos para rodar os testes da Fase 5

## 1. Teste `phase5_full.mem`

### Configuração
```bash
./configure \
  --top rv32i_tb \
  --test rv32i_phase5_test \
  --vivado "--R --testplusarg PROG=../tb/programs/phase5/mem/phase5_full.mem --testplusarg MAX_INSTR=23 --testplusarg START_PC=0x00000000"
```

---

## 2. Teste `phase5_regression.mem`

### Configuração
```bash
./configure \
  --top rv32i_tb \
  --test rv32i_phase5_test \
  --vivado "--R --testplusarg PROG=../tb/programs/phase5/mem/phase5_regression.mem --testplusarg MAX_INSTR=100 --testplusarg START_PC=0x00000000"
```

---

## 3. Próximos passos

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

1. `phase5_full.mem`
2. `phase5_regression.mem`

---

## Observação

O valor de `MAX_INSTR` usado foi:

- `phase5_full.mem` → `20`
- `phase5_regression.mem` → `94`


Ele corresponde à quantidade de eventos arquiteturais esperados no programa.
