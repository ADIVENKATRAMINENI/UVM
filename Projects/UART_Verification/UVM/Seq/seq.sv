// sequences
// base_sequence
class uart_base_seq extends uvm_sequence#(uart_txn);
  `uvm_object_utils(uart_base_seq)
  function new(string name="uart_base_seq");
    super.new(name);
  endfunction
endclass

// smoke_seq
class uart_smoke_seq extends uart_base_seq;
  `uvm_object_utils(uart_smoke_seq)
  task body();
    uart_txn t;
    byte values[3]='{8'h55,8'hA5,8'h3C};
    foreach(values[i]) begin
      t=uart_txn::type_id::create($sformatf("t%0d",i));
      start_item(t);
      assert(t.randomize() with { data==values[i];idle_cycles==2;});
      finish_item(t);
    end
  endtask
endclass


// back_to_back_seq == stress test(continous data flow)
class uart_back_to_back_seq extends uart_base_seq;
  `uvm_object_utils(uart_back_to_back_seq)
  
  task body();
    uart_txn t;
    repeat(10) begin
      t=uart_txn::type_id::create("t_bb");
      start_item(t);
      assert(t.randomize() with {idle_cycles==0;});
      finish_item(t);
    end
  endtask
endclass



// gap sequence == gaps after frame sent 
class uart_gap_seq extends uart_base_seq;
  `uvm_object_utils(uart_gap_seq)
  
  task body();
    uart_txn t;
    repeat(10) begin
      t=uart_txn::type_id::create("t_gap");
      start_item(t);
      assert(t.randomize() with {idle_cycles inside {[1:10]};});
      finish_item(t);
    end
  endtask
endclass


// random sequence == checks everything
class uart_random_seq extends uart_base_seq;
  `uvm_object_utils(uart_random_seq)
  
  task body();
    uart_txn t;
    repeat(50) begin
      t=uart_txn::type_id::create("t_rand");
      start_item(t);
      assert(t.randomize());
      finish_item(t);
    end
  endtask
endclass

