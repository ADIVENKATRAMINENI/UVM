

// Driver
class uart_driver extends uvm_driver#(uart_txn);
  `uvm_component_utils(uart_driver)
  virtual uart_if.drv vif;
  
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual uart_if.drv)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF", "Virtual interface has not been set for drv")
  endfunction
  
  task run_phase(uvm_phase phase);
	uart_txn t;
    vif.cb.tx_start <=0;
    vif.cb.tx_data <='0;
    @(posedge vif.cb);
    
    forever begin
      seq_item_port.get_next_item(t);
      while(vif.cb.tx_busy)@(posedge vif.cb);
      vif.cb.tx_start <=1;
      vif.cb.tx_data<=t.data;
      @(posedge vif.cb);
      vif.cb.tx_start=0;
      repeat(t.idle_cycles)@(posedge vif.cb);
      
      seq_item_port.item_done();
    end
  endtask
endclass
    
