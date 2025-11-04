`include "uvm_macros.svh"
import uvm_pkg::*;

class hello_test extends uvm_test;
  `uvm_component_utils(hello_test)
  
  function new(string name="hello_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    `uvm_info("PHASE", ">>> build_phase", UVM_LOW)
  endfunction

  function void connect_phase(uvm_phase phase);
    `uvm_info("PHASE", ">>> connect_phase", UVM_LOW)
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
      `uvm_info("PHASE", ">>> run_phase start", UVM_LOW)
      #50ns;
      `uvm_info("PHASE", "Hello UVM World — Simulation Running!", UVM_LOW)
      #50ns;
      `uvm_error("REPORT", "This is a sample error message for demo")
    phase.drop_objection(this);
    `uvm_info("PHASE", ">>> run_phase end", UVM_LOW)
  endtask
endclass


module top;
  initial run_test("hello_test");
endmodule