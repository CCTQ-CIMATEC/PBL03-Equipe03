module instruction_memory_tb;

    // Sinais
    logic [31:0] a;
    logic [31:0] rd;

    // Instância da Memória (Unit Under Test)
    // Sobrescrevemos o parâmetro FILE para usar nosso arquivo de teste
    instruction_memory #(
        .SIZE(1024),
        .FILE("test_prog.mem") 
    ) uut (
        .a(a),
        .rd(rd)
    );

    initial begin
        $display("=== Iniciando Teste da Instruction Memory ===");
        
        // Crie o arquivo 'test_prog.mem' antes de rodar!
        // Conteúdo esperado:
        // Linha 0: 00000093
        // Linha 1: DEADBEEF
        // Linha 2: CAFEBABE

        // Teste 1: Endereço 0 (Primeira instrução)
        a = 32'd0;
        #10; // Espera propagação
        check(32'h00000093, "Leitura Endereco 0");

        // Teste 2: Endereço 4 (Segunda instrução - índice 1)
        a = 32'd4;
        #10;
        check(32'hDEADBEEF, "Leitura Endereco 4");

        // Teste 3: Endereço 8 (Terceira instrução - índice 2)
        a = 32'd8;
        #10;
        check(32'hCAFEBABE, "Leitura Endereco 8");

        // Teste 4: Endereço fora do limite (Ex: 8000)
        // Deve retornar 0 (NOP) devido à nossa proteção
        a = 32'd8000;
        #10;
        check(32'd0, "Leitura Out of Bounds");

        $display("=== Teste Finalizado com Sucesso! ===");
        $finish;
    end

    // Tarefa de verificação
    task check(input logic [31:0] expected, input string msg);
        if (rd !== expected) begin
            $error("ERRO em %s: Esperado %h, Obtido %h", msg, expected, rd);
        end else begin
            $display("[PASS] %s: %h", msg, rd);
        end
    endtask

endmodule