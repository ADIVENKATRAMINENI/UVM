module axi_mem #(parameter ADDR_WIDTH=32, DATA_WIDTH=32, MEM_SIZE=1024)(
    input logic clk,
    input logic reset,
    input logic [ADDR_WIDTH-1:0] awaddr,
    input logic awvalid,
    output logic awready,
    input logic [DATA_WIDTH-1:0] wdata,
    input logic [(DATA_WIDTH/8)-1:0] wstrb,
    input logic wvalid,
    output logic wready,
    output logic bvalid,
    input logic bready,
    input logic [ADDR_WIDTH-1:0] araddr,
    input logic arvalid,
    output logic arready,
    output logic [DATA_WIDTH-1:0] rdata,
    output logic rvalid,
    input logic rready
);
    logic [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1];

    assign awready = 1'b1;
    assign wready  = 1'b1;
    assign bvalid  = wvalid;
    assign arready = 1'b1;
    assign rvalid  = arvalid;
    assign rdata   = mem[araddr/4];

    always_ff @(posedge clk) begin
        if(wvalid) mem[awaddr/4] <= wdata;
    end
endmodule

