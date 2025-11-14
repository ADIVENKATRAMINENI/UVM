`ifndef FIFO_COVERAGE_SV
`define FIFO_COVERAGE_SV
`include "uvm_macros.svh"
import uvm_pkg::*;


class fifo_coverage extends uvm_component;
  `uvm_component_utils(fifo_coverage)

  virtual fifo_if.mon vif;

  covergroup fifo_cg @(vif.cb);

    coverpoint vif.wr_en;
    coverpoint vif.rd_en;
    coverpoint vif.full;
    coverpoint vif.empty;
    coverpoint vif.almost_full;
    coverpoint vif.almost_empty;

    wr_full_x:     cross vif.wr_en, vif.full;
    rd_empty_x:    cross vif.rd_en, vif.empty;
    wr_rd_x:       cross vif.wr_en, vif.rd_en;
    bypass_full_x: cross vif.wr_en, vif.full, vif.rd_en;
    almost_x:      cross vif.almost_full, vif.almost_empty;

  endgroup


  function new(string name = "fifo_coverage", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual fifo_if.mon)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for fifo_coverage");

    fifo_cg = new();
  endfunction

endclass

`endif
