      
// Emvironment
      class uart_env extends uvm_env;
        `uvm_component_utils(uart_env)
        uart_agent agt;
        uart_scoreboard scb;
        uart_coverage cov;

        
        function new(string name,uvm_component parent);
          super.new(name,parent);
        endfunction
        
        function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          agt=uart_agent::type_id::create("agt",this);
          scb=uart_scoreboard::type_id::create("scb",this);
          cov=uart_coverage::type_id::create("cov",this);
        endfunction
        
        function void connect_phase(uvm_phase phase);
          super.connect_phase(phase);
          agt.mon.ap_tx.connect(scb.exp_fifo.analysis_export);
          agt.mon.ap_rx.connect(scb.act_fifo.analysis_export);
        endfunction
      endclass
