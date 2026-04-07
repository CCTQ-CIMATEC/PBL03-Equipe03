`ifndef RV32I_MEM_UTILS_SVH
`define RV32I_MEM_UTILS_SVH

task automatic rv32i_check_mem_file_or_fatal(input string mem_path);
    integer fd;

    if (mem_path == "") begin
        $fatal(1, "[MEM] Caminho do .mem vazio");
    end

    fd = $fopen(mem_path, "r");
    if (fd == 0) begin
        $fatal(1, "[MEM] Nao foi possivel abrir o arquivo: %s", mem_path);
    end
    $fclose(fd);
endtask

`endif