`timescale 1ns/1ps
module tb_top;
  import uvm_pkg::*;
  import axi_pkg::*;

  // Parameters
  localparam int ADDR_WIDTH = 8;
  localparam int DATA_WIDTH = 32;
  localparam int NUM_REGS   = 16;

  // Clock and Reset
  logic ACLK;
  initial ACLK = 0;
  always #5 ACLK = ~ACLK; // 100 MHz

  logic ARESETn;
  initial begin
    ARESETn = 0;
    repeat (5) @(posedge ACLK);
    ARESETn = 1;
  end

  // Interface
  axi_if #(ADDR_WIDTH, DATA_WIDTH) vif(ACLK, ARESETn);

  // DUT instantiation
  axi_lite_slave #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_REGS(NUM_REGS)
  ) dut (
    .ACLK    (ACLK),
    .ARESETn (ARESETn),

    .AWVALID (vif.AWVALID),
    .AWREADY (vif.AWREADY),
    .AWADDR  (vif.AWADDR),

    .WVALID  (vif.WVALID),
    .WREADY  (vif.WREADY),
    .WDATA   (vif.WDATA),
    .WSTRB   (vif.WSTRB),

    .BVALID  (vif.BVALID),
    .BREADY  (vif.BREADY),
    .BRESP   (vif.BRESP),

    .ARVALID (vif.ARVALID),
    .ARREADY (vif.ARREADY),
    .ARADDR  (vif.ARADDR),

    .RVALID  (vif.RVALID),
    .RREADY  (vif.RREADY),
    .RDATA   (vif.RDATA),
    .RRESP   (vif.RRESP)
  );

  // UVM configuration for driver and monitor
  initial begin
    // Driver virtual interface
    uvm_config_db#(virtual axi_if.DRIVER)::set(null, "uvm_test_top", "vif_drv", vif);
    // Monitor virtual interface
    uvm_config_db#(virtual axi_if.MONITOR)::set(null, "uvm_test_top", "vif_mon", vif);

    // Run UVM test (change test name as needed)
    run_test(); // +UVM_TESTNAME=smoke_test
  end

endmodule

