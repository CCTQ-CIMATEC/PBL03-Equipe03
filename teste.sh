#!/bin/bash

# ==============================================================================
# 1. Verificação de Argumentos
# ==============================================================================
if [ "$#" -lt 2 ]; then
    echo "❌ Erro de Uso."
    echo "Sintaxe: ./run_sim.sh <COMPONENTE> <TESTBENCH> [-v]"
    echo "Exemplo (Resumido): ./run_sim.sh top tb_top"
    echo "Exemplo (Verboso):  ./run_sim.sh top tb_top -v"
    exit 1
fi

MODULE_NAME=$1
TB_NAME=$2
VERBOSE_FLAG=$3

# Define se é modo verboso (1) ou silencioso (0)
if [ "$VERBOSE_FLAG" == "-v" ]; then
    IS_VERBOSE=1
else
    IS_VERBOSE=0
fi

# ==============================================================================
# 2. Configuração e Preparação de Pastas
# ==============================================================================

# Caminhos (Relativos à raiz do projeto)
PKG_FILE="../rtl/defines/riscv_pkg.sv"
# Nota: MODULE_FILE não é mais usado para compilação direta, pois vamos compilar tudo
TB_FILE="../tb/sanity/${TB_NAME}.sv"

# Logs
LOG_COMP="compile.log"
LOG_ELAB="elaborate.log"
LOG_SIM="simulate.log"

echo "============================================================"
echo "🚀 Simulação: $MODULE_NAME | TB: $TB_NAME"
if [ $IS_VERBOSE -eq 1 ]; then echo "📢 Modo: VERBOSO (Mostrando tudo)"; else echo "🤫 Modo: RESUMIDO (Apenas Pass/Fail)"; fi
echo "============================================================"

# Limpeza e Criação do Ambiente
rm -rf work
mkdir work

# Cópia de arquivos de memória (.mem)
# Copia da pasta tb/sanity/ para work/ ANTES de entrarmos nela
# O 2>/dev/null esconde erro se não houver arquivos .mem
cp tb/sanity/*.mem work/ 2>/dev/null

# Entra na pasta de trabalho
cd work

# ==============================================================================
# 3. Função Auxiliar de Execução (Controle de Erros e Logs)
# ==============================================================================
run_step() {
    local step_name="$1"
    local cmd="$2"
    local logfile="$3"
    local append="$4" # Se passar "append", usa >>, senão usa >

    # Monta o operador de redirecionamento
    if [ "$append" == "append" ]; then
        local redirect=">>"
        local pipe_flag="-a"
    else
        local redirect=">"
        local pipe_flag=""
    fi
    
    if [ $IS_VERBOSE -eq 1 ]; then
        # Modo Verboso: Mostra na tela e salva no log
        # eval executa o comando string como bash
        eval "$cmd 2>&1 | tee $pipe_flag $logfile"
    else
        # Modo Silencioso: Apenas log
        echo -n "   -> $step_name... "
        eval "$cmd $redirect $logfile 2>&1"
    fi

    # Checagem de Erro Genérica
    # Verifica status de saída ($?) OU se a palavra "Error" apareceu no log
    if [ $? -ne 0 ] || grep -q "Error" "$logfile" || grep -q "ERROR" "$logfile"; then
        echo ""
        echo "❌ FALHA CRÍTICA EM: $step_name"
        if [ $IS_VERBOSE -eq 0 ]; then
            echo "--- Exibindo erro (Do arquivo work/$logfile) ---"
            grep "Error" "$logfile" -A 2 -B 1 # Mostra a linha do erro e arredores
            echo "--------------------------------------------------"
            echo "Para ver tudo, abra: work/$logfile"
        fi
        exit 1
    else
        if [ $IS_VERBOSE -eq 0 ]; then echo "OK"; fi
    fi
}

# ==============================================================================
# 4. Compilação (xvlog)
# ==============================================================================
echo "[1/3] Compilando fontes..."

# Limpa/Cria o log de compilação
echo "" > $LOG_COMP

# 4.1 Package (Sempre o primeiro)
run_step "Package" "xvlog -sv $PKG_FILE" $LOG_COMP "append"

# 4.2 Design (TODOS os arquivos)
# Aqui usamos ../rtl/components/*.sv para garantir que alu, reg_file, core, etc
# sejam compilados e o 'top' consiga achá-los.
run_step "Design Completo" "xvlog -sv ../rtl/components/*.sv" $LOG_COMP "append"

# 4.3 Testbench
run_step "Testbench" "xvlog -sv $TB_FILE" $LOG_COMP "append"


# ==============================================================================
# 5. Elaboração (xelab)
# ==============================================================================
echo "[2/3] Elaborando..."
SNAPSHOT_NAME="${TB_NAME}_snap"

if [ $IS_VERBOSE -eq 1 ]; then 
    DEBUG_FLAGS="-debug typical -verbose 1"
else 
    DEBUG_FLAGS="-debug typical"
fi

run_step "Snapshot" "xelab -top $TB_NAME -snapshot $SNAPSHOT_NAME $DEBUG_FLAGS" $LOG_ELAB "new"


# ==============================================================================
# 6. Simulação (xsim)
# ==============================================================================
echo "[3/3] Simulando..."

if [ $IS_VERBOSE -eq 1 ]; then
    xsim $SNAPSHOT_NAME -runall 2>&1 | tee $LOG_SIM
else
    # Executa silenciosamente
    xsim $SNAPSHOT_NAME -runall > $LOG_SIM 2>&1
    
    # --- FILTRAGEM DE RESULTADO ---
    echo "------------------------------------------------------------"
    echo "📊 RESULTADO DOS TESTES:"
    echo "------------------------------------------------------------"
    
    # Procura mensagens importantes (PASS, Error, Fatal, Time)
    if grep -E "PASS|Error|Fatal|Time" $LOG_SIM; then
        # Imprime apenas as linhas relevantes
        grep -E "PASS|Error|Fatal|Time" $LOG_SIM
    else
        echo "⚠️  Nenhuma mensagem de [PASS] ou erro encontrada."
        echo "   (Certifique-se que seu testbench usa \$display)"
    fi
    echo "------------------------------------------------------------"
fi

echo "✅ Fim."