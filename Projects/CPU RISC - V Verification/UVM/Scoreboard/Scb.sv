// riscv_scoreboard.sv
class riscv_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(riscv_scoreboard)

    // -----------------------------------
    // Analysis imports
    // -----------------------------------
    uvm_analysis_imp #(riscv_txn, riscv_scoreboard) instr_imp;
    uvm_analysis_imp #(mem_txn,   riscv_scoreboard) mem_imp;

    // -----------------------------------
    // Expected architectural state
    // -----------------------------------
    bit [31:0] exp_pc;
    bit [31:0] exp_regs [0:31];

    // -----------------------------------
    // Constructor
    // -----------------------------------
    function new(string name="riscv_scoreboard", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    // -----------------------------------
    // Build phase
    // -----------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        instr_imp = new("instr_imp", this);
        mem_imp   = new("mem_imp", this);

        // Reset expected state
        exp_pc = 32'h0;
        foreach (exp_regs[i])
            exp_regs[i] = 32'h0;
    endfunction

    // -----------------------------------
    // Instruction checking
    // -----------------------------------
    function void write(riscv_txn txn);

        `uvm_info("SB",
            $sformatf("Checking PC=0x%08h INSTR=0x%08h",
                      txn.pc, txn.instr),
            UVM_LOW)

        // -----------------------------------
        // 1️⃣ PC CHECK
        // -----------------------------------
        if (txn.pc !== exp_pc) begin
            `uvm_error("SB",
                $sformatf("PC MISMATCH: Expected=0x%08h Got=0x%08h",
                          exp_pc, txn.pc))
        end

        // -----------------------------------
        // 2️⃣ Instruction decode
        // -----------------------------------
        bit [6:0] opcode = txn.instr[6:0];
        bit [4:0] rd     = txn.instr[11:7];
        bit [4:0] rs1    = txn.instr[19:15];
        bit [4:0] rs2    = txn.instr[24:20];

        // -----------------------------------
        // 3️⃣ Execute golden model
        // -----------------------------------
        case (opcode)

            // -------- R-TYPE (ADD only) --------
            7'b0110011: begin
                bit [31:0] result;
                result = exp_regs[rs1] + exp_regs[rs2];

                if (rd != 0)
                    exp_regs[rd] = result;

                exp_pc += 4;
            end

            // -------- ADDI --------
            7'b0010011: begin
                bit [31:0] imm;
                imm = {{20{txn.instr[31]}}, txn.instr[31:20]};

                if (rd != 0)
                    exp_regs[rd] = exp_regs[rs1] + imm;

                exp_pc += 4;
            end

            default: begin
                `uvm_warning("SB",
                    $sformatf("Unsupported opcode: %b", opcode))
                exp_pc += 4;
            end

        endcase

        // -----------------------------------
        // 4️⃣ REGISTER COMPARISON
        // -----------------------------------
        foreach (exp_regs[i]) begin

            // x0 must always be zero
            if (i == 0) begin
              if (txn.regs_data[i] !== 32'h0) begin
                    `uvm_error("SB",
                        $sformatf("x0 modified! DUT=0x%08h",
                                  txn.regs_data[i]))
                end
                continue;
            end

            // Expected vs Actual
          if (exp_regs[i] !== txn.regs_data[i]) begin
                `uvm_error("SB",
                    $sformatf(
                        "REG MISMATCH x%0d: Expected=0x%08h Got=0x%08h (PC=0x%08h)",
                      i, exp_regs[i], txn.regs_data[i], txn.pc
                    ))
            end
        end

    endfunction

    // -----------------------------------
    // Memory checking (stub for now)
    // -----------------------------------
    // Memory transaction checker
function void write(mem_txn txn);

    // -------------------------------
    // STORE (SW)
    // -------------------------------
    if (txn.is_write) begin

        // Update expected memory
        exp_mem[txn.addr] = txn.wdata;

        `uvm_info("SB_MEM",
            $sformatf("STORE addr=0x%08h data=0x%08h",
                      txn.addr, txn.wdata),
            UVM_LOW
        );

    end
    // -------------------------------
    // LOAD (LW)
    // -------------------------------
    else begin

        // Check only if address exists
        if (exp_mem.exists(txn.addr)) begin

            // Compare expected vs DUT read data
            if (txn.rdata !== exp_mem[txn.addr]) begin
                `uvm_error("SB_MEM",
                    $sformatf(
                        "LOAD MISMATCH addr=0x%08h exp=0x%08h got=0x%08h",
                        txn.addr,
                        exp_mem[txn.addr],
                        txn.rdata
                    )
                );
            end
            else begin
                `uvm_info("SB_MEM",
                    $sformatf(
                        "LOAD OK addr=0x%08h data=0x%08h",
                        txn.addr,
                        txn.rdata
                    ),
                    UVM_LOW
                );
            end

        end
        else begin
            `uvm_warning("SB_MEM",
                $sformatf(
                    "LOAD from uninitialized address 0x%08h",
                    txn.addr
                )
            );
        end

    end

endfunction


endclass

