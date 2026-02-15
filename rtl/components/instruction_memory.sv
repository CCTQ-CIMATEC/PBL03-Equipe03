module instruction_memory #(
    parameter SIZE = 1024,
    parameter FILE = "test_prog.mem"
)(
    input  logic [31:0] a,
    output logic [31:0] rd
);
    logic [31:0] instrmem [0:SIZE-1];

    initial begin
        // 1. Tenta carregar o arquivo
        $readmemh(FILE, instrmem);

        // 2. Debug: Mostra no console o que foi carregado nas primeiras posições
        $display("--------------------------------------------------");
        $display("DEBUG MEMORIA: Carregando arquivo '%s'", FILE);
        $display("DEBUG MEMORIA: instrmem[0] = %h", instrmem[0]);
        $display("DEBUG MEMORIA: instrmem[1] = %h", instrmem[1]);
        $display("--------------------------------------------------");
    end
    
    assign rd = instrmem[a[31:2]];
endmodule