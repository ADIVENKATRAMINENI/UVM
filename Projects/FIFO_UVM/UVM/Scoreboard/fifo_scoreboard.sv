`ifndef FIFO_SCOREBOARD_SV
`define FIFO_SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;


class fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fifo_scoreboard)

  uvm_analysis_imp #(fifo_write_s, fifo_scoreboard) imp_wr;
  uvm_analysis_imp #(fifo_read_s,  fifo_scoreboard) imp_rd;

  bit [7:0] ref_q[$];

  int unsigned DEPTH;
  int unsigned PTR_W;

  typedef struct {
    int unsigned idx;
    bit          wrap;
  } ptr_shadow;

  ptr_shadow wr_ptr;
  ptr_shadow rd_ptr;

  function new(string name = "fifo_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    imp_wr = new("imp_wr", this);
    imp_rd = new("imp_rd", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(int unsigned)::get(this, "", "DEPTH", DEPTH))
      DEPTH = 16;

    PTR_W = (DEPTH <= 1) ? 1 : $clog2(DEPTH);
    reset_model();
  endfunction

  function void reset_model();
    ref_q.delete();
    wr_ptr = '{idx:0, wrap:0};
    rd_ptr = '{idx:0, wrap:0};
  endfunction

  function bit empty_shadow();
    return (wr_ptr.idx == rd_ptr.idx) && (wr_ptr.wrap == rd_ptr.wrap);
  endfunction

  function bit full_shadow();
    return (wr_ptr.idx == rd_ptr.idx) && (wr_ptr.wrap != rd_ptr.wrap);
  endfunction

  function void write(fifo_write_s t);
    if (full_shadow())
      `uvm_error("SCORE", "Write seen while FULL in shadow");

    ref_q.push_back(t.data);

    if (wr_ptr.idx == (DEPTH - 1)) begin
      wr_ptr.idx  = 0;
      wr_ptr.wrap = ~wr_ptr.wrap;
    end
    else begin
      wr_ptr.idx++;
    end
  endfunction

  function void write(fifo_read_s t);
    if (empty_shadow())
      `uvm_error("SCORE", "Read seen while EMPTY in shadow");

    if (ref_q.size() == 0)
      `uvm_error("SCORE", "Ref underflow");
    else begin
      bit [7:0] exp;
      exp = ref_q.pop_front();

      if (exp !== t.data)
        `uvm_error("SCORE",
                   $sformatf("DATA MISMATCH exp=0x%0h got=0x%0h", exp, t.data));
    end

    if (rd_ptr.idx == (DEPTH - 1)) begin
      rd_ptr.idx  = 0;
      rd_ptr.wrap = ~rd_ptr.wrap;
    end
    else begin
      rd_ptr.idx++;
    end
  endfunction

endclass

`endif
