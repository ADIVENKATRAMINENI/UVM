package dma_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class dma_txn extends uvm_sequence_item;
        rand bit [31:0] src_addr;
        rand bit [31:0] dst_addr;
        rand bit [31:0] length;
      class dma_txn extends uvm_sequence_item;

    rand bit [31:0] src_addr;
    rand bit [31:0] dst_addr;
    rand bit [31:0] length;

    // ------------------------------------
    // Constraints
    // ------------------------------------

constraint c_addr_align {
    src_addr % 4 == 0;
    dst_addr % 4 == 0;
}

constraint c_length_valid {
    length inside { [4:256] };
    length % 4 == 0;
}

constraint c_addr_range {
    src_addr inside { [0 : 'h0FFF] };
    dst_addr inside { [0 : 'h0FFF] };
}


        `uvm_object_utils(dma_txn)

        function new(string name="dma_txn");
            super.new(name);
        endfunction
    endclass
endpackage
