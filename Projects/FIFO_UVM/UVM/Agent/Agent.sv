`ifndef FIFO_AGENT_SV
`define FIFO_AGENT_SV
`include "uvm_macros.svh"
import uvm_pkg::*;


class fifo_agent extends uvm_agent;
  `uvm_component_utils(fifo_agent)

  fifo_sequencer sqr;
  fifo_driver    drv;
  fifo_monitor   mon;

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  function new(string name = "fifo_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (is_active == UVM_ACTIVE)
      sqr = fifo_sequencer::type_id::create("sqr", this);

    drv = fifo_driver::type_id::create("drv", this);
    mon = fifo_monitor::type_id::create("mon", this);
  endfunction


  function void connect_phase(uvm_phase phase);
    if (is_active == UVM_ACTIVE)
      drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction

endclass

`endif
