`timescale 1ns/1ps
 import uvm_pkg::*; 
`include "uvm_macros.svh"


// Transaction_item

class uart_txn extends uvm_sequence_item;
  rand bit[7:0] data;
  rand int unsigned idle_cycles;
  
  constraint idle_c{idle_cycles inside {[0:10]};}
  
  `uvm_object_utils(uart_txn)
  
  function new(string name="uart_txn");
    super.new(name);
  endfunction
  
  
  function string convert2string();
    return $sformatf("{data =0x%0h idle=%0d}",data,idle_cycles);
  endfunction
  
endclass
