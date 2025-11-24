// dma_coverage.sv
`include "dma_pkg.sv"

class dma_coverage extends uvm_component;
  `uvm_component_utils(dma_coverage)

  // TLM imports — receives transactions from sequences and monitor
  uvm_analysis_imp#(dma_txn    , dma_coverage) imp_cfg;
  uvm_analysis_imp#(axi_write_s, dma_coverage) imp_wr;
  uvm_analysis_imp#(axi_read_s , dma_coverage) imp_rd;

  // -----------------------------------------------------
  // Covergroup 1: DMA configuration coverage (txn-level)
  // -----------------------------------------------------
  covergroup dma_cfg_cg with function sample(dma_txn t);
    option.per_instance = 1;

    src_addr : coverpoint t.src_addr {
      bins low_range   = {[32'h0000_0000 : 32'h0000_0FFF]};
      bins mid_range   = {[32'h0000_1000 : 32'h0000_1FFF]};
      bins high_range  = {[32'h0000_2000 : 32'h0000_FFFF]};
    }

    dst_addr : coverpoint t.dst_addr {
      bins low_range   = {[32'h0000_0000 : 32'h0000_0FFF]};
      bins mid_range   = {[32'h0000_1000 : 32'h0000_1FFF]};
      bins high_range  = {[32'h0000_2000 : 32'h0000_FFFF]};
    }

    length_cp : coverpoint t.len {
      bins small_len   = {[1 : 64]};
      bins medium_len  = {[65 : 512]};
      bins large_len   = {[513 : 2048]};
    }

    // Simple cross — safe for beginners
    src_dst_cross : cross src_addr, dst_addr;
  endgroup


  // -----------------------------------------------------
  // Covergroup 2: AXI beat-level coverage (monitor port)
  // -----------------------------------------------------
  covergroup axi_burst_cg;
    option.per_instance = 1;

    addr_cp : coverpoint axi_addr {
      bins aligned     = { [0 : 4095] iff (axi_addr % 4 == 0) };
      bins unaligned   = { [0 : 4095] iff (axi_addr % 4 != 0) };
    }

    wstrb_cp : coverpoint axi_wstrb {
      bins full_4bytes = {4'b1111};
      bins half        = {4'b0011, 4'b1100};
      bins single      = {4'b0001, 4'b0010, 4'b0100, 4'b1000};
    }

    // Read/write combined check
    rw_cp : coverpoint axi_is_write {
      bins is_write = {1};
      bins is_read  = {0};
    }
  endgroup


  // Temporary variables for coverage sampling
  bit [31:0] axi_addr;
  bit [3:0]  axi_wstrb;
  bit        axi_is_write;

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    imp_cfg = new("imp_cfg", this);
    imp_wr  = new("imp_wr" , this);
    imp_rd  = new("imp_rd" , this);

    dma_cfg_cg = new();
    axi_burst_cg = new();
  endfunction


  // -------------------------------------------------------------------
  // Receivers (from env.connect_phase)
  // These get called automatically when monitor / sequencer sends data
  // -------------------------------------------------------------------

  // 1️⃣ From sequence: DMA high-level configuration
  function void write(dma_txn t);
    dma_cfg_cg.sample(t);
    `uvm_info("COV", $sformatf("Coverage: sampled DMA txn (src=0x%0h dst=0x%0h len=%0d)",
                               t.src_addr, t.dst_addr, t.len), UVM_LOW);
  endfunction

  // 2️⃣ From monitor: WRITE beat
  function void write(axi_write_s w);
    axi_addr    = w.addr;
    axi_wstrb   = w.wstrb;
    axi_is_write = 1;

    axi_burst_cg.sample();
    `uvm_info("COV", $sformatf("Coverage: sampled AXI WRITE addr=0x%0h wstrb=%b",
                               w.addr, w.wstrb), UVM_LOW);
  endfunction

  // 3️⃣ From monitor: READ beat
  function void write(axi_read_s r);
    axi_addr     = r.addr;
    axi_wstrb    = 4'b0000; // not applicable
    axi_is_write = 0;

    axi_burst_cg.sample();
    `uvm_info("COV", $sformatf("Coverage: sampled AXI READ addr=0x%0h", r.addr),
              UVM_LOW);
  endfunction

endclass

