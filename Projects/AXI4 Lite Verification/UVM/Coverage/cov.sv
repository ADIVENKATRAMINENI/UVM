class axi_coverage extends uvm_component;
  `uvm_component_utils(axi_coverage)
  virtual axi_if.MONITOR vif;

  covergroup cg @(posedge vif.ACLK);
    option.per_instance=1;

    cp_awvalid : coverpoint vif.AWVALID { bins active={1}; bins idle={0}; }
    cp_wvalid  : coverpoint vif.WVALID  { bins active={1}; bins idle={0}; }
    cp_arvalid : coverpoint vif.ARVALID { bins active={1}; bins idle={0}; }
    cp_rvalid  : coverpoint vif.RVALID  { bins active={1}; bins idle={0}; }

    cp_awaddr : coverpoint vif.AWADDR {
      bins regs_0_3   = {[0:12]};
      bins regs_4_7   = {[16:28]};
      bins regs_8_11  = {[32:44]};
      bins regs_12_15 = {[48:60]};
      bins out_of_range = default;
    }
    cp_araddr : coverpoint vif.ARADDR {
      bins regs_0_3   = {[0:12]};
      bins regs_4_7   = {[16:28]};
      bins regs_8_11  = {[32:44]};
      bins regs_12_15 = {[48:60]};
      bins out_of_range = default;
    }
    cp_wdata : coverpoint vif.WDATA { bins zeros={32'h0}; bins other=default; }
    cp_rdata : coverpoint vif.RDATA { bins zeros={32'h0}; bins other=default; }

    cp_wstrb : coverpoint vif.WSTRB {
      bins byte0={4'b0001}; bins byte1={4'b0010}; bins byte2={4'b0100};
      bins byte3={4'b1000}; bins full={4'b1111}; bins other=default;
    }

    cp_bresp : coverpoint vif.BRESP { bins okay={2'b00}; bins err={2'b10,2'b11}; }
    cp_rresp : coverpoint vif.RRESP { bins okay={2'b00}; bins err={2'b10,2'b11}; }

    cr_aw_w : cross(vif.AWVALID,vif.WVALID);
    cr_addr_data : cross(vif.AWADDR,vif.WDATA);
  endgroup

  function new

