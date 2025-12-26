// riscv_core_full.sv
// RV32I Minimal CPU — supports:
// R/I-type, Load/Store, Branch, Jump, Reset
// Load/Store byte/halfword/word, Sign-extension
// PC/Register observable for DV
// Ready for assertions and coverage in interface

module riscv_core_full (
    input  logic        clk,
    input  logic        reset,

    // Instruction Memory Interface
    output logic [31:0] imem_addr,
    input  logic [31:0] imem_rdata,

    // Data Memory Interface
    output logic [31:0] dmem_addr,
    output logic [31:0] dmem_wdata,
    output logic [3:0]  dmem_wstrb,
    output logic        dmem_we,
    input  logic [31:0] dmem_rdata,

    // Expose architectural state
    output logic [31:0] pc_out,
    output logic [31:0] regs_out [0:31]
);

    // ===== Registers =====
    logic [31:0] pc;
    logic [31:0] regs [0:31]; // x0-x31

    // ===== Instruction Decode =====
    logic [31:0] instr;
    logic [4:0]  rs1, rs2, rd;
    logic [31:0] op1, op2, alu_res, imm;
    logic        branch_taken;

    // ===== Fetch =====
    assign imem_addr = pc;

    // ===== Outputs =====
    assign pc_out = pc;
    assign regs_out = regs;

    // ===== Internal Memory Signals =====
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [3:0]  mem_wstrb;
    logic        mem_we;

    assign dmem_addr  = mem_addr;
    assign dmem_wdata = mem_wdata;
    assign dmem_wstrb = mem_wstrb;
    assign dmem_we    = mem_we;

    // ===== Instruction Decode & Execute =====
    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            pc <= 32'h0;
            branch_taken <= 0;
            for(int i=0;i<32;i++) regs[i]<=0;
            mem_addr <= 0;
            mem_wdata <= 0;
            mem_wstrb <= 0;
            mem_we <= 0;
        end else begin
            instr <= imem_rdata;
            rs1 <= instr[19:15];
            rs2 <= instr[24:20];
            rd  <= instr[11:7];

            op1 <= regs[rs1];
            op2 <= regs[rs2];

            // ===== Immediate extraction =====
            // I-type
            logic [31:0] imm_i, imm_s, imm_b, imm_j;
            imm_i = {{20{instr[31]}}, instr[31:20]};
            // S-type
            imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            // B-type
            imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            // J-type
            imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

            branch_taken <= 0;

            // ===== ALU & Control =====
            alu_res <= 32'h0;
            mem_we <= 0;
            mem_addr <= 0;
            mem_wdata <= 0;
            mem_wstrb <= 4'b0000;

            case(instr[6:0])
                7'b0110011: begin // R-type
                    case(instr[14:12])
                        3'b000: alu_res <= (instr[30]) ? op1 - op2 : op1 + op2; // ADD/SUB
                        3'b111: alu_res <= op1 & op2; // AND
                        3'b110: alu_res <= op1 | op2; // OR
                        3'b100: alu_res <= op1 ^ op2; // XOR
                        3'b001: alu_res <= op1 << op2[4:0]; // SLL
                        3'b101: alu_res <= (instr[30]) ? $signed(op1) >>> op2[4:0] : op1 >> op2[4:0]; // SRL/SRA
                        default: alu_res <= 32'h0;
                    endcase
                end

                7'b0010011: begin // I-type
                    case(instr[14:12])
                        3'b000: alu_res <= op1 + imm_i; // ADDI
                        3'b111: alu_res <= op1 & imm_i; // ANDI
                        3'b110: alu_res <= op1 | imm_i; // ORI
                        3'b100: alu_res <= op1 ^ imm_i; // XORI
                        3'b001: alu_res <= op1 << imm_i[4:0]; // SLLI
                        3'b101: alu_res <= (instr[30]) ? $signed(op1) >>> imm_i[4:0] : op1 >> imm_i[4:0]; // SRLI/SRAI
                        default: alu_res <= 32'h0;
                    endcase
                end

                7'b0000011: begin // Load
                    mem_addr <= op1 + imm_i;
                    mem_we <= 0;
                    case(instr[14:12])
                        3'b000: alu_res <= $signed({dmem_rdata[7], dmem_rdata[7:0]});   // LB
                        3'b001: alu_res <= $signed({dmem_rdata[15], dmem_rdata[15:0]}); // LH
                        3'b010: alu_res <= dmem_rdata;                                   // LW
                        default: alu_res <= dmem_rdata;
                    endcase
                end

                7'b0100011: begin // Store
                    mem_addr <= op1 + imm_s;
                    mem_wdata <= op2;
                    mem_we <= 1;
                    case(instr[14:12])
                        3'b000: mem_wstrb <= 4'b0001; // SB
                        3'b001: mem_wstrb <= 4'b0011; // SH
                        3'b010: mem_wstrb <= 4'b1111; // SW
                        default: mem_wstrb <= 4'b1111;
                    endcase
                end

                7'b1100011: begin // Branch
                    case(instr[14:12])
                        3'b000: if(op1==op2) begin pc <= pc + imm_b; branch_taken <= 1; end // BEQ
                        3'b001: if(op1!=op2) begin pc <= pc + imm_b; branch_taken <= 1; end // BNE
                        3'b100: if($signed(op1)<$signed(op2)) begin pc <= pc + imm_b; branch_taken <= 1; end // BLT
                        3'b101: if($signed(op1)>=$signed(op2)) begin pc <= pc + imm_b; branch_taken <= 1; end // BGE
                        default: ;
                    endcase
                end

                7'b1101111: begin // JAL
                    if(rd!=0) regs[rd] <= pc + 4;
                    pc <= pc + imm_j;
                end

                7'b1100111: begin // JALR
                    if(rd!=0) regs[rd] <= pc + 4;
                    pc <= (op1 + imm_i) & ~1;
                end

                default: alu_res <= 32'h0;
            endcase

            // ===== Writeback =====
            if(rd!=0 && instr[6:0]!=7'b0100011) begin // x0 protection and store
                regs[rd] <= alu_res;
            end

            // ===== Increment PC =====
            if(instr[6:0] != 7'b1100011 && instr[6:0] != 7'b1101111 && instr[6:0] != 7'b1100111) begin
                pc <= pc + 4;
            end
        end
    end

endmodule

