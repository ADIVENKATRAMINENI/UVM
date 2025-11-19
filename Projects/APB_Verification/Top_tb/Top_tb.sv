             
`timescale 1ns/1ps
module tb_top;
  import uvm_pkg::*;
  import apb_pkg::*;

  localparam int ADDR_WIDTH = 8;
  localparam int DATA_WIDTH = 32;
  localparam int NUM_REGS   = 16;

  logic PCLK;
  initial PCLK = 0;
  always #5 PCLK = ~PCLK; // 100 MHz

  apb_if #(ADDR_WIDTH, DATA_WIDTH) vif(PCLK);

  // Reset
  initial begin
    vif.PRESETn = 0;
    repeat (5) @(posedge PCLK);
    vif.PRESETn = 1;
  end

  // DUT
  apb_slave #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_REGS  (NUM_REGS)
  ) dut (
    .PCLK   (PCLK),
    .PRESETn(vif.PRESETn),
    .PSEL   (vif.PSEL),
    .PENABLE(vif.PENABLE),
    .PWRITE (vif.PWRITE),
    .PADDR  (vif.PADDR),
    .PWDATA (vif.PWDATA),
    .PRDATA (vif.PRDATA),
    .PREADY (vif.PREADY),
    .PSLVERR(vif.PSLVERR)
  );

  // Connect VIF to UVM
  initial begin
    uvm_config_db#(virtual apb_if.drv)::set(null, "uvm_test_top", "vif_drv", vif);
    uvm_config_db#(virtual apb_if.mon)::set(null, "uvm_test_top", "vif_mon", vif);
    run_test(); // e.g. +UVM_TESTNAME=smoke_test
  end

endmodule

