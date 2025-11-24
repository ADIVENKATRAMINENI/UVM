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

    // Address alignment (word aligned)
    constraint addr_align {
        src_addr[1:0] == 2'b00;
        dst_addr[1:0] == 2'b00;
    }

    // DMA length between 16 and 1024 bytes
    constraint len_range {
        length inside {[16:1024]};
    }

    // Length must be multiple of 4
    constraint len_align {
        length % 4 == 0;
    }

    // SRC and DST must not overlap too close
    constraint no_overlap {
        (dst_addr >= src_addr + length) ||
        (src_addr >= dst_addr + length);
    }

    // Keep addresses inside a valid memory map (example: 4 KB = 4096)
    constraint addr_range {
        src_addr < 32'h1000;
        dst_addr < 32'h1000;
    }



        `uvm_object_utils(dma_txn)

        function new(string name="dma_txn");
            super.new(name);
        endfunction
    endclass
endpackage
