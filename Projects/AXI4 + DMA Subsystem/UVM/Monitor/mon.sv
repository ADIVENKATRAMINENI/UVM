// small beat structs (place near top of file or in a small package)
typedef struct packed {
  bit [31:0] addr;
  bit [31:0] data;
  bit [3:0]  wstrb;
  bit        last;
} axi_write_s;

typedef struct packed {
  bit [31:0] addr;
  bit [31:0] data;
  bit        last;
} axi_read_s;

// monitor
class dma_monitor extends uvm_monitor;
  `uvm_component_utils(dma_monitor)

  virtual axi_if mon_axi;
  uvm_analysis_port #(axi_write_s) ap_wr;
  uvm_analysis_port #(axi_read_s)  ap_rd;

  // queues to hold outstanding addresses (will match with data beats)
  bit [31:0] aw_addr_q[$]; // dynamic array used as queue
  bit [31:0] ar_addr_q[$];

  function new(string name="dma_monitor", uvm_component parent=null);
    super.new(name,parent);
    ap_wr = new("ap_wr", this);
    ap_rd = new("ap_rd", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual axi_if)::get(this,"","vif",mon_axi))
      `uvm_fatal("NOVIF", "AXI monitor: vif missing");
  endfunction

  virtual task run_phase(uvm_phase phase);
    fork
      collect_aw();
      collect_w();
      collect_ar();
      collect_r();
    join_none
  endtask

  task collect_aw();
    forever begin
      @(posedge mon_axi.clk);
      if (mon_axi.awvalid && mon_axi.awready) begin
        aw_addr_q.push_back(mon_axi.awaddr);
      end
    end
  endtask

  task collect_w();
    axi_write_s w;
    bit [31:0] cur_addr;
    forever begin
      @(posedge mon_axi.clk);
      if (mon_axi.wvalid && mon_axi.wready) begin
        if (aw_addr_q.size() == 0) begin
          `uvm_warning("MON", "W beat without AW address in queue")
          cur_addr = '0;
        end else begin
          cur_addr = aw_addr_q[0]; // take oldest
          if (mon_axi.wlast) begin
            // pop address only on last beat of burst
            aw_addr_q.pop_front();
          end
        end
        w.addr = cur_addr;
        w.data = mon_axi.wdata;
        w.wstrb = mon_axi.wstrb;
        w.last = mon_axi.wlast;
        ap_wr.write(w);
      end
    end
  endtask

  task collect_ar();
    forever begin
      @(posedge mon_axi.clk);
      if (mon_axi.arvalid && mon_axi.arready) begin
        ar_addr_q.push_back(mon_axi.araddr);
      end
    end
  endtask

  task collect_r();
    axi_read_s r;
    bit [31:0] cur_addr;
    forever begin
      @(posedge mon_axi.clk);
      if (mon_axi.rvalid && mon_axi.rready) begin
        if (ar_addr_q.size() == 0) begin
          `uvm_warning("MON", "R beat without AR address in queue")
          cur_addr = '0;
        end else begin
          cur_addr = ar_addr_q[0];
          if (mon_axi.rlast) begin
            ar_addr_q.pop_front();
          end
        end
        r.addr = cur_addr;
        r.data = mon_axi.rdata;
        r.last = mon_axi.rlast;
        ap_rd.write(r);
      end
    end
  endtask

endclass
