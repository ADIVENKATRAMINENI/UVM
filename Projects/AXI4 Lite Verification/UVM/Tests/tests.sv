class axi_test extends uvm_test;
  `uvm_component_utils(axi_test)
  axi_env env;

  function new(string name, uvm_component parent); super.new(name,parent); endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi_env::type_id::create("env",this);

    // --- Configuration setup ---
    virtual axi_if.MASTER vif_m;
    virtual axi_if.MONITOR vif_mon;

    if(!uvm_config_db#(virtual axi_if.MASTER)::get(this,"tb_top.axi_if","vif_m",vif_m))
      `uvm_fatal("NOVIF","Master interface not found")
    if(!uvm_config_db#(virtual axi_if.MONITOR)::get(this,"tb_top.axi_if","vif_mon",vif_mon))
      `uvm_fatal("NOVIF","Monitor interface not found")

    uvm_config_db#(virtual axi_if.MASTER)::set(this,"env.agt.drv","vif",vif_m);
    uvm_config_db#(virtual axi_if.MONITOR)::set(this,"env.agt.mon","vif",vif_mon);
  endfunction

  task run_phase(uvm_phase phase);
    axi_smoke_seq s = axi_smoke_seq::type_id::create("s");
    s.start(env.agt.sqr);

    axi_back_to_back_seq bb = axi_back_to_back_seq::type_id::create("bb");
    bb.start(env.agt.sqr);

    axi_write_read_seq wr = axi_write_read_seq::type_id::create("wr");
    wr.start(env.agt.sqr);

    axi_random_seq rnd = axi_random_seq::type_id::create("rnd");
    rnd.start(env.agt.sqr);
  endtask
endclass
