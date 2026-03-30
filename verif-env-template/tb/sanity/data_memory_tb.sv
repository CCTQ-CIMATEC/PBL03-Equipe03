module data_memory_tb;

    // 1. Sinais do Testbench
    logic        clk;
    logic        we;       // Write Enable
    logic [31:0] a;        // Address
    logic [31:0] wd;       // Write Data
    logic [31:0] rd;       // Read Data

    // 2. Instância da Memória (Unit Under Test)
    data_memory #(
        .DEPTH(1024) // Testando com 1024 palavras
    ) uut (
        .clk(clk),
        .we(we),
        .a(a),
        .wd(wd),
        .rd(rd)
    );

    // 3. Gerador de Clock (Período de 10ns)
    always #5 clk = ~clk;

    // 4. Procedimento de Teste
    initial begin
        $display("=== Iniciando Teste da Data Memory ===");
        
        // Inicialização
        clk = 0;
        we = 0;
        a = 0;
        wd = 0;

        // ----------------------------------------------------------------
        // TESTE 1: Escrita e Leitura Básica (Endereço 0)
        // ----------------------------------------------------------------
        $display("--- Teste 1: Escrita no endereco 0 ---");
        
        // Setup dos dados antes da borda de subida
        @(negedge clk); // Espera borda de descida (para estabilizar)
        a = 32'd0;
        wd = 32'hDEADBEEF;
        we = 1'b1;      // Habilita escrita

        @(posedge clk); // Borda de subida: A GRAVACAO ACONTECE AQUI
        
        // Desabilita escrita e verifica leitura
        @(negedge clk);
        we = 1'b0;      
        
        // Verifica se leu corretamente (Leitura é combinacional, deve sair na hora)
        check(32'hDEADBEEF, "Leitura A=0");


        // ----------------------------------------------------------------
        // TESTE 2: Escrita em outro endereço (Endereço 4 - Próxima Palavra)
        // ----------------------------------------------------------------
        $display("--- Teste 2: Escrita no endereco 4 (Word 1) ---");
        
        @(negedge clk);
        a = 32'd4;      // Endereço 4 bytes = Índice 1 da memória
        wd = 32'hCAFEBABE;
        we = 1'b1;

        @(posedge clk); // Grava
        
        @(negedge clk);
        we = 1'b0;
        check(32'hCAFEBABE, "Leitura A=4");

        // Verifica se o endereço 0 ainda está intacto
        a = 32'd0; 
        #1; // Pequeno delay para a leitura propagar
        check(32'hDEADBEEF, "Verificacao de integridade em A=0");


        // ----------------------------------------------------------------
        // TESTE 3: Teste do Write Enable (WE=0)
        // ----------------------------------------------------------------
        $display("--- Teste 3: Tentativa de escrita com WE=0 ---");
        
        @(negedge clk);
        a = 32'd4;          // Mesmo endereço do teste anterior
        wd = 32'hFFFFFFFF;  // Tenta escrever "Lixo"
        we = 1'b0;          // MAS O WE ESTÁ DESLIGADO!

        @(posedge clk);     // Clock bate, mas não deve gravar
        
        @(negedge clk);
        // O valor deve continuar sendo CAFEBABE, e não FFFFFFFF
        check(32'hCAFEBABE, "Protecao de WE=0 em A=4");


        // ----------------------------------------------------------------
        // TESTE 4: Endereçamento por Byte (Aliasing)
        // ----------------------------------------------------------------
        // O RISC-V endereça por byte. A=8, A=9, A=10, A=11 devem cair na mesma palavra.
        $display("--- Teste 4: Alinhamento de Endereco ---");
        
        @(negedge clk);
        a = 32'd8;      // Índice 2
        wd = 32'h12345678;
        we = 1'b1;
        @(posedge clk); // Grava
        we = 1'b0;

        // Agora lê usando endereço desalinhado (ex: 9)
        // Como sua lógica é a[31:2], o endereço 9 vira índice 2 também.
        @(negedge clk);
        a = 32'd9; 
        #1;
        check(32'h12345678, "Leitura Desalinhada (A=9 le Word 2)");


        $display("=== Teste Finalizado com Sucesso! ===");
        $finish;
    end

    // Tarefa de Verificação
    task check(input logic [31:0] expected, input string msg);
        if (rd !== expected) begin
            $error("ERRO em %s: Esperado %h, Obtido %h", msg, expected, rd);
        end else begin
            $display("[PASS] %s: %h", msg, rd);
        end
    endtask

endmodule