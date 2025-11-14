`ifndef FIFO_MONITOR_SV
`define FIFO_MONITOR_SV
`include "uvm_macros.svh"
import uvm_pkg::*;


typedef struct packed {
  bit [7:0] data;
} fifo_write_s;

typedef struct packed {
  bit [7:0] data;
} fifo_read_s;


class fifo_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_monitor)

  virtual fifo_if.mon vif;

  uvm_analysis_port #(fifo_write_s) ap_write;
  uvm_analysis_port #(fifo_read_s)  ap_read;

  function new(string name = "fifo_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap_write = new("ap_write", this);
    ap_read  = new("ap_read",  this);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual fifo_if.mon)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for fifo_monitor");
  endfunction


  task run_phase(uvm_phase phase);
    fifo_write_s w;
    fifo_read_s  r;

    forever begin
      @(vif.cb);    // use clocking block for sampling

      if (vif.wr_en && (!vif.full || (vif.full && vif.rd_en))) begin
        w.data = vif.din;
        ap_write.write(w);
      end

      if (vif.rd_en && !vif.empty) begin
        r.data = vif.dout;
        ap_read.write(r);
      end
    end
  endtask

endclass

`endif
