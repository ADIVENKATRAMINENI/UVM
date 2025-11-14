`timescale 1ns/1ps

module tb_top;
`include "uvm_macros.svh"
  import uvm_pkg::*;

  localparam int DATA_WIDTH         = 8;
  localparam int DEPTH              = 16;
  localparam int ALMOST_FULL_LEVEL  = 14;
  localparam int ALMOST_EMPTY_LEVEL = 2;

  logic clk;
  initial clk = 0;
  always #5 clk = ~clk;   // 100 MHz

  // Interface instance
  fifo_if #(DATA_WIDTH) vif (clk);

  // Reset
  initial begin
    vif.rst_n = 0;
    repeat (5) @(posedge clk);
    vif.rst_n = 1;
  end

  // DUT instance (name must match your RTL file: fifo_dut.sv)
  fifo_dut #(
    .DATA_WIDTH         (DATA_WIDTH),
    .DEPTH              (DEPTH),
    .ALMOST_FULL_LEVEL  (ALMOST_FULL_LEVEL),
    .ALMOST_EMPTY_LEVEL (ALMOST_EMPTY_LEVEL)
  ) dut (
    .clk          (clk),
    .rst_n        (vif.rst_n),
    .wr_en        (vif.wr_en),
    .rd_en        (vif.rd_en),
    .din          (vif.din),
    .dout         (vif.dout),
    .full         (vif.full),
    .empty        (vif.empty),
    .almost_full  (vif.almost_full),
    .almost_empty (vif.almost_empty)
  );

  // Hook interface and depth into UVM config_db and start test
  initial begin
    // pass vif to base_test (vif_drv / vif_mon)
    uvm_config_db#(virtual fifo_if.drv)::set(null, "uvm_test_top", "vif_drv", vif);
    uvm_config_db#(virtual fifo_if.mon)::set(null, "uvm_test_top", "vif_mon", vif);

    // optional: top-level DEPTH (base_test already sets env.scb.DEPTH)
    uvm_config_db#(int unsigned)::set(null, "uvm_test_top", "DEPTH", DEPTH);

    // Either use +UVM_TESTNAME=random_test on the command line
    // or hardcode a test name here:
    // run_test("smoke_test");
    run_test();  // use +UVM_TESTNAME=<test> in simulation settings
  end

endmodule
