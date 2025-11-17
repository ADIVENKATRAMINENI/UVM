// test bench top module             
             
`timescale 1ns/1ps
module tb_top;
  import uvm_pkg::*;
  import uart_pkg::*;

  localparam int DATA_WIDTH = 8;
  localparam int BAUD_DIV   = 16; // clk cycles per bit

  logic clk;
  initial clk = 0;
  always #5 clk = ~clk; // 100 MHz

  logic baud_tick;
  logic [7:0] baud_cnt;

  // simple baud generator
  always_ff @(posedge clk) begin
    baud_cnt  <= baud_cnt + 1'b1;
    if (baud_cnt == BAUD_DIV-1) begin
      baud_cnt  <= '0;
      baud_tick <= 1'b1;
    end else begin
      baud_tick <= 1'b0;
    end
  end

  uart_if vif(clk);

  // Reset
  initial begin
    vif.rst_n = 0;
    baud_cnt  = '0;
    baud_tick = 0;
    repeat (5) @(posedge clk);
    vif.rst_n = 1;
  end

  // DUTs: TX and RX with loopback
  uart_tx #(.DATA_WIDTH(DATA_WIDTH)) u_tx (
    .clk      (clk),
    .rst_n    (vif.rst_n),
    .tx_start (vif.tx_start),
    .tx_data  (vif.tx_data),
    .baud_tick(baud_tick),
    .tx_line  (vif.serial_line),
    .tx_busy  (vif.tx_busy)
  );

  uart_rx #(.DATA_WIDTH(DATA_WIDTH)) u_rx (
    .clk      (clk),
    .rst_n    (vif.rst_n),
    .rx_line  (vif.serial_line),
    .baud_tick(baud_tick),
    .rx_data  (vif.rx_data),
    .rx_valid (vif.rx_valid)
  );

  // Hook up VIF to UVM
  initial begin
    uvm_config_db#(virtual uart_if.drv)::set(null, "uvm_test_top", "vif_drv", vif);
    uvm_config_db#(virtual uart_if.mon)::set(null, "uvm_test_top", "vif_mon", vif);
    run_test(); // e.g. +UVM_TESTNAME=smoke_test
  end

endmodule
