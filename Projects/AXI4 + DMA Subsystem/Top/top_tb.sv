`timescale 1ns/1ps
`include "dma_pkg.sv"
import uvm_pkg::*;
import dma_pkg::*;

module tb_top;

    //------------------------------------------
    // Clock and Reset
    //------------------------------------------
    bit clk;
    bit reset_n;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 100MHz clock
    end

    initial begin
        reset_n = 0;
        #100;
        reset_n = 1;
    end


    //------------------------------------------
    // Instantiate Interfaces
    //------------------------------------------
    axi_if axi_if_inst(.clk(clk), .reset_n(reset_n));
    cfg_if cfg_if_inst(.clk(clk), .reset_n(reset_n));


    //------------------------------------------
    // DUT Instantiation (dma)
    //------------------------------------------
    dma dut (
        .clk      (clk),
        .reset_n  (reset_n),

        // cfg_if connections
        .cfg_addr   (cfg_if_inst.addr),
        .cfg_wdata  (cfg_if_inst.wdata),
        .cfg_write  (cfg_if_inst.write),
        .cfg_start  (cfg_if_inst.start),
        .cfg_len    (cfg_if_inst.len),
        .cfg_src    (cfg_if_inst.src),
        .cfg_dst    (cfg_if_inst.dst),
        .cfg_done   (cfg_if_inst.done),

        // AXI interface connections
        .awvalid (axi_if_inst.awvalid),
        .awready (axi_if_inst.awready),
        .awaddr  (axi_if_inst.awaddr),
        .awlen   (axi_if_inst.awlen),
        .awsize  (axi_if_inst.awsize),
        .awburst (axi_if_inst.awburst),

        .wvalid (axi_if_inst.wvalid),
        .wready (axi_if_inst.wready),
        .wdata  (axi_if_inst.wdata),
        .wstrb  (axi_if_inst.wstrb),
        .wlast  (axi_if_inst.wlast),

        .bvalid (axi_if_inst.bvalid),
        .bready (axi_if_inst.bready),
        .bresp  (axi_if_inst.bresp),

        .arvalid (axi_if_inst.arvalid),
        .arready (axi_if_inst.arready),
        .araddr  (axi_if_inst.araddr),
        .arlen   (axi_if_inst.arlen),
        .arsize  (axi_if_inst.arsize),
        .arburst (axi_if_inst.arburst),

        .rvalid (axi_if_inst.rvalid),
        .rready (axi_if_inst.rready),
        .rdata  (axi_if_inst.rdata),
        .rlast  (axi_if_inst.rlast),
        .rresp  (axi_if_inst.rresp)
    );


    //------------------------------------------
    // AXI Memory Model (acts as AXI slave)
    //------------------------------------------
    axi_mem mem (
        .clk     (clk),
        .reset_n (reset_n),

        .awvalid (axi_if_inst.awvalid),
        .awready (axi_if_inst.awready),
        .awaddr  (axi_if_inst.awaddr),
        .awlen   (axi_if_inst.awlen),
        .awsize  (axi_if_inst.awsize),
        .awburst (axi_if_inst.awburst),

        .wvalid  (axi_if_inst.wvalid),
        .wready  (axi_if_inst.wready),
        .wdata   (axi_if_inst.wdata),
        .wstrb   (axi_if_inst.wstrb),
        .wlast   (axi_if_inst.wlast),

        .bvalid  (axi_if_inst.bvalid),
        .bready  (axi_if_inst.bready),
        .bresp   (axi_if_inst.bresp),

        .arvalid (axi_if_inst.arvalid),
        .arready (axi_if_inst.arready),
        .araddr  (axi_if_inst.araddr),
        .arlen   (axi_if_inst.arlen),
        .arsize  (axi_if_inst.arsize),
        .arburst (axi_if_inst.arburst),

        .rvalid  (axi_if_inst.rvalid),
        .rready  (axi_if_inst.rready),
        .rdata   (axi_if_inst.rdata),
        .rlast   (axi_if_inst.rlast),
        .rresp   (axi_if_inst.rresp)
    );


    //------------------------------------------
    // Passing virtual interfaces to UVM
    //------------------------------------------
    initial begin
        uvm_config_db#(virtual axi_if)::set(null, "*", "vif", axi_if_inst);
        uvm_config_db#(virtual cfg_if)::set(null, "*", "cfg_vif", cfg_if_inst);

        run_test();
    end

endmodule

