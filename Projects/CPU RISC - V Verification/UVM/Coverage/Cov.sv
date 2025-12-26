//======================================================
// RISC-V Functional Coverage Component
//======================================================

class riscv_coverage extends uvm_component;

    `uvm_component_utils(riscv_coverage)

    // ---------------------------------------------
    // Analysis implementations (receive from monitor)
    // ---------------------------------------------
    uvm_analysis_imp #(riscv_txn, riscv_coverage) instr_imp;
    uvm_analysis_imp #(mem_txn,   riscv_coverage) mem_imp;

    // ---------------------------------------------
    // Local variables used by covergroups
    // ---------------------------------------------
    bit [31:0] instr;
    bit [31:0] addr;
    bit        is_write;
    bit [3:0]  wstrb;

    // ---------------------------------------------
    // Instruction Coverage Group
    // ---------------------------------------------
    covergroup instr_cg;
        option.per_instance = 1;

        // Opcode coverage
        opcode_cp : coverpoint instr[6:0] {
            bins R_TYPE = {7'b0110011};
            bins ADDI   = {7'b0010011};
            bins LOAD   = {7'b0000011};
            bins STORE  = {7'b0100011};
        }

        // Destination register coverage
        rd_cp : coverpoint instr[11:7] {
            bins regs[] = {[0:31]};
        }

        // Source register 1 coverage
        rs1_cp : coverpoint instr[19:15] {
            bins regs[] = {[0:31]};
        }

        // Source register 2 coverage
        rs2_cp : coverpoint instr[24:20] {
            bins regs[] = {[0:31]};
        }

        // Cross: which instructions write to which registers
        opcode_x_rd : cross opcode_cp, rd_cp;

    endgroup


    // ---------------------------------------------
    // Memory Coverage Group
    // ---------------------------------------------
    covergroup mem_cg;
        option.per_instance = 1;

        // Read vs Write
        rw_cp : coverpoint is_write {
            bins READ  = {0};
            bins WRITE = {1};
        }

        // Address ranges
        addr_cp : coverpoint addr {
            bins low  = {[32'h0000_0000 : 32'h0000_00FF]};
            bins mid  = {[32'h0000_0100 : 32'h0000_0FFF]};
        }

        // Write strobe coverage
        wstrb_cp : coverpoint wstrb {
            bins byte = {4'b0001};
            bins half = {4'b0011};
            bins word = {4'b1111};
        }

        // Cross: Read/Write across address regions
        rw_x_addr : cross rw_cp, addr_cp;

    endgroup


    // ---------------------------------------------
    // Constructor
    // ---------------------------------------------
    function new(string name="riscv_coverage", uvm_component parent=null);
        super.new(name, parent);
    endfunction


    // ---------------------------------------------
    // Build Phase
    // ---------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        instr_imp = new("instr_imp", this);
        mem_imp   = new("mem_imp", this);

        instr_cg = new();
        mem_cg   = new();
    endfunction


    // ---------------------------------------------
    // Instruction transaction write() callback
    // Called by monitor via instr_ap
    // ---------------------------------------------
    function void write(riscv_txn txn);
        instr = txn.instr;
        instr_cg.sample();

        `uvm_info("COV",
            $sformatf("Instruction sampled: 0x%08h", instr),
            UVM_LOW)
    endfunction


    // ---------------------------------------------
    // Memory transaction write() callback
    // Called by monitor via mem_ap
    // ---------------------------------------------
    function void write(mem_txn txn);
        addr     = txn.addr;
        is_write = txn.is_write;
        wstrb    = txn.wstrb;

        mem_cg.sample();

        `uvm_info("COV",
            $sformatf("Memory sampled: %s addr=0x%08h wstrb=%b",
                      is_write ? "WRITE" : "READ",
                      addr, wstrb),
            UVM_LOW)
    endfunction

endclass

