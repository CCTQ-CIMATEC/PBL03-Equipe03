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
        string prog_file = "../tb/programs/phase3/mem/phase3_sign_zero_ext.mem";
        $readmemh(prog_file, dut.u_instruction_memory.instrmem);

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

        // 
        // DEBUG PARA VALORES DOS REGISTRADORES AO FIM DA EXECUÇÂO
        #500;
        $display("--------------------------------------------------");
        $display("Resultados finais:");
        $display("x1 = %0d", dut.u_reg_file_n.rf[1]);
        $display("x2 = %0d", dut.u_reg_file_n.rf[2]);
        $display("x3 = %0d", dut.u_reg_file_n.rf[3]);
        $display("x4 = %0d", dut.u_reg_file_n.rf[4]);
        $display("x5 = %0d", dut.u_reg_file_n.rf[5]);
        $display("x6 = %0d", dut.u_reg_file_n.rf[6]);
        $display("x7 = %0d", dut.u_reg_file_n.rf[7]);
        $display("x8 = %0d", dut.u_reg_file_n.rf[8]);
        $display("x9 = %0d", dut.u_reg_file_n.rf[9]);
        $display("x10 = %0d", dut.u_reg_file_n.rf[10]);
        $display("x11 = %0d", dut.u_reg_file_n.rf[11]);
        $display("x12 = %0d", dut.u_reg_file_n.rf[12]);
        $display("x13 = %0d", dut.u_reg_file_n.rf[13]);
        $display("x14 = %0d", dut.u_reg_file_n.rf[14]);
        $display("x15 = %0d", dut.u_reg_file_n.rf[15]);
        $display("x16 = %0d", dut.u_reg_file_n.rf[16]);
        $display("x17 = %0d", dut.u_reg_file_n.rf[17]);
        $display("x18 = %0d", dut.u_reg_file_n.rf[18]);
        $display("x19 = %0d", dut.u_reg_file_n.rf[19]);
        $display("x20 = %0d", dut.u_reg_file_n.rf[20]);
        $display("x21 = %0d", dut.u_reg_file_n.rf[21]);
        $display("x22 = %0d", dut.u_reg_file_n.rf[22]);
        $display("x23 = %0d", dut.u_reg_file_n.rf[23]);
        $display("x24 = %0d", dut.u_reg_file_n.rf[24]);
        $display("x25 = %0d", dut.u_reg_file_n.rf[25]);
        $display("x26 = %0d", dut.u_reg_file_n.rf[26]);
        $display("x27 = %0d", dut.u_reg_file_n.rf[27]);
        $display("x28 = %0d", dut.u_reg_file_n.rf[28]);
        $display("x29 = %0d", dut.u_reg_file_n.rf[29]);
        $display("x30 = %0d", dut.u_reg_file_n.rf[30]);
        $display("x31 = %0d", dut.u_reg_file_n.rf[31]);
        $display("Mem[0] = %0d", dut.u_data_memory.datamem[0]);
        $display("--------------------------------------------------");
        $display("PC final: %h", dut.pc);
        $display("Simulação finalizada.");
        $finish;
    end

endmodule