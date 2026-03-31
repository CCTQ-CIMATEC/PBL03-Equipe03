module tb_rf_sanity;

    logic        clk;
    logic        we3;
    logic [4:0]  a1, a2, a3;
    logic [31:0] wd3;
    logic [31:0] rd1, rd2;

    reg_file uut (.*); // Conexão automática pelo nome (SystemVerilog)

    // Clock generator
    always #5 clk = ~clk;

    initial begin
        // Inicialização
        clk = 0; we3 = 0; a1 = 0; a2 = 0; a3 = 0; wd3 = 0;
        
        $display("=== Teste RegFile Iniciado ===");

        // 1. Escrever no registrador x1
        @(negedge clk); // Espera borda de descida para preparar dados
        we3 = 1; a3 = 5'd1; wd3 = 32'hDEADBEEF;
        @(posedge clk); // Borda de subida (Escreve)

        // 2. Ler x1 e x2
        @(negedge clk);
        we3 = 0; 
        a1 = 5'd1; // Deve ler DEADBEEF
        a2 = 5'd2; // Deve ler Lixo/Unknown (ou 0 se simulador limpar)
        #1;
        if (rd1 !== 32'hDEADBEEF) $error("Falha: x1 nao gravou!");
        else $display("[PASS] Escrita em x1 OK");

        // 3. Tentar escrever no x0 (Deve falhar/ser ignorado na leitura)
        @(negedge clk);
        we3 = 1; a3 = 5'd0; wd3 = 32'hFFFFFFFF;
        @(posedge clk);

        // 4. Ler x0
        @(negedge clk);
        we3 = 0; a1 = 5'd0;
        #1;
        if (rd1 !== 32'd0) $error("Falha: x0 foi alterado!");
        else $display("[PASS] Protecao do x0 OK");

        $finish;
    end
endmodule