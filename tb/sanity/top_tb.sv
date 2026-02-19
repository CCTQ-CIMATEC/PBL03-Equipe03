module top_tb;

    logic clk;
    logic rst_n;

    // Instância do Top Level
    top u_top (
        .clk(clk),
        .rst_n(rst_n)
    );

    // Gerador de Clock (10ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("ondas.vcd"); 
        $dumpvars(0, u_top); 
    end

    initial begin
        $display("=== Iniciando Simulacao do Processador RISC-V ===");

        // 1. Inicialização
        clk = 0;
        rst_n = 0; // Reset ativo (CPU parada)
        
        // 2. Reset por alguns ciclos
        repeat (2) @(negedge clk);
        rst_n = 1; // Solta o Reset (CPU começa a rodar)

        // 3. Roda por um tempo fixo
        // Como não temos instruções de 'halt', rodamos por tempo ou ciclos
        #500; 

        $display("=== Simulacao Finalizada ===");
        $finish;
    end

    // Monitoramento (Opcional: Mostra o que está acontecendo a cada clock)
    always @(posedge clk) begin
        if (rst_n) begin
            $display("Time: %0t | PC: %h | Instr: %h | ALU Res: %h | WriteData: %h | MemWrite_Enable: %b", 
                     $time, u_top.pc, u_top.instr, u_top.aluresult, u_top.writedata, u_top.write_enable);
        end
    end

endmodule