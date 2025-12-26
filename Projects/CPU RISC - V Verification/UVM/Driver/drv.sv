// riscv_driver.sv
// Instruction Memory Driver for RISC-V CPU Verification

class riscv_driver extends uvm_driver #(riscv_txn);

    `uvm_component_utils(riscv_driver)

    // Virtual interface to instruction memory
    virtual riscv_if vif;

    function new(string name="riscv_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    // Get virtual interface
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual riscv_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Virtual interface not set for riscv_driver")
    endfunction

    // Main driver loop
    task run_phase(uvm_phase phase);
        riscv_txn txn;

        // Default instruction (NOP = ADDI x0,x0,0)
        vif.imem_rdata <= 32'h00000013;

        forever begin
            seq_item_port.get_next_item(txn);

            drive_instruction(txn);

            seq_item_port.item_done();
        end
    endtask

    // Drive instruction when PC matches
    task drive_instruction(riscv_txn txn);
        // Wait for DUT to request this PC
        @(posedge vif.clk);
        wait(vif.imem_addr == txn.pc);

        // Drive instruction
        vif.imem_rdata <= txn.instr;

        `uvm_info("DRV",
            $sformatf("Driving instr=0x%08h at PC=0x%08h",
                      txn.instr, txn.pc),
            UVM_MEDIUM
        );

        // Hold for one cycle (simple ROM behavior)
        @(posedge vif.clk);

        // Drive NOP after instruction
        vif.imem_rdata <= 32'h00000013;
    endtask

endclass

