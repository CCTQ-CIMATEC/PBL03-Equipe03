# Comandos para rodar os testes da Fase 1

## 1. Teste `phase1_full.mem`
### Configuração

```bash
./configure \
  --top rv32i_tb \
  --test rv32i_phase1_test \
  --vivado "--R --testplusarg PROG=../tb/programs/phase1/mem/phase1_full.mem --testplusarg MAX_INSTR=12 --testplusarg START_PC=0x00000000"
```

---

## 2. Próximos passos

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

1. `phase1_full.mem`

---

## Observação

Os valores de `MAX_INSTR` usados foram:

- `phase1_full.mem` → `12`

Eles correspondem à quantidade de instruções de cada programa.
