class axi_scoreboard extends uvm_component;
  `uvm_component_utils(axi_scoreboard)
  uvm_analysis_imp#(axi_write_s, axi_scoreboard) imp_wr;
  uvm_analysis_imp#(axi_read_s, axi_scoreboard)  imp_rd;

  typedef bit [31:0] addr_t;
  typedef bit [31:0] data_t;
  typedef  associative_array #(data_t) reg_map_t;
  reg_map_t reg_model;

  function new(string name, uvm_component parent);
    super.new(name,parent);
    imp_wr = new("imp_wr", this);
    imp_rd = new("imp_rd", this);
  endfunction

  function void write(axi_write_s t);
    reg_model[t.addr] = t.data;
    `uvm_info("SCORE","Write model updated",UVM_LOW)
  endfunction

  function void write(axi_read_s t);
    bit [31:0] exp = reg_model.exists(t.addr) ? reg_model[t.addr] : '0;
    if(exp !== t.data)
      `uvm_error("SCORE",$sformatf("READ MISMATCH addr=0x%0h exp=0x%0h got=0x%0h",t.addr,exp,t.data))
    else
      `uvm_info("SCORE",$sformatf("READ MATCH addr=0x%0h data=0x%0h",t.addr,t.data),UVM_LOW)
  endfunction
endclass

