class apb_agent extends uvm_agent;
  `uvm_component_utils(apb_agent)

  apb_seqr    seqr;
  apb_driver  drv;
  apb_monitor mon;

  function new(string name, uvm_component parent); super.new(name,parent); endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seqr = apb_seqr::type_id::create("seqr", this);
    drv  = apb_driver::type_id::create("drv", this);
    mon  = apb_monitor::type_id::create("mon", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass

