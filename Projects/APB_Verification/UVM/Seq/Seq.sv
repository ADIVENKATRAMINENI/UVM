class apb_base_seq extends uvm_sequence#(apb_txn);
  `uvm_object_utils(apb_base_seq)
  function new(string name="apb_base_seq"); super.new(name); endfunction
endclass

class apb_smoke_seq extends apb_base_seq;
  `uvm_object_utils(apb_smoke_seq)
  task body();
    apb_txn t;
    for (int i=0; i<4; i++) begin
      t = apb_txn::type_id::create($sformatf("write_%0d",i));
      start_item(t);
      assert(t.randomize() with {
        write == 1;
        addr  == (8'h00 + i*4);
        wdata == (32'hA5A50000 + i);
        idle_cycles == 1;
      });
      finish_item(t);
    end

    for (int i=0; i<4; i++) begin
      t = apb_txn::type_id::create($sformatf("read_%0d",i));
      start_item(t);
      assert(t.randomize() with {
        write == 0;
        addr  == (8'h00 + i*4);
        idle_cycles == 1;
      });
      finish_item(t);
    end
  endtask
endclass

class apb_write_read_seq extends apb_base_seq;
  `uvm_object_utils(apb_write_read_seq)
  task body();
    apb_txn t;
    for (int i=0; i<8; i++) begin
      t = apb_txn::type_id::create("write_dir");
      start_item(t);
      assert(t.randomize() with {addr == (8'h00 + i*4); write == 1;});
      finish_item(t);
    end
    for (int i=0; i<8; i++) begin
      t = apb_txn::type_id::create("read_dir");
      start_item(t);
      assert(t.randomize() with {addr == (8'h00 + i*4); write == 0;});
      finish_item(t);
    end
  endtask
endclass

class apb_back2back_seq extends apb_base_seq;
  `uvm_object_utils(apb_back2back_seq)
  task body();
    apb_txn t;
    repeat(20) begin
      t = apb_txn::type_id::create("b2b");
      start_item(t);
      assert(t.randomize() with {idle_cycles == 0;});
      finish_item(t);
    end
  endtask
endclass

class apb_random_seq extends apb_base_seq;
  `uvm_object_utils(apb_random_seq)
  task body();
    apb_txn t;
    repeat(100) begin
      t = apb_txn::type_id::create("random");
      start_item(t);
      assert(t.randomize());
      finish_item(t);
    end
  endtask
endclass

