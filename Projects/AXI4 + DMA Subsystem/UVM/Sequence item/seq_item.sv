package dma_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class dma_txn extends uvm_sequence_item;
        rand bit [31:0] src_addr;
        rand bit [31:0] dst_addr;
        rand bit [31:0] length;

        `uvm_object_utils(dma_txn)

        function new(string name="dma_txn");
            super.new(name);
        endfunction
    endclass
endpackage

