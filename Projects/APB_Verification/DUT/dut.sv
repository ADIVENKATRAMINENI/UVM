`timescale 1ns/1ps
module apb_slave #(
  parameter int ADDR_WIDTH = 8,
  parameter int DATA_WIDTH = 32,
  parameter int NUM_REGS   = 16
)(
  input  logic                   PCLK,
  input  logic                   PRESETn,
  input  logic                   PSEL,
  input  logic                   PENABLE,
  input  logic                   PWRITE,
  input  logic [ADDR_WIDTH-1:0]  PADDR,
  input  logic [DATA_WIDTH-1:0]  PWDATA,
  output logic [DATA_WIDTH-1:0]  PRDATA,
  output logic                   PREADY,
  output logic                   PSLVERR
);

  logic [DATA_WIDTH-1:0] regfile [0:NUM_REGS-1];

  // Word index: 4-byte aligned
  logic [$clog2(NUM_REGS)-1:0] index;
  assign index = PADDR[5:2];

  // Always ready, no error
  assign PREADY  = 1'b1;
  assign PSLVERR = 1'b0;

  // Read
  always_comb begin
    if (PSEL && !PWRITE && (index < NUM_REGS))
      PRDATA = regfile[index];
    else
      PRDATA = '0;
  end

  // Write
  always_ff @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      integer i;
      for (i = 0; i < NUM_REGS; i++) regfile[i] <= '0;
    end else begin
      if (PSEL && PENABLE && PWRITE && (index < NUM_REGS))
        regfile[index] <= PWDATA;
    end
  end

endmodule

