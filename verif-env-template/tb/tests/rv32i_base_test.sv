`ifndef RV32I_BASE_TEST_SV
`define RV32I_BASE_TEST_SV

// Importa o pacote de configuração do testbench,
// onde estão os valores default do programa, número máximo
// de instruções e PC inicial.
import rv32i_tb_cfg_pkg::*;

// ============================================================
// Classe base de teste
// ------------------------------------------------------------
// Papel desta classe:
// 1) definir valores default do teste
// 2) sobrescrever esses valores com plusargs, se fornecidos
// 3) propagar a configuração para os componentes do ambiente
// 4) instanciar o ambiente UVM
// 5) controlar o encerramento do teste via scoreboard ou timeout
// ============================================================
class rv32i_base_test extends uvm_test;
    `uvm_component_utils(rv32i_base_test)

    // Ambiente principal de verificação
    rv32i_env env;

    // --------------------------------------------------------
    // Parâmetros principais do teste
    // --------------------------------------------------------
    // prog_file : caminho do arquivo .mem a ser executado
    // max_instr : número máximo de instruções/commits esperados
    // start_pc  : endereço inicial do PC no modelo de referência
    // --------------------------------------------------------
    string       prog_file;
    int unsigned max_instr;
    bit [31:0]   start_pc;

    // ========================================================
    // Construtor
    // --------------------------------------------------------
    // Inicializa a classe e define valores default.
    // Esses valores podem ser sobrescritos depois via plusargs.
    // ========================================================
    function new(string name = "rv32i_base_test", uvm_component parent = null);
        super.new(name, parent);

        prog_file = RV32I_DEFAULT_PROG_FILE;
        max_instr = RV32I_DEFAULT_MAX_INSTR;
        start_pc  = RV32I_DEFAULT_START_PC;
    endfunction

    // ========================================================
    // Build phase
    // --------------------------------------------------------
    // Nesta fase:
    // 1) lemos plusargs da linha de comando
    // 2) registramos os valores no config_db
    // 3) criamos o ambiente
    //
    // Exemplo de uso de plusargs:
    //   +PROG=test_prog.mem
    //   +MAX_INSTR=100
    //   +START_PC=00000000
    // ========================================================
    function void build_phase(uvm_phase phase);

        // Flags para indicar se cada plusarg foi encontrado
        bit got_prog;
        bit got_max_instr;
        bit got_start_pc;

        super.build_phase(phase);

        // ----------------------------------------------------
        // Leitura dos plusargs
        // ----------------------------------------------------
        // Se o plusarg existir, a variável correspondente é
        // atualizada. Caso contrário, o valor default permanece.
        // ----------------------------------------------------
        got_prog     = $value$plusargs("PROG=%s", prog_file);
        got_max_instr = $value$plusargs("MAX_INSTR=%d", max_instr);
        got_start_pc = $value$plusargs("START_PC=%h", start_pc);

        // ----------------------------------------------------
        // Logs informativos sobre quais argumentos vieram
        // da linha de comando e quais ficaram no default
        // ----------------------------------------------------
        if (got_prog) begin
            `uvm_info("RV32I_BASE_TEST",
                $sformatf("Plusarg detectado: PROG=%s", prog_file),
                UVM_LOW)
        end
        else begin
            `uvm_info("RV32I_BASE_TEST",
                $sformatf("Plusarg PROG nao fornecido. Usando default: %s", prog_file),
                UVM_LOW)
        end

        if (got_max_instr) begin
            `uvm_info("RV32I_BASE_TEST",
                $sformatf("Plusarg detectado: MAX_INSTR=%0d", max_instr),
                UVM_LOW)
        end
        else begin
            `uvm_info("RV32I_BASE_TEST",
                $sformatf("Plusarg MAX_INSTR nao fornecido. Usando default: %0d", max_instr),
                UVM_LOW)
        end

        if (got_start_pc) begin
            `uvm_info("RV32I_BASE_TEST",
                $sformatf("Plusarg detectado: START_PC=%08h", start_pc),
                UVM_LOW)
        end
        else begin
            `uvm_info("RV32I_BASE_TEST",
                $sformatf("Plusarg START_PC nao fornecido. Usando default: %08h", start_pc),
                UVM_LOW)
        end

        // ----------------------------------------------------
        // Propagação da configuração para o ref_model
        // ----------------------------------------------------
        // O modelo de referência certamente precisa desses dados,
        // então fazemos o set diretamente no caminho específico.
        // ----------------------------------------------------
        uvm_config_db#(string)::set(this, "env.ref_model", "prog_file", prog_file);
        uvm_config_db#(int unsigned)::set(this, "env.ref_model", "max_instr", max_instr);
        uvm_config_db#(bit[31:0])::set(this, "env.ref_model", "start_pc", start_pc);

        // ----------------------------------------------------
        // Propagação mais ampla para componentes abaixo de env
        // ----------------------------------------------------
        // Isso é útil caso outros componentes também consultem
        // esses parâmetros no futuro.
        // ----------------------------------------------------
        uvm_config_db#(string)::set(this, "env*", "prog_file", prog_file);
        uvm_config_db#(int unsigned)::set(this, "env*", "max_instr", max_instr);
        uvm_config_db#(bit[31:0])::set(this, "env*", "start_pc", start_pc);

        // ----------------------------------------------------
        // Criação do ambiente
        // ----------------------------------------------------
        // Depois de configurar o config_db, criamos o env.
        // Assim, os componentes filhos podem recuperar os valores
        // durante suas próprias fases de build.
        // ----------------------------------------------------
        env = rv32i_env::type_id::create("env", this);
    endfunction

    // ========================================================
    // End of elaboration phase
    // --------------------------------------------------------
    // Fase útil para imprimir a configuração final consolidada,
    // já com defaults e plusargs aplicados.
    // ========================================================
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        `uvm_info("RV32I_BASE_TEST",
            $sformatf("Configuracao final do teste: prog_file=%s, max_instr=%0d, start_pc=%08h",
                      prog_file, max_instr, start_pc),
            UVM_LOW)
    endfunction

    // ========================================================
    // Run phase
    // --------------------------------------------------------
    // Esta fase controla a duração do teste.
    //
    // Estratégia:
    // - levantar objection para impedir o fim prematuro
    // - esperar o scoreboard atingir max_instr comparações
    // - em paralelo, manter um watchdog de timeout
    // - se o scoreboard terminar primeiro: teste encerra normal
    // - se o timeout vencer primeiro: erro fatal
    // ========================================================
    task run_phase(uvm_phase phase);
        int unsigned timeout_cycles;

        // Impede que a simulação termine enquanto este teste
        // ainda estiver ativo.
        phase.raise_objection(this);

        `uvm_info("RV32I_BASE_TEST",
            "Iniciando execucao do teste base.",
            UVM_LOW)


        // Define um timeout simples em ciclos de clock
        timeout_cycles = max_instr + 50;

        fork
            // =================================================
            // Thread 1: espera o scoreboard concluir o número
            // desejado de comparações
            // =================================================
            begin : wait_scoreboard_done
                wait (env.scoreboard.num_compares >= max_instr);

                `uvm_info("RV32I_BASE_TEST",
                    $sformatf("Condicao de parada atingida: num_compares=%0d pass=%0d fail=%0d",
                              env.scoreboard.num_compares,
                              env.scoreboard.num_pass,
                              env.scoreboard.num_fail),
                    UVM_LOW)
            end

            // =================================================
            // Thread 2: watchdog de timeout
            // =================================================
            begin : timeout_watchdog
                repeat (timeout_cycles) @(posedge env.monitor.vif.clk);

                `uvm_fatal("RV32I_TIMEOUT",
                    $sformatf("Timeout: scoreboard nao atingiu %0d comparacoes em %0d ciclos. compares=%0d pass=%0d fail=%0d",
                              max_instr,
                              timeout_cycles,
                              env.scoreboard.num_compares,
                              env.scoreboard.num_pass,
                              env.scoreboard.num_fail))
            end
        join_any

        // ----------------------------------------------------
        // Assim que uma das duas threads terminar, encerramos
        // a outra.
        // ----------------------------------------------------
        disable fork;

        `uvm_info("RV32I_BASE_TEST",
            "Encerrando execucao do teste base.",
            UVM_LOW)

        // Libera o objection, permitindo o encerramento
        // da simulação quando todas as objections forem baixadas.
        phase.drop_objection(this);
    endtask

endclass

`endif