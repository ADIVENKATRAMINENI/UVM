//===================
// sequencer
//===================
`include "uvm_macros.svh"
import uvm_pkg::*;


class fifo_sequencer extends uvm_sequencer#(fifo_txn);
  `uvm_component_utils(fifo_sequencer)
  
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
endclass

//Purpose:
//   The sequencer acts as the "middleman" between sequences and driver.
//   It sends one transaction at a time to the driver upon request.
//
// Note: For simple FIFOs, this is a passive relay - no extra code needed.