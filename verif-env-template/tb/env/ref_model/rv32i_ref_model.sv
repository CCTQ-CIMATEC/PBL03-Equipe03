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
    // Memória de dados do modelo (byte-addressable)
    // ------------------------------------------------------------
    bit [7:0] data_mem [0:4095];

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

        for (i = 0; i < 4096; i++) begin
            data_mem[i] = 8'h00;
        end

        pc_model = start_pc;
    endfunction

    // ------------------------------------------------------------
    // Sign-extend helpers de imediatos
    // ------------------------------------------------------------
    function automatic bit [31:0] sext12(input bit [11:0] imm12);
        sext12 = {{20{imm12[11]}}, imm12};
    endfunction

    function automatic bit [31:0] sext13(input bit [12:0] imm13);
        sext13 = {{19{imm13[12]}}, imm13};
    endfunction

    function automatic bit [31:0] sext21(input bit [20:0] imm21);
        sext21 = {{11{imm21[20]}}, imm21};
    endfunction

    function automatic bit [31:0] imm_b_from_instr(input bit [31:0] instr);
        imm_b_from_instr = sext13({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0});
    endfunction

    function automatic bit [31:0] imm_j_from_instr(input bit [31:0] instr);
        imm_j_from_instr = sext21({instr[31], instr[19:12], instr[20], instr[30:21], 1'b0});
    endfunction

    function automatic bit [31:0] sll32(
        input bit [31:0] value,
        input bit [4:0]  shamt
    );
        sll32 = value << shamt;
    endfunction

    function automatic bit [31:0] srl32(
        input bit [31:0] value,
        input bit [4:0]  shamt
    );
        srl32 = value >> shamt;
    endfunction

    function automatic bit [31:0] sra32(
        input bit [31:0] value,
        input bit [4:0]  shamt
    );
        sra32 = $signed(value) >>> shamt;
    endfunction

    // ------------------------------------------------------------
    // Helpers de memória
    // ------------------------------------------------------------
    function automatic bit [31:0] load_byte_signed(input bit [31:0] addr);
        bit [7:0] b;
        b = data_mem[addr];
        load_byte_signed = {{24{b[7]}}, b};
    endfunction

    function automatic bit [31:0] load_byte_unsigned(input bit [31:0] addr);
        bit [7:0] b;
        b = data_mem[addr];
        load_byte_unsigned = {24'h000000, b};
    endfunction

    function automatic bit [31:0] load_half_signed(input bit [31:0] addr);
        bit [15:0] h;
        h = {data_mem[addr + 32'd1], data_mem[addr]};
        load_half_signed = {{16{h[15]}}, h};
    endfunction

    function automatic bit [31:0] load_half_unsigned(input bit [31:0] addr);
        bit [15:0] h;
        h = {data_mem[addr + 32'd1], data_mem[addr]};
        load_half_unsigned = {16'h0000, h};
    endfunction

    function automatic bit [31:0] load_word(input bit [31:0] addr);
        load_word = {
            data_mem[addr + 32'd3],
            data_mem[addr + 32'd2],
            data_mem[addr + 32'd1],
            data_mem[addr]
        };
    endfunction

    function automatic void store_byte(
        input bit [31:0] addr,
        input bit [31:0] data
    );
        data_mem[addr] = data[7:0];
    endfunction

    function automatic void store_half(
        input bit [31:0] addr,
        input bit [31:0] data
    );
        data_mem[addr]         = data[7:0];
        data_mem[addr + 32'd1] = data[15:8];
    endfunction

    function automatic void store_word(
        input bit [31:0] addr,
        input bit [31:0] data
    );
        data_mem[addr]         = data[7:0];
        data_mem[addr + 32'd1] = data[15:8];
        data_mem[addr + 32'd2] = data[23:16];
        data_mem[addr + 32'd3] = data[31:24];
    endfunction

    // ------------------------------------------------------------
    // Máscaras esperadas de escrita
    // Convenção:
    //   bit0 -> byte de menor endereço
    // ------------------------------------------------------------
    function automatic bit [3:0] mask_sb(input bit [31:0] addr);
        mask_sb = (4'b0001 << addr[1:0]);
    endfunction

    function automatic bit [3:0] mask_sh(input bit [31:0] addr);
        mask_sh = (addr[1]) ? 4'b1100 : 4'b0011;
    endfunction

    function automatic bit [3:0] mask_sw();
        mask_sw = 4'b1111;
    endfunction

    // ------------------------------------------------------------
    // Inicializa campos comuns/default da transação
    // ------------------------------------------------------------
    function void init_tr_defaults(
        rv32i_commit_tr tr,
        int unsigned cyc,
        bit [31:0] pc,
        bit [31:0] instr
    );
        tr.cycle      = cyc;
        tr.pc         = pc;
        tr.instr      = instr;

        tr.regwrite   = 1'b0;
        tr.rd_addr    = 5'd0;
        tr.rd_data    = 32'h0000_0000;

        tr.memwrite   = 1'b0;
        tr.mem_addr   = 32'h0000_0000;
        tr.mem_wdata  = 32'h0000_0000;
        tr.mem_wmask  = 4'b0000;

        tr.x0_value   = regs_model[0];

        tr.stallF      = 1'b0;
        tr.stallD      = 1'b0;
        tr.flushE      = 1'b0;
        tr.pc_fetch    = 32'h0;
        tr.instr_fetch = 32'h0;
        tr.instr_dec   = 32'h0;
        tr.instr_ex    = 32'h0;
    endfunction

    // ------------------------------------------------------------
    // Gera a sequência de commits esperados
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
        bit [31:0] imm_s;
        bit [31:0] imm_b;
        bit [31:0] imm_j;
        bit [4:0]  shamt_i;

        bit [31:0] result;
        bit [31:0] eff_addr;
        bit [31:0] next_pc;

        rv32i_commit_tr tr;

        `uvm_info("RV32I_REF",
            $sformatf("Gerando commits esperados (max_instr=%0d, start_pc=%08h)",
                      max_instr, start_pc),
            UVM_LOW)

        for (i = 0; i < max_instr; i++) begin
            instr   = prog_mem[pc_model[31:2]];
            opcode  = instr[6:0];
            funct3  = instr[14:12];
            funct7  = instr[31:25];
            rs1     = instr[19:15];
            rs2     = instr[24:20];
            rd      = instr[11:7];
            imm_i   = sext12(instr[31:20]);
            imm_s   = sext12({instr[31:25], instr[11:7]});
            imm_b   = imm_b_from_instr(instr);
            imm_j   = imm_j_from_instr(instr);
            shamt_i = instr[24:20];

            // Se pegou X/Z, interrompe para evitar lixo
            if ((^instr) === 1'bx) begin
                `uvm_warning("RV32I_REF",
                    $sformatf("Instrucao indefinida em pc=%08h. Encerrando geração.",
                              pc_model))
                break;
            end

            result   = 32'h0000_0000;
            eff_addr = 32'h0000_0000;
            next_pc  = pc_model + 32'd4;

            // ====================================================
            // I-TYPE ARITH / LOGIC
            // ====================================================

            // ADDI
            if ((opcode == 7'b0010011) && (funct3 == 3'b000)) begin
                result = regs_model[rs1] + imm_i;

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_addi_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // XORI
            else if ((opcode == 7'b0010011) && (funct3 == 3'b100)) begin
                result = regs_model[rs1] ^ imm_i;

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_xori_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // ORI
            else if ((opcode == 7'b0010011) && (funct3 == 3'b110)) begin
                result = regs_model[rs1] | imm_i;

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_ori_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // ANDI
            else if ((opcode == 7'b0010011) && (funct3 == 3'b111)) begin
                result = regs_model[rs1] & imm_i;

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_andi_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // SLLI
            else if ((opcode == 7'b0010011) &&
                     (funct3 == 3'b001)     &&
                     (funct7 == 7'b0000000)) begin
                result = sll32(regs_model[rs1], shamt_i);

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_slli_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // SRLI
            else if ((opcode == 7'b0010011) &&
                     (funct3 == 3'b101)     &&
                     (funct7 == 7'b0000000)) begin
                result = srl32(regs_model[rs1], shamt_i);

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_srli_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // SRAI
            else if ((opcode == 7'b0010011) &&
                     (funct3 == 3'b101)     &&
                     (funct7 == 7'b0100000)) begin
                result = sra32(regs_model[rs1], shamt_i);

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_srai_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // ====================================================
            // LOADS (Fase 3)
            // ====================================================

            // LB
            else if ((opcode == 7'b0000011) && (funct3 == 3'b000)) begin
                eff_addr = regs_model[rs1] + imm_i;
                result   = load_byte_signed(eff_addr);

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_lb_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // LH
            else if ((opcode == 7'b0000011) && (funct3 == 3'b001)) begin
                eff_addr = regs_model[rs1] + imm_i;
                result   = load_half_signed(eff_addr);

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_lh_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // LW
            else if ((opcode == 7'b0000011) && (funct3 == 3'b010)) begin
                eff_addr = regs_model[rs1] + imm_i;
                result   = load_word(eff_addr);

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_lw_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // LBU
            else if ((opcode == 7'b0000011) && (funct3 == 3'b100)) begin
                eff_addr = regs_model[rs1] + imm_i;
                result   = load_byte_unsigned(eff_addr);

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_lbu_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // LHU
            else if ((opcode == 7'b0000011) && (funct3 == 3'b101)) begin
                eff_addr = regs_model[rs1] + imm_i;
                result   = load_half_unsigned(eff_addr);

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_lhu_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // ====================================================
            // R-TYPE ARITH / LOGIC
            // ====================================================

            // ADD
            else if ((opcode == 7'b0110011) &&
                     (funct3 == 3'b000)     &&
                     (funct7 == 7'b0000000)) begin
                result = regs_model[rs1] + regs_model[rs2];

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_add_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // SUB
            else if ((opcode == 7'b0110011) &&
                     (funct3 == 3'b000)     &&
                     (funct7 == 7'b0100000)) begin
                result = regs_model[rs1] - regs_model[rs2];

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_sub_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // XOR
            else if ((opcode == 7'b0110011) &&
                     (funct3 == 3'b100)     &&
                     (funct7 == 7'b0000000)) begin
                result = regs_model[rs1] ^ regs_model[rs2];

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_xor_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // OR
            else if ((opcode == 7'b0110011) &&
                     (funct3 == 3'b110)     &&
                     (funct7 == 7'b0000000)) begin
                result = regs_model[rs1] | regs_model[rs2];

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_or_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // AND
            else if ((opcode == 7'b0110011) &&
                     (funct3 == 3'b111)     &&
                     (funct7 == 7'b0000000)) begin
                result = regs_model[rs1] & regs_model[rs2];

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_and_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // SLL
            else if ((opcode == 7'b0110011) &&
                     (funct3 == 3'b001)     &&
                     (funct7 == 7'b0000000)) begin
                result = sll32(regs_model[rs1], regs_model[rs2][4:0]);

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_sll_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // SRL
            else if ((opcode == 7'b0110011) &&
                     (funct3 == 3'b101)     &&
                     (funct7 == 7'b0000000)) begin
                result = srl32(regs_model[rs1], regs_model[rs2][4:0]);

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_srl_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // SRA
            else if ((opcode == 7'b0110011) &&
                     (funct3 == 3'b101)     &&
                     (funct7 == 7'b0100000)) begin
                result = sra32(regs_model[rs1], regs_model[rs2][4:0]);

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_sra_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // ====================================================
            // STORES (Fase 3)
            // ====================================================

            // SB
            else if ((opcode == 7'b0100011) && (funct3 == 3'b000)) begin
                eff_addr = regs_model[rs1] + imm_s;

                store_byte(eff_addr, regs_model[rs2]);

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_sb_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.memwrite = 1'b1;
                tr.mem_addr = eff_addr;
                tr.mem_wdata = regs_model[rs2];
                tr.mem_wmask = mask_sb(eff_addr);

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // SH
            else if ((opcode == 7'b0100011) && (funct3 == 3'b001)) begin
                eff_addr = regs_model[rs1] + imm_s;

                store_half(eff_addr, regs_model[rs2]);

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_sh_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.memwrite = 1'b1;
                tr.mem_addr = eff_addr;
                tr.mem_wdata = regs_model[rs2];
                tr.mem_wmask = mask_sh(eff_addr);

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end

            // SW
            else if ((opcode == 7'b0100011) && (funct3 == 3'b010)) begin
                eff_addr = regs_model[rs1] + imm_s;

                store_word(eff_addr, regs_model[rs2]);

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_sw_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.memwrite = 1'b1;
                tr.mem_addr = eff_addr;
                tr.mem_wdata = regs_model[rs2];
                tr.mem_wmask = mask_sw();

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);
            end


            // ====================================================
            // BRANCHES / JUMPS (Fase 4)
            // ====================================================

            // BEQ
            else if ((opcode == 7'b1100011) && (funct3 == 3'b000)) begin
                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_beq_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);
                tr.x0_value = regs_model[0];

                exp_ap.write(tr);

                if (regs_model[rs1] == regs_model[rs2])
                    next_pc = pc_model + imm_b;
            end

            // BNE
            else if ((opcode == 7'b1100011) && (funct3 == 3'b001)) begin
                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_bne_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);
                tr.x0_value = regs_model[0];

                exp_ap.write(tr);

                if (regs_model[rs1] != regs_model[rs2])
                    next_pc = pc_model + imm_b;
            end

            // BLT
            else if ((opcode == 7'b1100011) && (funct3 == 3'b100)) begin
                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_blt_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);
                tr.x0_value = regs_model[0];

                exp_ap.write(tr);

                if ($signed(regs_model[rs1]) < $signed(regs_model[rs2]))
                    next_pc = pc_model + imm_b;
            end

            // BGE
            else if ((opcode == 7'b1100011) && (funct3 == 3'b101)) begin
                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_bge_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);
                tr.x0_value = regs_model[0];

                exp_ap.write(tr);

                if ($signed(regs_model[rs1]) >= $signed(regs_model[rs2]))
                    next_pc = pc_model + imm_b;
            end

            // BLTU
            else if ((opcode == 7'b1100011) && (funct3 == 3'b110)) begin
                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_bltu_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);
                tr.x0_value = regs_model[0];

                exp_ap.write(tr);

                if (regs_model[rs1] < regs_model[rs2])
                    next_pc = pc_model + imm_b;
            end

            // BGEU
            else if ((opcode == 7'b1100011) && (funct3 == 3'b111)) begin
                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_bgeu_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);
                tr.x0_value = regs_model[0];

                exp_ap.write(tr);

                if (regs_model[rs1] >= regs_model[rs2])
                    next_pc = pc_model + imm_b;
            end

            // JAL
            else if (opcode == 7'b1101111) begin
                result = pc_model + 32'd4;

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_jal_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);

                next_pc = pc_model + imm_j;
            end

            // JALR
            else if ((opcode == 7'b1100111) && (funct3 == 3'b000)) begin
                eff_addr = (regs_model[rs1] + imm_i) & 32'hffff_fffe;
                result   = pc_model + 32'd4;

                tr = rv32i_commit_tr::type_id::create(
                        $sformatf("exp_jalr_%0d", i), this);

                init_tr_defaults(tr, i, pc_model, instr);

                tr.regwrite = 1'b1;
                tr.rd_addr  = rd;
                tr.rd_data  = result;

                if (rd != 5'd0)
                    regs_model[rd] = result;

                regs_model[0] = 32'h0000_0000;
                tr.x0_value   = regs_model[0];

                exp_ap.write(tr);

                next_pc = eff_addr;
            end

            // ====================================================
            // Instrução não suportada nesta fase
            // ====================================================
            else begin
                `uvm_warning("RV32I_REF",
                    $sformatf("Instrucao nao suportada ate a Fase 4 em pc=%08h: %08h",
                              pc_model, instr))
            end

            // x0 sempre zero
            regs_model[0] = 32'h0000_0000;

            // Próxima instrução (sequencial ou alterada por controle)
            pc_model = next_pc;
        end

        `uvm_info("RV32I_REF",
            "Geracao de commits esperados concluida.",
            UVM_LOW)
    endtask

endclass

`endif