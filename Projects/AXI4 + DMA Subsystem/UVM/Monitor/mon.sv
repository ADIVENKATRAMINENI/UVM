//==========================================================
// dma_monitor.sv
// AXI4 Monitor for DMA subsystem
//==========================================================
`include "dma_pkg.sv"

class dma_monitor extends uvm_monitor;
    `uvm_component_utils(dma_monitor)

    // -----------------------------------------------------
    // Virtual interface
    // -----------------------------------------------------
    virtual axi_if mon_axi;

    // -----------------------------------------------------
    // Analysis port to send observed transactions
    // -----------------------------------------------------
    uvm_analysis_port #(dma_txn) mon_ap;

    // -----------------------------------------------------
    // Constructor
    // -----------------------------------------------------
    function new(string name = "dma_monitor", uvm_component parent);
        super.new(name, parent);
        mon_ap = new("mon_ap", this);
    endfunction

    // -----------------------------------------------------
    // BUILD PHASE
    // Fetch virtual interface from config DB
    // -----------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", mon_axi)) begin
            `uvm_fatal("NOVIF", "AXI monitor: virtual interface not found in config DB")
        end
    endfunction

    // -----------------------------------------------------
    // RUN PHASE
    // Main sampling process
    // -----------------------------------------------------
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        fork
            collect_read_address();
            collect_read_data();
            collect_write_address();
            collect_write_data();
        join_none
    endtask

    // =====================================================
    // AXI READ ADDRESS CHANNEL (AR)
    // =====================================================
    task collect_read_address();
        dma_txn tr;
        forever begin
            @(posedge mon_axi.clk);
            if (mon_axi.ar_valid && mon_axi.ar_ready) begin
                tr = dma_txn::type_id::create("read_tr");
                tr.addr  = mon_axi.ar_addr;
                tr.len   = mon_axi.ar_len;
                tr.size  = mon_axi.ar_size;
                tr.burst = mon_axi.ar_burst;
                tr.dir   = DMA_READ;

                mon_ap.write(tr);
                `uvm_info("MON", $sformatf("Captured READ AR addr=%0h len=%0d", tr.addr, tr.len), UVM_LOW)
            end
        end
    endtask

    // =====================================================
    // AXI READ DATA CHANNEL (R)
    // =====================================================
    task collect_read_data();
        dma_txn tr;
        forever begin
            @(posedge mon_axi.clk);

            if (mon_axi.r_valid && mon_axi.r_ready) begin
                tr = dma_txn::type_id::create("read_data_tr");
                tr.data  = mon_axi.r_data;
                tr.last  = mon_axi.r_last;
                tr.dir   = DMA_READ_DATA;

                mon_ap.write(tr);

                `uvm_info("MON", $sformatf("Captured READ DATA data=%0h last=%0b", tr.data, tr.last), UVM_LOW)
            end
        end
    endtask

    // =====================================================
    // AXI WRITE ADDRESS CHANNEL (AW)
    // =====================================================
    task collect_write_address();
        dma_txn tr;
        forever begin
            @(posedge mon_axi.clk);
            if (mon_axi.aw_valid && mon_axi.aw_ready) begin
                tr = dma_txn::type_id::create("write_tr");
                tr.addr  = mon_axi.aw_addr;
                tr.len   = mon_axi.aw_len;
                tr.size  = mon_axi.aw_size;
                tr.burst = mon_axi.aw_burst;
                tr.dir   = DMA_WRITE;

                mon_ap.write(tr);

                `uvm_info("MON", $sformatf("Captured WRITE AW addr=%0h len=%0d", tr.addr, tr.len), UVM_LOW)
            end
        end
    endtask

    // =====================================================
    // AXI WRITE DATA CHANNEL (W)
    // =====================================================
    task collect_write_data();
        dma_txn tr;
        forever begin
            @(posedge mon_axi.clk);
            if (mon_axi.w_valid && mon_axi.w_ready) begin
                tr = dma_txn::type_id::create("write_data_tr");
                tr.data = mon_axi.w_data;
                tr.strb = mon_axi.w_strb;
                tr.last = mon_axi.w_last;
                tr.dir  = DMA_WRITE_DATA;

                mon_ap.write(tr);

                `uvm_info("MON", $sformatf("Captured WRITE DATA data=%0h last=%0b", tr.data, tr.last), UVM_LOW)
            end
        end
    endtask

endclass

