// Scoreboard
      
      class uart_scoreboard extends uvmscoreboard;
        `uvm_component_utils(uart_scoreboard)
        
        uvm_tlm_analysis_fifo#(uart_tx_s) exp_fifo;
        uvm_tlm_analysis_fifo#(uart_rx_s) act_fifo;
        
        function new(string name,uvm_component parent);
          super.new(name,parent);
        endfunction
        
        function build_phase(uvm_phase phase);
          super.build_phase(phase);
          exp_fifo=new("exp_fifo",this);
          act_fifo=new("act_fifo",this);
        endfunction
        
        task run_phase(uvm_phase phase);
          uart_tx_x exp;
          uart_rx_s act;
          forever begin
            act_fifo.get(act);
            if (exp_fifo.is_empty()) begin
              `uvm_error("SCORE","RX got data but no expected TX in queue")
            end
            else begin
              exp_fifo.get(exp);
              if (exp.data !== act.data) 
                `uvm_error("SCORE",$sformatf("DATA MISMATCH exp=0x%0h got=0x%0h", exp.data, act.data));
              else
                `uvm_info("SCORE", $sformatf("MATCH: 0x%0h", act.data), UVM_LOW);
            end
          end
        endtask
      endclass
