
// monitor

    typedef struct packed {bit[7:0] data;}uart_tx_s;
    typedef struct packed {bit[7:0] data;}uart_rx_s;
    
    
    
    class uart_monitor extends uvm_component;
      `uvm_component_utils(uart_monitor);
      
     virtual uart_if.mon vif;
      
      uvm_analysis_port#(uart_tx_s) ap_tx;
      uvm_analysis_port#(uart_rx_s) ap_rx;
      
      
      function new(string name,uvm_component parent);
    	super.new(name,parent);
        ap_tx= new("ap_tx",this);
        ap_rx= new("ap_rx",this);
  	endfunction
  
  	function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
      if(!uvm_config_db#(virtual uart_if.mon)::get(this,"","vif",vif))
          `uvm_fatal("NOVIF", "Virtual interface has not been set for mon")
  	endfunction
    
    task run_phase(uvm_phase phase);
      uart_tx_s tx;
      uart_rx_s rx;
      
      
      forever begin
        @(posedge vif.clk);
        
        if(vif.tx_start && !vif.tx_busy)begin
          tx.data<=vif.tx_data;
          ap_tx.write(tx);
        end
        
        if(vif.rx_valid)begin
          rx.data<=vif.rx_data;
          ap_rx.write(rx);
        end
      end
      endtask
endclass
