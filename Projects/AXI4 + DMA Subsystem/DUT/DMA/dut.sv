module dma #(parameter ADDR_WIDTH=32, DATA_WIDTH=32)(
    input logic clk,
    input logic reset,
    input cfg_if cfg,         // config interface
    output axi_if axi         // AXI master interface
);
    typedef enum logic [1:0] {IDLE, READ, WRITE, DONE} state_t;
    state_t state;

    logic [31:0] addr_src, addr_dst, len;
    logic [31:0] data_buffer;

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= IDLE;
            cfg.done <= 0;
        end else begin
            case(state)
                IDLE: if(cfg.start) begin
                    addr_src <= cfg.src_addr;
                    addr_dst <= cfg.dst_addr;
                    len      <= cfg.length;
                    cfg.done <= 0;
                    state    <= READ;
                end
                READ: begin
                    axi.araddr  <= addr_src;
                    axi.arvalid <= 1;
                    if(axi.rvalid) begin
                        data_buffer <= axi.rdata;
                        addr_src <= addr_src + 4;
                        state <= WRITE;
                    end
                end
                WRITE: begin
                    axi.awaddr  <= addr_dst;
                    axi.wdata   <= data_buffer;
                    axi.awvalid <= 1;
                    axi.wvalid  <= 1;
                    if(axi.bvalid) begin
                        addr_dst <= addr_dst + 4;
                        len <= len - 4;
                        state <= (len>0) ? READ : DONE;
                    end
                end
                DONE: begin
                    cfg.done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
