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

class dma_back_to_back_seq extends dma_base_seq;
    `uvm_object_utils(dma_back_to_back_seq)

    virtual task body();
        dma_txn t;

        repeat(5) begin
            t = dma_txn::type_id::create("t");
            assert(t.randomize() with {
                length inside {[16:128]};
            });

            start_item(t);
            finish_item(t);
        end
    endtask
endclass

class dma_large_seq extends dma_base_seq;
    `uvm_object_utils(dma_large_seq)

    virtual task body();
        dma_txn t = dma_txn::type_id::create("t");

        start_item(t);
        t.src_addr = 32'h0000_2000;
        t.dst_addr = 32'h0000_4000;
        t.length   = 32'd512; // big transfer
        finish_item(t);
    endtask
endclass

class dma_stress_seq extends dma_base_seq;
    `uvm_object_utils(dma_stress_seq)

    virtual task body();
        dma_txn t;

        repeat(50) begin
            t = dma_txn::type_id::create("t");
            assert(t.randomize());
            start_item(t);
            finish_item(t);
        end
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
