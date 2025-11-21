class axi_test extends uvm_test;
  `uvm_component_utils(axi_test)
  axi_env env;

  function new(string name, uvm_component parent); super.new(name,parent); endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi_env::type_id::create("env",this);
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

