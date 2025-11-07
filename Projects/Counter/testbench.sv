//====================
// UVM includes
//====================
`include "uvm_macros.svh"
import uvm_pkg::*;

//============================================================
// counter_item.sv (transaction)
//============================================================
class counter_item extends uvm_sequence_item;
  rand bit reset;
  rand bit enable;

  constraint c_reset { reset dist { 1 := 2, 0 := 8 }; }

  `uvm_object_utils_begin(counter_item)
    `uvm_field_int(reset , UVM_ALL_ON)
    `uvm_field_int(enable, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name="counter_item");
    super.new(name);
  endfunction
endclass

//============================================================
// counter_sequencer.sv
//============================================================
class counter_sequencer extends uvm_sequencer#(counter_item);
  `uvm_component_utils(counter_sequencer)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass




//============================================================
// counter_driver.sv
//============================================================
class counter_driver extends uvm_driver#(counter_item);
  `uvm_component_utils(counter_driver)

  virtual counter_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual counter_if)::get(this, "", "vif", vif))
      `uvm_fatal("DRV/CFG", "Virtual interface 'vif' not set")
  endfunction

  task run_phase(uvm_phase phase);
    counter_item tr;
    forever begin
      seq_item_port.get_next_item(tr);

      vif.reset  <= tr.reset;
      vif.enable <= tr.enable;

      `uvm_info("DRV",
        $sformatf("Driving item: reset=%0b enable=%0b", tr.reset, tr.enable),
        UVM_MEDIUM)

      @(posedge vif.clk);

      seq_item_port.item_done();
      @(posedge vif.clk);
    end
  endtask
endclass
    
//============================================================
// counter_monitor.sv
//============================================================ 
 class counter_monitor extends uvm_monitor;
  `uvm_component_utils(counter_monitor)
   virtual counter_if vif;

  uvm_analysis_port#(counter_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual counter_if)::get(this, "", "vif", vif))
      `uvm_fatal("MON/CFG", "Virtual interface 'vif' not set")
  endfunction
  
    
  task run_phase(uvm_phase phase);
  counter_item seen;
    forever begin
     @(posedge vif.clk);
      `uvm_info("MON",$sformatf("Observed: reset=%0b enable=%0b count=%0d",vif.reset, vif.enable,vif.count),UVM_LOW)
     seen = counter_item::type_id::create("seen");
     seen.reset=vif.reset;
     seen.enable=vif.enable;
      ap.write(seen);
     end
   endtask
 endclass
       
     
//============================================================
// counter_agent.sv
//============================================================
class counter_agent extends uvm_agent;
  `uvm_component_utils(counter_agent)
  
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  
  counter_sequencer seqr;
  counter_driver Drv;
  counter_monitor Mon;
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seqr=counter_sequencer::type_id::create("seqr",this);
    Drv=counter_driver::type_id::create("Drv",this);
    Mon=counter_monitor::type_id::create("Mon",this);
    
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    Drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass
                               
                               
     
//============================================================
// counter_env.sv
//============================================================
class counter_env extends uvm_env;
  `uvm_component_utils(counter_env)
  counter_agent agt;
  
  function new(string name ,uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt=counter_agent::type_id::create("agt",this);
  endfunction
endclass
                            

//============================================================
// counter_seq.sv (stimulus)
//============================================================
class counter_seq extends uvm_sequence#(counter_item);
  `uvm_object_utils(counter_seq)
  
    function new(string name = "counter_seq");
    super.new(name);
  endfunction

  task body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);

    repeat (12) begin
      counter_item tr = counter_item::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize() with { if (reset) enable == 0; });
      finish_item(tr);
    end

    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask
endclass

                               
//============================================================
// counter_test.sv
//============================================================
class counter_test extends uvm_test;
  `uvm_component_utils(counter_test)
  counter_env env;
  
  function new(string name="counter_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=counter_env::type_id::create("env",this);
  endfunction
  
 task run_phase(uvm_phase phase);
    counter_seq seq;
    phase.raise_objection(this);
      `uvm_info("TEST", "Starting counter_seq", UVM_LOW)
      seq = counter_seq::type_id::create("seq");
      seq.start(env.agt.seqr);
      #50ns;
      `uvm_info("TEST", "Finished counter_seq", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass
                               
                               
//============================================================
// top.sv (top-level)
//============================================================

module top;
  logic clk = 0;
  always #5 clk = ~clk; 


  counter_if cif(clk);
  counter  dut(.clk(clk),.reset (cif.reset),.enable(cif.enable),.count (cif.count));

  initial begin
    cif.reset  = 1'b1;
    cif.enable = 1'b0;
    repeat (2) @(posedge clk);
    cif.reset = 1'b0;
  end

  initial begin
    uvm_config_db#(virtual counter_if)::set(null, "*", "vif", cif);
    run_test("counter_test");
  end

endmodule                              
    
    
    
         
                               
    
 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


























