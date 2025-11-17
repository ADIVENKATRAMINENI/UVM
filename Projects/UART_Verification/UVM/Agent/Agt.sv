// agent
    class uart_agent extends uvm_agent;
      `uvm_component_utils(uart_agent)
      uart_seqr seqr;
      uart_driver drv;
      uart_monitor mon;
      
      function new (string name,uvm_component parent);
        super.new(name,parent);
      endfunction
      
      
      function build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr=uart_sequencer::type_id::create("seqr",this);
        drv=uart_driver::type_id::create("drv",this);
        mon=uart_monitor::type_id::create("mon",this);
      endfunction
      
      function connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
        endfunction
endclass       
      
