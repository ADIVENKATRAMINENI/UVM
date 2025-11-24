/*3️⃣ Who samples what inside DUT?

DMA (DUT) samples:
cfg_if signals: start, src_addr, dst_addr, length (driven by driver/TB)
AXI response signals: arready, rvalid, wready, bvalid (driven by memory/slave)

DMA drives:
AXI request signals: araddr/arvalid for reads, awaddr/awvalid & wdata/wvalid for writes

Flow summary:

Source	Signal	Who samples	Who drives
Driver/TB	cfg_if.start/src/dst/len	DMA	TB/Driver
DMA (DUT)	AXI address/data	Memory	DMA
Memory (Slave)	AXI ready/valid	DMA	Memory
DMA (DUT)	cfg_if.done	TB/Driver	DMA


4️⃣ Signal travel paths

Let’s trace one read transaction as example:

Driver sets cfg.start=1, src_addr=0x0, dst_addr=0x100
DMA DUT samples these cfg_if signals → prepares AXI read
DMA drives axi.araddr = src_addr, axi.arvalid=1 → goes to memory slave
Memory slave samples araddr/arvalid, responds with rdata/rvalid
DMA samples rdata/rvalid → stores internally → drives wdata/awaddr/wvalid to memory
Memory samples write request → writes data, sends bvalid

DMA samples bvalid, updates len and addr_dst → repeat or set cfg.done=1

Driver samples cfg.done to know transaction finished

✅ So, signals do not stop at the clocking block. Clocking block is only for the testbench driver/monitor to safely read/write signals. The actual path is:

Driver/TB → DMA (DUT) → Memory (Slave)
Memory → DMA → Driver/TB

*/







`include "dma_pkg.sv"

class dma_driver extends uvm_driver #(dma_txn);
    `uvm_component_utils(dma_driver)

    virtual cfg_if drv_cfg;
    virtual axi_if drv_axi;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual cfg_if)::get(this, "", "vif_cfg", drv_cfg))
            `uvm_fatal("NOVIF", "cfg_if not found! Did you set it in top module?")

        if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif_axi", drv_axi))
            `uvm_fatal("NOVIF", "axi_if not found! Did you set it in top module?")
    endfunction

    virtual task run_phase(uvm_phase phase);
        dma_txn txn;

        forever begin
            seq_item_port.get_next_item(txn);

            @(posedge drv_cfg.clk);
            drv_cfg.src_addr <= txn.src_addr;
            drv_cfg.dst_addr <= txn.dst_addr;
            drv_cfg.length   <= txn.length;
            drv_cfg.start    <= 1;

            @(posedge drv_cfg.clk);
            drv_cfg.start    <= 0;

            wait(drv_cfg.done);
            seq_item_port.item_done();
        end
    endtask
endclass

