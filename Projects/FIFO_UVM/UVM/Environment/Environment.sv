`ifndef FIFO_ENV_SV
`define FIFO_ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;


class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)

  fifo_agent      agt;
  fifo_scoreboard scb;
  fifo_coverage   cov;

  virtual fifo_if vif;   // must be provided by testbench


  function new(string name = "fifo_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction



  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agt = fifo_agent     ::type_id::create("agt", this);
    scb = fifo_scoreboard::type_id::create("scb", this);
    cov = fifo_coverage  ::type_id::create("cov", this);

    // Pass virtual interface to agent + monitor + coverage
    uvm_config_db#(virtual fifo_if.drv)::set(this, "agt.drv", "vif", vif);
    uvm_config_db#(virtual fifo_if.mon)::set(this, "agt.mon", "vif", vif);
    uvm_config_db#(virtual fifo_if.mon)::set(this, "cov",     "vif", vif);
  endfunction



  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    agt.mon.ap_write.connect(scb.imp_wr);
    agt.mon.ap_read.connect(scb.imp_rd);
  endfunction


endclass

`endif
