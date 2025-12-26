// riscv_agent.sv
// UVM Agent for RISC-V CPU Verification

class riscv_agent extends uvm_agent;

    `uvm_component_utils(riscv_agent)

    // Agent components
    riscv_sequencer sequencer;
    riscv_driver    driver;
    riscv_monitor   monitor;

    // Agent mode
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    function new(string name="riscv_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    // -----------------------------------
    // Build Phase
    // -----------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Get active/passive mode (optional override)
        uvm_config_db#(uvm_active_passive_enum)::get(
            this, "", "is_active", is_active
        );

        // Always create monitor
        monitor = riscv_monitor::type_id::create("monitor", this);

        // Create sequencer & driver only if ACTIVE
        if (is_active == UVM_ACTIVE) begin
            sequencer = riscv_sequencer::type_id::create("sequencer", this);
            driver    = riscv_driver   ::type_id::create("driver", this);
        end
    endfunction

    // -----------------------------------
    // Connect Phase
    // -----------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction

endclass

