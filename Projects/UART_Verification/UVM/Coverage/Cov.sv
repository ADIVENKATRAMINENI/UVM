// coverage
      class uart_coverage extends uvm_component;
        `uvm_component_utils(uart_coverage);
      virtual uart_if.mon vif;
        
		covergroup uart_cg @(posedge vif.clk);
          coverpoint vif.rx_valid;
          coverpoint vif.rx_data {
      bins low   = {[8'h00:8'h1F]};
      bins mid   = {[8'h20:8'h7F]};
      bins high  = {[8'h80:8'hFF]};
    }
                 
        rx_valid_x_data : cross vif.rx_data,vif.rx_valid;
       endgroup
              
      
       function new(string name,uvm_component parent);
      	 super.new(name,parent);
       endfunction
      
          function void build_phase(uvm_phase phase);
          super.build_phase(phase);
            if(!uvm_config_db#(virtual uart_if.mon)::get(this,"","vif",vif) begin
             `uvm_fatal("NOVIF","Virtual interface is not set for modport mon");
             uart_cg=new();
            end
             endfunction
         
             endclass
          
