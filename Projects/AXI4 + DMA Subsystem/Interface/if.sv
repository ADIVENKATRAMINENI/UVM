interface axi_if(input logic clk, input logic reset);

    // Write Address Channel
    logic [31:0] awaddr;
    logic        awvalid;
    logic        awready;

    // Write Data Channel
    logic [31:0] wdata;
    logic [(32/8)-1:0] wstrb;
    logic        wvalid;
    logic        wready;

    // Write Response Channel
    logic        bvalid;
    logic        bready;

    // Read Address Channel
    logic [31:0] araddr;
    logic        arvalid;
    logic        arready;

    // Read Data Channel
    logic [31:0] rdata;
    logic        rvalid;
    logic        rready;

    // Clocking block for driver
    clocking drv_cb @(posedge clk);
        output awaddr, awvalid, wdata, wstrb, wvalid, bready;
        input  awready, wready, bvalid;
        output araddr, arvalid, rready;
        input  arready, rvalid;
    endclocking

    // Clocking block for monitor
    clocking mon_cb @(posedge clk);
        input awaddr, awvalid, awready;
        input wdata, wstrb, wvalid, wready;
        input bvalid, bready;
        input araddr, arvalid, arready;
        input rdata, rvalid, rready;
    endclocking

    // Modports
    modport drv (clk, reset, cb => drv_cb);
    modport mon (clk, reset, cb => mon_cb);

    // AXI Assertions
    assert property (@(posedge clk) disable iff(reset)
        !(wvalid && !awvalid)
    ) else $error("AXI Write Data valid without AWVALID");

    assert property (@(posedge clk) disable iff(reset)
        !(rvalid && !arvalid)
    ) else $error("AXI Read Data valid without ARVALID");

endinterface

