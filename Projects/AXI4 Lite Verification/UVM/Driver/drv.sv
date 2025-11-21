class axi_driver extends uvm_driver#(axi_txn);
  `uvm_component_utils(axi_driver)
  virtual axi_if.MASTER vif;

  function new(string name, uvm_component parent); super.new(name,parent); endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if.MASTER)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","No vif for driver");
  endfunction

  task axi_write_transfer(bit [31:0] addr, bit [31:0] data);
    vif.drv_cb.AWADDR <= addr; vif.drv_cb.AWVALID <= 1;
    vif.drv_cb.WDATA <= data; vif.drv_cb.WVALID <= 1;
    vif.drv_cb.WSTRB <= { (32/8){1'b1} };
    @(posedge vif.drv_cb);
    wait(vif.AWREADY && vif.WREADY);
    vif.drv_cb.AWVALID <= 0; vif.drv_cb.WVALID <= 0;
    wait(vif.BVALID); vif.drv_cb.BREADY <= 1; @(posedge vif.drv_cb); vif.drv_cb.BREADY <= 0;
  endtask

  task axi_read_transfer(bit [31:0] addr, output bit [31:0] rdata);
    vif.drv_cb.ARADDR <= addr; vif.drv_cb.ARVALID <= 1; @(posedge vif.drv_cb);
    wait(vif.ARREADY); vif.drv_cb.ARVALID <= 0;
    wait(vif.RVALID); rdata = vif.RDATA;
    vif.drv_cb.RREADY <= 1; @(posedge vif.drv_cb); vif.drv_cb.RREADY <= 0;
  endtask

  task run_phase(uvm_phase phase);
    axi_txn t;
    vif.drv_cb.AWVALID<=0; vif.drv_cb.WVALID<=0; vif.drv_cb.BREADY<=0;
    vif.drv_cb.ARVALID<=0; vif.drv_cb.RREADY<=0; @(posedge vif.drv_cb);
    forever begin
      seq_item_port.get_next_item(t);
      repeat(t.idle_cycles) @(posedge vif.drv_cb);
      if(t.is_write) axi_write_transfer(t.addr,t.wdata);
      else axi_read_transfer(t.addr,t.rdata);
      seq_item_port.item_done();
    end
  endtask
endclass

