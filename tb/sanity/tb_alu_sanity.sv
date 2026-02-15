module tb_alu_sanity;

    // 1. Importar o pacote para usar os tipos (alu_ops_t, ALU_ADD, etc.)
    import riscv_pkg::*;

    // 2. Sinais para conectar na ALU
    logic [31:0] a, b;
    alu_ops_t    ctrl;
    logic [31:0] result;
    logic        zero;

    // 3. Instância da ALU (Unit Under Test)
    alu uut (
        .a(a),
        .b(b),
        .ctrl(ctrl),
        .result(result),
        .zero(zero)
    );

    // 4. Procedimento de Teste
    initial begin
        $display("=== Iniciando Teste de Sanidade da ALU ===");

        // Teste 1: Soma (ADD)
        // 10 + 20 = 30
        check(32'd10, 32'd20, ALU_ADD, 32'd30, 1'b0, "ADD Simples");

        // Teste 2: Subtração (SUB)
        // 100 - 30 = 70
        check(32'd100, 32'd30, ALU_SUB, 32'd70, 1'b0, "SUB Simples");

        // Teste 3: Subtração resultando em Zero (Teste da flag Zero)
        // 50 - 50 = 0 (Zero deve ser 1)
        check(32'd50, 32'd50, ALU_SUB, 32'd0, 1'b1, "SUB Zero Flag");

        // Teste 4: AND
        // 0x00FF & 0x0F0F = 0x000F
        check(32'h000000FF, 32'h00000F0F, ALU_AND, 32'h0000000F, 1'b0, "AND Logico");

        // Teste 5: OR
        // 0x00F0 | 0x000F = 0x00FF
        check(32'h000000F0, 32'h0000000F, ALU_OR, 32'h000000FF, 1'b0, "OR Logico");

        // Teste 6: XOR
        // 0xAAAA ^ 0x5555 = 0xFFFF
        check(32'h0000AAAA, 32'h00005555, ALU_XOR, 32'h0000FFFF, 1'b0, "XOR Logico");
        
        // Teste 7: XOR (Igualdade)
        // 0x1234 ^ 0x1234 = 0 (Zero deve ser 1)
        check(32'h12345678, 32'h12345678, ALU_XOR, 32'd0, 1'b1, "XOR Igualdade");

        $display("=== Teste Finalizado com Sucesso! ===");
        $finish;
    end

    // 5. Tarefa automática de verificação
    // Recebe as entradas e o que ESPERAMOS que saia (exp_result, exp_zero)
    task check(
        input logic [31:0] val_a,
        input logic [31:0] val_b,
        input alu_ops_t    op,
        input logic [31:0] exp_result,
        input logic        exp_zero,
        input string       test_name
    );
        begin
            // Aplica os estímulos
            a = val_a;
            b = val_b;
            ctrl = op;
            
            // Espera um delta de tempo para a lógica propagar
            #10; 

            // Verifica se o resultado real bate com o esperado
            if (result !== exp_result || zero !== exp_zero) begin
                $error("ERRO no teste %s!", test_name);
                $display("   Entradas: A=%h, B=%h, Op=%s", val_a, val_b, op.name()); // op.name() imprime o nome do enum!
                $display("   Esperado: Res=%h, Zero=%b", exp_result, exp_zero);
                $display("   Obtido:   Res=%h, Zero=%b", result, zero);
                $stop; // Para a simulação se houver erro
            end else begin
                $display("[PASS] %s: %h op %h = %h", test_name, val_a, val_b, result);
            end
        end
    endtask

endmodule