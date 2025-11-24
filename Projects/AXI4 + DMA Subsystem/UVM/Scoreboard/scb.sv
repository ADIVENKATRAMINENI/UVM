// dma_scoreboard.sv
`include "dma_pkg.sv"

class dma_scoreboard extends uvm_component;
  `uvm_component_utils(dma_scoreboard)

  // analysis_imps receive TLM transactions from monitor (via connect)
  uvm_analysis_imp#(axi_write_s, dma_scoreboard) imp_wr;
  uvm_analysis_imp#(axi_read_s , dma_scoreboard) imp_rd;

  // reference memory model (word-addressable). Keep size modest for simulation.
  localparam int MEM_WORDS = 4096; // 16 KB if DATA_WIDTH=32
  bit [31:0] ref_mem [0:MEM_WORDS-1];

  // constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    imp_wr = new("imp_wr", this);
    imp_rd = new("imp_rd", this);
  endfunction

  // build phase: initialize reference memory to zero
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    for (int i = 0; i < MEM_WORDS; i++) ref_mem[i] = '0;
    `uvm_info(get_type_name(), $sformatf("Scoreboard: reference memory initialized (%0d words)", MEM_WORDS), UVM_LOW)
  endfunction

  // ------------------------------------------------------------------
  // This method is called automatically by imp_wr when monitor publishes
  // a write beat (axi_write_s).
  // ------------------------------------------------------------------
  function void write(axi_write_s w);
    int idx;
    bit [31:0] oldval, newval;
    idx = w.addr / 4; // assume word aligned address

    if (idx < 0 || idx >= MEM_WORDS) begin
      `uvm_error("SCORE", $sformatf("WRITE: address 0x%0h out of range", w.addr));
      return;
    end

    oldval = ref_mem[idx];
    newval = oldval;

    // Apply byte enables (WSTRB). WSTRB[0] is lowest byte.
    for (int b = 0; b < 4; b++) begin
      if (w.wstrb[b]) begin
        newval[b*8 +: 8] = w.data[b*8 +: 8];
      end
    end

    ref_mem[idx] = newval;

    `uvm_info("SCORE",
      $sformatf("WRITE: addr=0x%0h idx=%0d wdata=0x%0h wstrb=%b old=0x%0h new=0x%0h",
                w.addr, idx, w.data, w.wstrb, oldval, newval),
      UVM_MEDIUM);
  endfunction

  // ------------------------------------------------------------------
  // This method is called automatically by imp_rd when monitor publishes
  // a read beat (axi_read_s).
  // ------------------------------------------------------------------
  function void write(axi_read_s r);
    int idx;
    bit [31:0] expected;

    idx = r.addr / 4; // assume word aligned address

    if (idx < 0 || idx >= MEM_WORDS) begin
      `uvm_error("SCORE", $sformatf("READ: address 0x%0h out of range", r.addr));
      return;
    end

    expected = ref_mem[idx];

    if (expected !== r.data) begin
      `uvm_error("SCORE",
        $sformatf("READ MISMATCH addr=0x%0h idx=%0d exp=0x%0h got=0x%0h",
                  r.addr, idx, expected, r.data));
    end else begin
      `uvm_info("SCORE",
        $sformatf("READ MATCH addr=0x%0h idx=%0d data=0x%0h",
                  r.addr, idx, r.data),
        UVM_LOW);
    end
  endfunction

endclass : dma_scoreboard

