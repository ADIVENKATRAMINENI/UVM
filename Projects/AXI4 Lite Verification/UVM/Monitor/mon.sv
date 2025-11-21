typedef struct packed { bit [31:0] addr; bit [31:0] data; } axi_write_s;
typedef struct packed { bit [31:0] addr; bit [31:0] data; } axi_read_s;

class axi_monitor extends uvm_component;
  `uvm_component_utils(axi_monitor)
  virtual axi_if.MONITOR vif;
  uvm_analysis_port#(axi_write_s) ap_wr;
  uvm_analysis_port#(axi_read_s)  ap_rd;
  bit [31:0] araddr_q[$];

  function new(string name, uvm_component parent);
    super.new(name,parent);
    ap_wr = new("ap_wr",this);
    ap_rd = new("ap_rd",this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual axi_if.MONITOR)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","No vif for monitor");
  endfunction

  task run_phase(uvm_phase phase);
    axi_write_s w; axi_read_s r;
    forever @(posedge vif.ACLK) begin
      // write capture
      if(vif.AWVALID && vif.AWREADY && vif.WVALID && vif.WREADY) begin
        w.addr = vif.AWADDR; w.data = vif.WDATA; ap_wr.write(w);
      end
      // read address
      if(vif.ARVALID && vif.ARREADY) araddr_q.push_back(vif.ARADDR);
      // read data
      if(vif.RVALID && vif.RREADY) begin
        if(araddr_q.size()==0) `uvm_error("AXI_MON","RVALID w/o ARADDR");
        else begin
          r.addr = araddr_q.pop_front(); r.data = vif.RDATA;
          ap_rd.write(r);
        end
      end
    end
  endtask
endclass

