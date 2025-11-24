`include "dma_pkg.sv"

class dma_base_seq extends uvm_sequence #(dma_txn);
    `uvm_object_utils(dma_base_seq)
    function new(string name="dma_base_seq");
        super.new(name);
    endfunction
endclass

`include "dma_pkg.sv"

class dma_base_seq extends uvm_sequence #(dma_txn);
    `uvm_object_utils(dma_base_seq)
    function new(string name="dma_base_seq");
        super.new(name);
    endfunction
endclass

class dma_directed_seq extends dma_base_seq;
    `uvm_object_utils(dma_directed_seq)
    virtual task body();
        dma_txn txn = dma_txn::type_id::create("txn");
        txn.src_addr = 32'h0;
        txn.dst_addr = 32'h100;
        txn.length   = 32'h40;
        start_item(txn);
        finish_item(txn);
    endtask
endclass

class dma_random_seq extends dma_base_seq;
    `uvm_object_utils(dma_random_seq)
    virtual task body();
        dma_txn txn = dma_txn::type_id::create("txn");
        
        start_item(txn);
      assert(txn.randomize());
        finish_item(txn);
    endtask
endclass

