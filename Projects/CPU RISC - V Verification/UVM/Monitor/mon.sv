
// riscv_monitor.sv
// Passive monitor for RISC-V CPU verification

class riscv_monitor extends uvm_monitor;

    `uvm_component_utils(riscv_monitor)

    // Virtual interface
    virtual riscv_if vif;

    // Analysis ports
    uvm_analysis_port #(riscv_txn) instr_ap;
    uvm_analysis_port #(mem_txn)   mem_ap;

    function new(string name="riscv_monitor", uvm_component parent=null);
        super.new(name, parent);
        instr_ap = new("instr_ap", this);
        mem_ap   = new("mem_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual riscv_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Virtual interface not set for riscv_monitor")
    endfunction

    task run_phase(uvm_phase phase);
        riscv_txn itxn;
        mem_txn   mtxn;

        forever begin
            @(posedge vif.clk);

            if (vif.reset)
                continue;

            // ================================
            // Instruction Fetch Observation
            // ================================
            itxn = riscv_txn::type_id::create("itxn");
            itxn.pc    = vif.pc_out;
            itxn.instr = vif.imem_rdata;
          foreach (itxn.regs_data[i])
  			  itxn.regs_data[i] = vif.regs_out[i];

            instr_ap.write(itxn);

            `uvm_info("MON",
                $sformatf("Observed instr=0x%08h at PC=0x%08h",
                          itxn.instr, itxn.pc),
                UVM_LOW
            );

            // ================================
            // Memory Operation Observation
            // ================================
            if (vif.dmem_we || (vif.dmem_addr != 0)) begin
                mtxn = mem_txn::type_id::create("mtxn");
                mtxn.addr     = vif.dmem_addr;
                mtxn.wdata    = vif.dmem_wdata;
                mtxn.wstrb    = vif.dmem_wstrb;
                mtxn.is_write = vif.dmem_we;
                mtxn.rdata    = vif.dmem_rdata;

                mem_ap.write(mtxn);

                `uvm_info("MON",
                    $sformatf("MEM %s addr=0x%08h wdata=0x%08h rdata=0x%08h wstrb=%b",
                              mtxn.is_write ? "WRITE" : "READ",
                              mtxn.addr, mtxn.wdata, mtxn.rdata, mtxn.wstrb),
                    UVM_LOW
                );
            end
        end
    endtask

endclass
