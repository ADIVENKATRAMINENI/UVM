`timescale 1ns/1ps
module axi_lite_slave #(
  parameter int ADDR_WIDTH = 8,
  parameter int DATA_WIDTH = 32,
  parameter int NUM_REGS   = 16
)(
  input  logic                     ACLK,
  input  logic                     ARESETn,

  // Write address channel
  input  logic                     AWVALID,
  output logic                     AWREADY,
  input  logic [ADDR_WIDTH-1:0]    AWADDR,

  // Write data channel
  input  logic                     WVALID,
  output logic                     WREADY,
  input  logic [DATA_WIDTH-1:0]    WDATA,
  input  logic [(DATA_WIDTH/8)-1:0] WSTRB,

  // Write response channel
  output logic                     BVALID,
  input  logic                     BREADY,
  output logic [1:0]               BRESP,

  // Read address channel
  input  logic                     ARVALID,
  output logic                     ARREADY,
  input  logic [ADDR_WIDTH-1:0]    ARADDR,

  // Read data channel
  output logic                     RVALID,
  input  logic                     RREADY,
  output logic [DATA_WIDTH-1:0]    RDATA,
  output logic [1:0]               RRESP
);

  // Register file
  logic [DATA_WIDTH-1:0] regfile [0:NUM_REGS-1];
  logic [$clog2(NUM_REGS)-1:0] index_w, index_r;
  integer i;

  // Zero wait-state slave
  assign AWREADY = 1'b1;
  assign WREADY  = 1'b1;
  assign ARREADY = 1'b1;

  // Responses = OKAY
  assign BRESP = 2'b00;
  assign RRESP = 2'b00;

  // Write logic
  always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
      BVALID <= 0;
      for (i=0; i<NUM_REGS; i++) regfile[i] <= '0;
    end else begin
      if (AWVALID && WVALID) begin
        index_w = AWADDR[$clog2(NUM_REGS)+1 : 2];
        bit [DATA_WIDTH-1:0] oldval = regfile[index_w];
        bit [DATA_WIDTH-1:0] newval = oldval;
        for (int b=0; b<DATA_WIDTH/8; b++)
          if (WSTRB[b]) newval[b*8 +: 8] = WDATA[b*8 +: 8];
        regfile[index_w] <= newval;
        BVALID <= 1'b1;
      end else if (BVALID && BREADY) begin
        BVALID <= 0;
      end
    end
  end

  // Read logic
  always_ff @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
      RVALID <= 0;
      RDATA  <= '0;
    end else begin
      if (ARVALID) begin
        index_r = ARADDR[$clog2(NUM_REGS)+1 : 2];
        RDATA  <= regfile[index_r];
        RVALID <= 1'b1;
      end else if (RVALID && RREADY) begin
        RVALID <= 0;
      end
    end
  end

endmodule

