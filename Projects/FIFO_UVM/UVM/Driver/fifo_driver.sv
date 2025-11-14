`ifndef FIFO_DRIVER_SV
`define FIFO_DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;


class fifo_driver extends uvm_driver#(fifo_txn);
  `uvm_component_utils(fifo_driver)

  virtual fifo_if.drv vif;

  function new(string name = "fifo_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual fifo_if.drv)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual Interface not set for fifo_driver");
  endfunction


  task run_phase(uvm_phase phase);
    fifo_txn t;

    vif.cb.wr_en <= 0;
    vif.cb.rd_en <= 0;
    vif.cb.din   <= 0;

    @(vif.cb);

    forever begin
      seq_item_port.get_next_item(t);

      vif.cb.din   <= t.data;
      vif.cb.wr_en <= t.wr_en;
      vif.cb.rd_en <= t.rd_en;

      @(vif.cb);

      vif.cb.wr_en <= 0;
      vif.cb.rd_en <= 0;

      seq_item_port.item_done();
    end
  endtask

endclass

`endif
