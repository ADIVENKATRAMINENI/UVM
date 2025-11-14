`timescale 1ns/1ps

module fifo_dut #(
  parameter int DATA_WIDTH         = 8,
  parameter int DEPTH              = 16,       // power of 2 recommended
  parameter int ALMOST_FULL_LEVEL  = 15,       // assert when occupancy >= this
  parameter int ALMOST_EMPTY_LEVEL = 1,        // assert when occupancy <= this
  localparam int PTR_W             = $clog2(DEPTH)
)(
  input  logic                  clk,
  input  logic                  rst_n,
  // write/read controls
  input  logic                  wr_en,
  input  logic                  rd_en,
  // data
  input  logic [DATA_WIDTH-1:0] din,
  output logic [DATA_WIDTH-1:0] dout,
  // flags
  output logic                  full,
  output logic                  empty,
  output logic                  almost_full,
  output logic                  almost_empty
);

  // Pointers with extra MSB for wrap detection
  typedef logic [PTR_W:0] ptr_t;  // {wrap, idx[PTR_W-1:0]}
  ptr_t wr_ptr, rd_ptr;

  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Full/Empty with pointer-MSB method
  wire same_idx  = (wr_ptr[PTR_W-1:0] == rd_ptr[PTR_W-1:0]);
  wire same_wrap = (wr_ptr[PTR_W]     == rd_ptr[PTR_W]);
  assign empty   =  same_idx &&  same_wrap;
  assign full    =  same_idx && !same_wrap;

  // Combinational occupancy from pointer difference (no counter register).
  // With extra MSB, subtraction yields 0..DEPTH in single-clock FIFOs.
  wire [PTR_W:0] occupancy = wr_ptr - rd_ptr;

  // Almost flags from occupancy (combinational)
  always_comb begin
    almost_full  = (occupancy >= ALMOST_FULL_LEVEL);
    almost_empty = (occupancy <= ALMOST_EMPTY_LEVEL);
  end

  // Full-bypass acceptance:
  // - Accept write when: wr_en && ( !full || (full && rd_en) )
  // - Accept read  when: rd_en && !empty
  wire accept_write = wr_en && ( !full || (full && rd_en) );
  wire accept_read  = rd_en && !empty;

  // Write path
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr <= '0;
    end else if (accept_write) begin
      mem[wr_ptr[PTR_W-1:0]] <= din;
      wr_ptr <= wr_ptr + 1'b1;
    end
  end

  // Read path
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rd_ptr <= '0;
      dout   <= '0;
    end else if (accept_read) begin
      dout   <= mem[rd_ptr[PTR_W-1:0]];
      rd_ptr <= rd_ptr + 1'b1;
    end
  end

endmodule