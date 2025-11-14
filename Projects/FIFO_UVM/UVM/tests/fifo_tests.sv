`ifndef FIFO_TESTS_SV
`define FIFO_TESTS_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  fifo_env          env;
  virtual fifo_if.drv vif_drv;
  virtual fifo_if.mon vif_mon;

  int unsigned DEPTH = 16;

  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual fifo_if.drv)::get(this, "", "vif_drv", vif_drv))
      `uvm_fatal("NOVIF", "Need drv modport");

    if (!uvm_config_db#(virtual fifo_if.mon)::get(this, "", "vif_mon", vif_mon))
      `uvm_fatal("NOVIF", "Need mon modport");

    uvm_config_db#(virtual fifo_if.drv)::set(this, "env.agt.drv", "vif", vif_drv);
    uvm_config_db#(virtual fifo_if.mon)::set(this, "env.agt.mon", "vif", vif_mon);
    uvm_config_db#(virtual fifo_if.mon)::set(this, "env.cov",     "vif", vif_mon);
    uvm_config_db#(int unsigned)       ::set(this, "env.scb",     "DEPTH", DEPTH);

    env = fifo_env::type_id::create("env", this);
  endfunction



endclass



class smoke_test extends base_test;
  `uvm_component_utils(smoke_test)

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    fifo_smoke_sequence::type_id::create("seq").start(env.agt.sqr);
    phase.drop_objection(this);
  endtask

endclass



class full_test extends base_test;
  `uvm_component_utils(full_test)

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    fifo_full_sequence::type_id::create("seq").start(env.agt.sqr);
    phase.drop_objection(this);
  endtask

endclass



class empty_test extends base_test;
  `uvm_component_utils(empty_test)

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    fifo_empty_seq::type_id::create("seq").start(env.agt.sqr);
    phase.drop_objection(this);
  endtask

endclass



class wrap_test extends base_test;
  `uvm_component_utils(wrap_test)

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    fifo_wrap_sequence::type_id::create("seq").start(env.agt.sqr);
    phase.drop_objection(this);
  endtask

endclass



class simrw_test extends base_test;
  `uvm_component_utils(simrw_test)

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    fifo_simrw_seq::type_id::create("seq").start(env.agt.sqr);
    phase.drop_objection(this);
  endtask

endclass



class bypass_full_test extends base_test;
  `uvm_component_utils(bypass_full_test)

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    fifo_bypass_full_seq::type_id::create("seq").start(env.agt.sqr);
    phase.drop_objection(this);
  endtask

endclass



class random_test extends base_test;
  `uvm_component_utils(random_test)

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    fifo_random_seq::type_id::create("seq").start(env.agt.sqr);
    phase.drop_objection(this);
  endtask

endclass

`endif
