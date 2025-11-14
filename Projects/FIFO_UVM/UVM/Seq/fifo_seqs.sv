// ==========================================================
// Base Sequence
// ==========================================================4
`include "uvm_macros.svh"
import uvm_pkg::*;


class fifo_base_sequence extends uvm_sequence#(fifo_txn);
  `uvm_object_utils(fifo_base_sequence)

  function new(string name = "fifo_base_sequence");
    super.new(name);
  endfunction
endclass



// ==========================================================
// Smoke Sequence
// ==========================================================
class fifo_smoke_sequence extends fifo_base_sequence;
  `uvm_object_utils(fifo_smoke_sequence)

  task body();
    fifo_txn tr;

    // --------------------------------------------------------
    // 1. WRITE 3 known values
    // --------------------------------------------------------
    for (int i = 0; i < 3; i++) begin
      tr = fifo_txn::type_id::create("wr");   
      start_item(tr);

      assert(tr.randomize() with {
        wr_en == 1;
        rd_en == 0;
        data  == (i + 8'h10);                
      });

      finish_item(tr);
    end


    // --------------------------------------------------------
    // 2. READ 3 values
    // --------------------------------------------------------
    for (int i = 0; i < 3; i++) begin
      tr = fifo_txn::type_id::create("rd");
      start_item(tr);

      assert(tr.randomize() with {
        wr_en == 0;
        rd_en == 1;
      });

      finish_item(tr);
    end
  endtask

endclass



// full_seq
class fifo_full_sequence extends fifo_base_sequence;
  `uvm_object_utils(fifo_full_sequence)

  int DEPTH = 16;

  task body();
    fifo_txn tr;

    // -----------------------------
    // Fill FIFO completely
    // -----------------------------
    repeat (DEPTH) begin
      tr = fifo_txn::type_id::create("full");
      start_item(tr);

      assert(tr.randomize() with {
        wr_en == 1;
        rd_en == 0;
      });

      finish_item(tr);
    end

    // -----------------------------
    // Try extra writes while full
    // -----------------------------
    repeat (3) begin
      tr = fifo_txn::type_id::create("full_wr");
      start_item(tr);

      assert(tr.randomize() with {
        wr_en == 1;
        rd_en == 0;
      });

      finish_item(tr);
    end
  endtask
endclass


// empty_seq
class fifo_empty_seq extends fifo_base_sequence;
  `uvm_object_utils(fifo_empty_seq)

  task body();
    fifo_txn tr;

    repeat (4) begin
      tr = fifo_txn::type_id::create("empty_tr");
      start_item(tr);

      assert(tr.randomize() with {
        wr_en == 0;
        rd_en == 1;
      });

      finish_item(tr);
    end
  endtask
endclass


//wrap_seq
class fifo_wrap_sequence extends fifo_base_sequence;
  `uvm_object_utils(fifo_wrap_sequence)

  int DEPTH = 16;

  task body();
    fifo_txn tr;

    // Run 2 full wrap cycles
    repeat (2) begin

      // -----------------------------
      // Fill FIFO
      -----------------------------
      repeat (DEPTH) begin
        tr = fifo_txn::type_id::create("fill");
        start_item(tr);

        assert(tr.randomize() with {
          wr_en == 1;
          rd_en == 0;
        });

        finish_item(tr);
      end

      // -----------------------------
      // Drain FIFO
      -----------------------------
      repeat (DEPTH) begin
        tr = fifo_txn::type_id::create("drain");
        start_item(tr);

        assert(tr.randomize() with {
          wr_en == 0;
          rd_en == 1;
        });

        finish_item(tr);
      end

    end // repeat

  endtask
endclass



// simln_wr_rd
class fifo_simrw_seq extends fifo_base_sequence;
  `uvm_object_utils(fifo_simrw_seq)

  task body();
    fifo_txn t;

    repeat (60) begin
      t = fifo_txn::type_id::create("simrw");
      start_item(t);

      // Weighted random:
      // wr_en = 1 most of the time
      // rd_en = 1 most of the time
      assert(t.randomize() with {
        wr_en dist {1 := 3, 0 := 1};
        rd_en dist {1 := 3, 0 := 1};
      });

      finish_item(t);
    end

  endtask
endclass


//bypass_seq
class fifo_bypass_full_seq extends fifo_base_sequence;
  `uvm_object_utils(fifo_bypass_full_seq)

  int depth = 16;

  task body();
    fifo_txn t;

    // ------------------------------------------------
    // 1. Fill FIFO completely
    // ------------------------------------------------
    repeat (depth) begin
      t = fifo_txn::type_id::create("fill");
      start_item(t);

      assert(t.randomize() with {
        wr_en == 1;
        rd_en == 0;
      });

      finish_item(t);
    end


    // ------------------------------------------------
    // 2. Full-bypass mode (simultaneous R/W while full)
    // ------------------------------------------------
    repeat (16) begin
      t = fifo_txn::type_id::create("bypass");
      start_item(t);

      assert(t.randomize() with {
        wr_en == 1;
        rd_en == 1;
      });

      finish_item(t);
    end


    // ------------------------------------------------
    // 3. Drain remaining entries
    // ------------------------------------------------
    repeat (depth) begin
      t = fifo_txn::type_id::create("drain");
      start_item(t);

      assert(t.randomize() with {
        wr_en == 0;
        rd_en == 1;
      });

      finish_item(t);
    end
  endtask

endclass



//random_seq
class fifo_random_seq extends fifo_base_sequence;
  `uvm_object_utils(fifo_random_seq)

  task body();
    fifo_txn t;

    repeat (300) begin
      t = fifo_txn::type_id::create("rand");
      start_item(t);

      assert(t.randomize());

      finish_item(t);
    end
  endtask

endclass

