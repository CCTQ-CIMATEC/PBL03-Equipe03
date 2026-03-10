`timescale 1ns/1ps

module pipelined_tb();

    logic clk;
    logic rst;

    // Instanciação do Processador (Top Level)
    pipelined dut (
        .clk(clk),
        .rst(rst)
    );

    // Geração do Clock (Período de 10ns = 100MHz)
    always #5 clk = ~clk;

    // Bloco de Estímulos
    initial begin
        // Inicialização
        clk = 0;
            rst = 0; // Ativa o reset (alto conforme seu código)

            $display("Iniciando Simulação...");
            
            // Mantém o reset por alguns ciclos
            #20;
            @(negedge clk);
            rst = 1; // Desativa o reset
        
        $display("Reset desativado. Executando programa...");

        // Monitoramento de sinais via console
        // Vamos monitorar o PC no estágio Fetch e o resultado sendo escrito no WB
        $monitor("Tempo: %0t | PC_Fetch: %h | RD_WB: %d | Dado_WB: %d | RegWrite: %b", 
                 $time, dut.pcF, dut.rdW, dut.resultW, dut.regwriteW);

        // Executa por tempo suficiente para o programa de teste terminar
        // O programa tem ~13 instruções + latência de pipeline
        #250;

        $display("Simulação finalizada.");
        $display("Verifique se x6 (rdW=6) contém o valor 25.");
        $finish;
    end

    // Tarefa para debugar o Banco de Registradores (opcional)
    // Se o seu simulador permitir, você pode ver o conteúdo interno:
    /*
    initial begin
        #230;
        $display("Conteúdo Final do Reg[6]: %d", dut.u_reg_file_n.rf[6]);
        $display("Conteúdo da Memória[0]: %h", dut.u_data_memory.mem[0]);
    end
    */

endmodule