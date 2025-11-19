class apb_base_test extends uvm_test;
  `uvm_component_utils(apb_base_test)

  apb_env env;
  virtual apb_if.drv vif_drv;
  virtual apb_if.mon vif_mon;

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual apb_if.drv)::get(this,"","vif_drv",vif_drv))
      `uvm_fatal("NOVIF","Need drv modport");
    if(!uvm_config_db#(virtual apb_if.mon)::get(this,"","vif_mon",vif_mon))
      `uvm_fatal("NOVIF","Need mon modport");

    uvm_config_db#(virtual apb_if.drv)::set(this,"env.agt.drv","vif",vif_drv);
    uvm_config_db#(virtual apb_if.mon)::set(this,"env.agt.mon","vif",vif_mon);
    uvm_config_db#(virtual apb_if.mon)::set(this,"env.cov","vif",vif_mon);

    env = apb_env::type_id::create("env", this);
  endfunction
endclass


class smoke_test extends base_test;
  `uvm_component_utils(smoke_test)

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
      apb_smoke_seq::type_id::create("seq").start(env.agt.sqr);
    phase.drop_objection(this);
  endtask
endclass


             class write_read_test extends base_test;
  `uvm_component_utils(write_read_test)

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    apb_write_read_seq::type_id::create("seq").start(env.agt.seqr);
    phase.drop_objection(this);
  endtask
endclass

             class back_to_back_test extends base_test;
  `uvm_component_utils(back_to_back_test)

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    apb_back_to_back_seq::type_id::create("seq").start(env.agt.seqr);
    phase.drop_objection(this);
  endtask
endclass


class random_test extends base_test;
  `uvm_component_utils(random_test)

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    apb_random_seq::type_id::create("seq").start(env.agt.seqr);
    phase.drop_objection(this);
  endtask
endclass

