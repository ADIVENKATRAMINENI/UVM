typedef struct packed { bit [7:0] addr; bit [31:0] data; } apb_write_s;
typedef struct packed { bit [7:0] addr; bit [31:0] data; } apb_read_s;

class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)
  virtual apb_if.mon vif;
  uvm_analysis_port#(apb_write_s) ap_wr;
  uvm_analysis_port#(apb_read_s)  ap_rd;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap_wr = new("ap_wr", this);
    ap_rd = new("ap_rd", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_if.mon)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","Interface not set for monitor");
  endfunction

  task run_phase(uvm_phase phase);
    apb_write_s w;
    apb_read_s  r;
    forever begin
      @(posedge vif.PCLK);
      if (vif.PSEL && vif.PENABLE && vif.PREADY) begin
        if (vif.PWRITE) begin
          w.addr = vif.PADDR;
          w.data = vif.PWDATA;
          ap_wr.write(w);
        end else begin
          r.addr = vif.PADDR;
          r.data = vif.PRDATA;
          ap_rd.write(r);
        end
      end
    end
  endtask
endclass

