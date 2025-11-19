class apb_scoreboard extends uvm_component;
  `uvm_component_utils(apb_scoreboard)

  uvm_analysis_imp#(apb_write_s, apb_scoreboard) imp_wr;
  uvm_analysis_imp#(apb_read_s,  apb_scoreboard) imp_rd;

  parameter int NUM_REGS = 16;
  bit [31:0] ref_model [0:NUM_REGS-1];

  function new(string name, uvm_component parent);
    super.new(name, parent);
    imp_wr = new("imp_wr", this);
    imp_rd = new("imp_rd", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    for(int i=0; i<NUM_REGS; i++) ref_model[i] = '0;
    `uvm_info(get_type_name(), "Scoreboard model initialized to zeros", UVM_LOW)
  endfunction

  function void write(apb_write_s t);
    ref_model[t.addr] = t.data;
    `uvm_info("SCORE",$sformatf("WRITE model[0x%0h] = 0x%0h", t.addr, t.data), UVM_MEDIUM)
  endfunction

  function void write(apb_read_s t);
    bit [31:0] exp;
    if(ref_model.exists(t.addr)) exp = ref_model[t.addr];
    else exp = '0;

    if (exp !== t.data) begin
      `uvm_error("SCORE",$sformatf("READ MISMATCH addr=0x%0h exp=0x%0h got=0x%0h", t.addr, exp, t.data))
    end else begin
      `uvm_info("SCORE",$sformatf("READ MATCH addr=0x%0h data=0x%0h", t.addr, t.data), UVM_LOW)
    end
  endfunction
endclass

