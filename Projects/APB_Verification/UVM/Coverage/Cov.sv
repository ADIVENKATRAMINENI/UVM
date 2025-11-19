class apb_coverage extends uvm_component;
  `uvm_component_utils(apb_coverage)
  virtual apb_if.mon vif;

  covergroup apb_cg @(posedge vif.PCLK);
    coverpoint vif.PSEL;
    coverpoint vif.PENABLE;
    coverpoint vif.PWRITE;

    coverpoint vif.PADDR iff (vif.PSEL && vif.PENABLE && vif.PREADY) {
      bins regs_0_7  = {[8'h00:8'h1C]};
      bins regs_8_15 = {[8'h20:8'h3C]};
    }

    coverpoint vif.PRDATA iff (vif.PSEL && vif.PENABLE && vif.PREADY) {
      bins zero  = {32'h0000_0000};
      bins other = default;
    }

    cross addr_and_rw = cross(vif.PADDR, vif.PWRITE) iff (vif.PSEL && vif.PENABLE && vif.PREADY);

    option.per_instance = 1;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if.mon)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","coverage needs apb_if");
    apb_cg = new();
  endfunction
endclass

