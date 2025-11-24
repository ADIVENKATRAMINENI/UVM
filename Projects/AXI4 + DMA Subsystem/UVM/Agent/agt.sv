`include "dma_pkg.sv"

class dma_agent extends uvm_agent;
    `uvm_component_utils(dma_agent)

    // Components inside agent
    dma_sequencer   sqr;
    dma_driver      drv;
    dma_monitor     mon;

    // Virtual interfaces
    virtual cfg_if  vif_cfg;
    virtual axi_if  vif_axi;

    // Agent configuration controls
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    // -------------------------
    // Constructor
    // -------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // -------------------------
    // build_phase
    // -------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Get interfaces from config DB
        if(!uvm_config_db#(virtual cfg_if)::get(this, "", "vif_cfg", vif_cfg))
            `uvm_fatal("NOCFGVIF", "dma_agent: cfg_if not found in config DB")

        if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif_axi", vif_axi))
            `uvm_fatal("NOAXIVIF", "dma_agent: axi_if not found in config DB")

        // Build monitor always
        mon = dma_monitor::type_id::create("mon", this);

        // Build active components only when agent is ACTIVE
        if (is_active == UVM_ACTIVE) begin
            sqr = dma_sequencer::type_id::create("sqr", this);
            drv = dma_driver  ::type_id::create("drv", this);
        end
    endfunction

    // -------------------------
    // connect_phase
    // -------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Pass interfaces to sub-components
        mon.mon_axi = vif_axi;

        if (is_active == UVM_ACTIVE) begin
            drv.drv_cfg = vif_cfg;
            drv.drv_axi = vif_axi;

            // Sequencer <-> Driver connection
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
    endfunction

endclass

