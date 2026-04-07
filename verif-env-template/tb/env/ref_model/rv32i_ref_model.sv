`ifndef RV32I_REF_MODEL_SV
`define RV32I_REF_MODEL_SV

class rv32i_ref_model extends uvm_component;
    `uvm_component_utils(rv32i_ref_model)

    // ------------------------------------------------------------
    // Virtual interface
    // ------------------------------------------------------------
    virtual rv32i_if vif;

    // ------------------------------------------------------------
    // Analysis port de saída:
    // publica commits esperados para o scoreboard
    // ------------------------------------------------------------
    uvm_analysis_port #(rv32i_commit_tr) exp_ap;

    // ------------------------------------------------------------
    // Configuração
    // ------------------------------------------------------------
    string prog_file;
    int unsigned max_instr;
    bit [31:0] start_pc;

    // ------------------------------------------------------------
    // Memória do programa e estado arquitetural do modelo
    // ------------------------------------------------------------
    bit [31:0] prog_mem [0:1023];
    bit [31:0] regs_model [0:31];
    bit [31:0] pc_model;

    // ------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------
    function new(string name = "rv32i_ref_model", uvm_component parent = null);
        super.new(name, parent);
        exp_ap = new("exp_ap", this);
    endfunction

    // ------------------------------------------------------------
    // Build phase
    // ------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual rv32i_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF",
                $sformatf("%s: virtual interface rv32i_if não encontrada",
                          get_full_name()))
        end

        // Arquivo do programa
        if (!uvm_config_db#(string)::get(this, "", "prog_file", prog_file)) begin
            `uvm_fatal("NO_PROGFILE",
                $sformatf("%s: arquivo de programa não encontrado no ambiente",
                          get_full_name()))
        end

        // Quantidade máxima de instruções que o modelo vai percorrer
        if (!uvm_config_db#(int unsigned)::get(this, "", "max_instr", max_instr))
            max_instr = 32;

        // PC inicial
        if (!uvm_config_db#(bit[31:0])::get(this, "", "start_pc", start_pc))
            start_pc = 32'h0000_0000;
    endfunction

    // ------------------------------------------------------------
    // Run phase
    // O modelo:
    // 1) lê o mesmo arquivo .mem do DUT
    // 2) espera sair do reset
    // 3) gera a sequência de commits esperados
    // ------------------------------------------------------------
    task run_phase(uvm_phase phase);
        load_program();
        reset_model();

        wait (vif.rst_n === 1'b1);
        @(posedge vif.clk);

        generate_expected_stream();
    endtask

    // ------------------------------------------------------------
    // Carrega programa na memória local do ref model
    // ------------------------------------------------------------
    task load_program();
        int i;
        for (i = 0; i < 1024; i++) begin
            prog_mem[i] = 32'h0000_0000;
        end

        rv32i_check_mem_file_or_fatal(prog_file);
        
        $readmemh(prog_file, prog_mem);

        `uvm_info("RV32I_REF",
            $sformatf("Programa carregado no ref model: %s", prog_file),
            UVM_LOW)
    endtask

    // ------------------------------------------------------------
    // Reset do modelo arquitetural
    // ------------------------------------------------------------
    function void reset_model();
        int i;
        for (i = 0; i < 32; i++) begin
            regs_model[i] = 32'h0000_0000;
        end
        pc_model = start_pc;
    endfunction

    // ------------------------------------------------------------
    // Sign-extend de imediato de 12 bits
    // ------------------------------------------------------------
    function automatic bit [31:0] sext12(input bit [11:0] imm12);
        sext12 = {{20{imm12[11]}}, imm12};
    endfunction

    // ------------------------------------------------------------
    // Gera a sequência de commits esperados
    // Suporta nesta fase:
    // - ADDI
    // - ADD
    // - SUB
    // Também cobre:
    // - escrita em x0 (rd=0), mantendo x0 = 0
    // ------------------------------------------------------------
    task generate_expected_stream();
        int unsigned i;
        bit [31:0] instr;

        bit [6:0]  opcode;
        bit [2:0]  funct3;
        bit [6:0]  funct7;
        bit [4:0]  rs1;
        bit [4:0]  rs2;
        bit [4:0]  rd;
        bit [31:0] imm_i;

        bit [31:0] result;

        rv32i_commit_tr tr;

        `uvm_info("RV32I_REF",
            $sformatf("Gerando commits esperados (max_instr=%0d, start_pc=%08h)",
                      max_instr, start_pc),
            UVM_LOW)

        for (i = 0; i < max_instr; i++) begin
            instr  = prog_mem[pc_model[31:2]];
            opcode = instr[6:0];
            funct3 = instr[14:12];
            funct7 = instr[31:25];
            rs1    = instr[19:15];
            rs2    = instr[24:20];
            rd     = instr[11:7];
            imm_i  = sext12(instr[31:20]);

            // Se pegou X/Z, interrompe para evitar lixo
            if ((^instr) === 1'bx) begin
                `uvm_warning("RV32I_REF",
                    $sformatf("Instrucao indefinida em pc=%08h. Encerrando geração.",
                              pc_model))
                break;
            end

            // ----------------------------------------------------
            // ADDI
            // opcode = 0010011, funct3 = 000
            // ----------------------------------------------------
            if ((opcode == 7'b0010011) && (funct3 == 3'b000)) begin
                result = regs_model[rs1] + imm_i;

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_addi_%0d", i), this);

                tr.cycle      = i;
                tr.pc         = pc_model;
                tr.instr      = instr;
                tr.regwrite   = 1'b1;
                tr.rd_addr    = rd;
                tr.rd_data    = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                tr.stallF     = 1'b0;
                tr.stallD     = 1'b0;
                tr.flushE     = 1'b0;
                tr.pc_fetch   = 32'h0;
                tr.instr_fetch= 32'h0;
                tr.instr_dec  = 32'h0;
                tr.instr_ex   = 32'h0;

                exp_ap.write(tr);
            end

            // ----------------------------------------------------
            // ADD
            // opcode = 0110011, funct3 = 000, funct7 = 0000000
            // ----------------------------------------------------
            else if ((opcode == 7'b0110011) &&
                     (funct3 == 3'b000) &&
                     (funct7 == 7'b0000000)) begin

                result = regs_model[rs1] + regs_model[rs2];

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_add_%0d", i), this);

                tr.cycle      = i;
                tr.pc         = pc_model;
                tr.instr      = instr;
                tr.regwrite   = 1'b1;
                tr.rd_addr    = rd;
                tr.rd_data    = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                tr.stallF     = 1'b0;
                tr.stallD     = 1'b0;
                tr.flushE     = 1'b0;
                tr.pc_fetch   = 32'h0;
                tr.instr_fetch= 32'h0;
                tr.instr_dec  = 32'h0;
                tr.instr_ex   = 32'h0;

                exp_ap.write(tr);
            end

            // ----------------------------------------------------
            // SUB
            // opcode = 0110011, funct3 = 000, funct7 = 0100000
            // ----------------------------------------------------
            else if ((opcode == 7'b0110011) &&
                     (funct3 == 3'b000) &&
                     (funct7 == 7'b0100000)) begin

                result = regs_model[rs1] - regs_model[rs2];

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_sub_%0d", i), this);

                tr.cycle      = i;
                tr.pc         = pc_model;
                tr.instr      = instr;
                tr.regwrite   = 1'b1;
                tr.rd_addr    = rd;
                tr.rd_data    = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                tr.stallF     = 1'b0;
                tr.stallD     = 1'b0;
                tr.flushE     = 1'b0;
                tr.pc_fetch   = 32'h0;
                tr.instr_fetch= 32'h0;
                tr.instr_dec  = 32'h0;
                tr.instr_ex   = 32'h0;

                exp_ap.write(tr);
            end

            // ----------------------------------------------------
            // Instrução não suportada nesta fase
            // ----------------------------------------------------
            else begin
                `uvm_warning("RV32I_REF",
                    $sformatf("Instrucao nao suportada na Fase 1 em pc=%08h: %08h",
                              pc_model, instr))
            end

            // x0 sempre zero
            regs_model[0] = 32'h0000_0000;

            // Próxima instrução sequencial
            pc_model = pc_model + 32'd4;
        end

        `uvm_info("RV32I_REF",
            "Geracao de commits esperados concluida.",
            UVM_LOW)
    endtask

endclass

`endif