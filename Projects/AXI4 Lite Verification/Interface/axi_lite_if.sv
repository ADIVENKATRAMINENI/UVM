interface axi_lite_if #(parameter ADDR_WIDTH=8, DATA_WIDTH=32)
                       (input logic ACLK, ARESETn);

  // Write address channel
  logic AWVALID, AWREADY;
  logic [ADDR_WIDTH-1:0] AWADDR;

  // Write data channel
  logic WVALID, WREADY;
  logic [DATA_WIDTH-1:0] WDATA;
  logic [(DATA_WIDTH/8)-1:0] WSTRB;

  // Write response channel
  logic BVALID, BREADY;
  logic [1:0] BRESP;

  // Read address channel
  logic ARVALID, ARREADY;
  logic [ADDR_WIDTH-1:0] ARADDR;

  // Read data channel
  logic RVALID, RREADY;
  logic [DATA_WIDTH-1:0] RDATA;
  logic [1:0] RRESP;

  // Master clocking
  clocking drv_cb @(posedge ACLK);
    default input #1step output #1step;
    output AWADDR, AWVALID, WDATA, WSTRB, WVALID, BREADY;
    output ARADDR, ARVALID, RREADY;
    input AWREADY, WREADY, BVALID, BRESP, ARREADY, RVALID, RDATA, RRESP;
  endclocking

  // Monitor clocking
  clocking mon_cb @(posedge ACLK);
    default input #1step;
    input AWADDR, AWVALID, AWREADY;
    input WDATA, WSTRB, WVALID, WREADY;
    input BVALID, BREADY, BRESP;
    input ARADDR, ARVALID, ARREADY;
    input RDATA, RRESP, RVALID, RREADY;
  endclocking

  // Modports
  modport MASTER  (clocking drv_cb, input ARESETn);
  modport MONITOR (clocking mon_cb, input ARESETn);

endinterface

