class apb_txn extends uvm_sequence_item;
  `uvm_object_utils(apb_txn)

  rand bit write;
  rand bit [7:0] addr;
  rand bit [31:0] wdata;
  bit [31:0] rdata;
  rand int unsigned idle_cycles;

  constraint c_idle { idle_cycles inside {[0:5]}; }

  function new(string name="apb_txn");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("{%s addr=0x%0h wdata=0x%0h idle=%0d}", write ? "WR" : "RD", addr, wdata, idle_cycles);
  endfunction
endclass

