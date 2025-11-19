class apb_driver extends uvm_driver#(apb_txn);
  `uvm_component_utils(apb_driver)
  virtual apb_if.drv vif;

  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_if.drv)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","Interface not set for driver");
  endfunction

  task run_phase(uvm_phase phase);
    apb_txn t;

    // Initialize bus
    vif.cb.PSEL    <= 0;
    vif.cb.PENABLE <= 0;
    vif.cb.PWRITE  <= 0;
    vif.cb.PADDR   <= 0;
    vif.cb.PWDATA  <= 0;
    @(posedge vif.cb);

    forever begin
      seq_item_port.get_next_item(t);

      // Idle cycles
      repeat(t.idle_cycles) @(posedge vif.cb);

      // SETUP phase
      vif.cb.PADDR   <= t.addr;
      vif.cb.PWRITE  <= t.write;
      vif.cb.PWDATA  <= t.wdata;
      vif.cb.PSEL    <= 1;
      vif.cb.PENABLE <= 0;
      @(posedge vif.cb);

      // ENABLE phase
      vif.cb.PENABLE <= 1;
      @(posedge vif.cb);
      while (vif.cb.PREADY == 0) @(posedge vif.cb);

      // Deassert
      vif.cb.PSEL    <= 0;
      vif.cb.PENABLE <= 0;

      seq_item_port.item_done();
    end
  endtask
endclass

