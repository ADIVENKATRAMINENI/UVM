// riscv_seq_pkg.sv
package riscv_seq_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // =========================================================
    // Transaction item for instruction execution
    // Supports: PC tracking, instruction value, ALU operations
    // =========================================================
    class riscv_txn extends uvm_sequence_item;
        // Instruction to execute
        rand bit [31:0] instr;

        // PC associated with instruction
        rand bit [31:0] pc;
      bit [31:0] regs_data [0:31];


        // Optional decoded info for scoreboard / monitor
        bit [4:0] rd;
        bit [4:0] rs1;
        bit [4:0] rs2;
        bit [31:0] op1;
        bit [31:0] op2;
        bit [31:0] alu_res;
        bit        branch_taken;

        `uvm_object_utils(riscv_txn)

        // Constructor
        function new(string name="riscv_txn");
            super.new(name);
        endfunction

        // Optional: print for debugging
        function void do_print();
            `uvm_info("RISCV_TXN", $sformatf("PC: 0x%0h, INSTR: 0x%0h, RD:%0d RS1:%0d RS2:%0d ALU_RES:0x%0h BR:%0b",
                                            pc, instr, rd, rs1, rs2, alu_res, branch_taken), UVM_LOW)
        endfunction
    endclass

    // =========================================================
    // Memory access transaction
    // Supports: load/store, data, byte/half/word, write-enable
    // =========================================================
    class mem_txn extends uvm_sequence_item;
        rand bit [31:0] addr;       // memory address
        rand bit [31:0] wdata;      // data to write
        rand bit [3:0]  wstrb;      // write strobe (byte-enable)
        rand bit        is_write;   // 1=write, 0=read

        bit [31:0] rdata;           // data read from memory (observed)

        `uvm_object_utils(mem_txn)

        function new(string name="mem_txn");
            super.new(name);
        endfunction

        // Optional: print for debugging
        function void do_print();
            string type_str;
            type_str = is_write ? "WRITE" : "READ";
            `uvm_info("MEM_TXN", $sformatf("%s: ADDR:0x%0h WDATA:0x%0h WSTRB:0b%b RDATA:0x%0h",
                                          type_str, addr, wdata, wstrb, rdata), UVM_LOW)
        endfunction
    endclass

endpackage

