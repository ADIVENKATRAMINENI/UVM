`ifndef FIFO_TXN_SV
`define FIFO_TXN_SV

`include "uvm_macros.svh"
import uvm_pkg::*;


// ====================================================
// FIFO Transaction / Sequence Item
// ====================================================
class fifo_txn extends uvm_sequence_item;
  `uvm_object_utils(fifo_txn)

  // Randomized stimulus fields
  rand bit        wr_en;
  rand bit        rd_en;
  rand bit [7:0]  data;

  // Constructor
  function new(string name="fifo_txn");
    super.new(name);
  endfunction

  // For logs
  function string convert2string();
    return $sformatf("{wr=%0b rd=%0b data=0x%0h}",
                     wr_en, rd_en, data);
  endfunction

endclass

`endif
