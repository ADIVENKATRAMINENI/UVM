class axi_base_seq extends uvm_sequence#(axi_txn);
  `uvm_object_utils(axi_base_seq)
  function new(string name="axi_base_seq"); super.new(name); endfunction
endclass

class axi_smoke_seq extends axi_base_seq;
  `uvm_object_utils(axi_smoke_seq)
  task body();
    axi_txn t;
    bit [31:0] vals[3] = '{32'hDEAD_BEEF, 32'h12345678, 32'h0F0FF0F0};
    for(int i=0;i<3;i++) begin
      t=axi_txn::type_id::create("smoke_w");
      start_item(t);
      assert(t.randomize() with {is_write==1; addr==(i*4); wdata==vals[i]; idle_cycles==1;});
      finish_item(t);

      t=axi_txn::type_id::create("smoke_r");
      start_item(t);
      assert(t.randomize() with {is_write==0; addr==(i*4); idle_cycles==1;});
      finish_item(t);
    end
  endtask
endclass

class axi_back_to_back_seq extends axi_base_seq;
  `uvm_object_utils(axi_back_to_back_seq)
  task body();
    axi_txn t;
    repeat(20) begin
      t = axi_txn::type_id::create("bb");
      start_item(t);
      assert(t.randomize() with { idle_cycles==0; });
      finish_item(t);
    end
  endtask
endclass

class axi_write_read_seq extends axi_base_seq;
  `uvm_object_utils(axi_write_read_seq)
  task body();
    axi_txn t;
    for(int i=0;i<8;i++) begin
      t = axi_txn::type_id::create($sformatf("w_reg%0d",i));
      start_item(t); assert(t.randomize() with { is_write==1; addr==(i*4); }); finish_item(t);
    end
    for(int i=0;i<8;i++) begin
      t = axi_txn::type_id::create($sformatf("r_reg%0d",i));
      start_item(t); assert(t.randomize() with { is_write==0; addr==(i*4); }); finish_item(t);
    end
  endtask
endclass

class axi_random_seq extends axi_base_seq;
  `uvm_object_utils(axi_random_seq)
  task body();
    axi_txn t;
    repeat(100) begin
      t = axi_txn::type_id::create("rand");
      start_item(t);
      assert(t.randomize());
      finish_item(t);
    end
  endtask
endclass

