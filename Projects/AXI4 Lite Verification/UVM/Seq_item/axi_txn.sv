class axi_txn extends uvm_sequence_item;
  `uvm_object_utils(axi_txn)

  rand bit        is_write;      // 1 = write, 0 = read
  rand bit [7:0]  addr;          // 8-bit address
  rand bit [31:0] wdata;         // write data
  bit [31:0] rdata;              // read data (captured by driver)
  rand int unsigned idle_cycles;  // optional delay

  // Constraints
  constraint addr_align { addr[1:0] == 2'b00; } // word-aligned
  constraint idle_limit { idle_cycles inside {[0:5]}; }

  // Constructor
  function new(string name = "axi_txn");
    super.new(name);
  endfunction

  // Convert to string (for logging)
  function string convert2string();
    return $sformatf("{%s addr=0x%0h wdata=0x%0h idle=%0d}",
                     is_write ? "WR" : "RD", addr, wdata, idle_cycles);
  endfunction

endclass

