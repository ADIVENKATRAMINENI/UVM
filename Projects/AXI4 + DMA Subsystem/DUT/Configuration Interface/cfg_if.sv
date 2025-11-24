interface cfg_if(input logic clk, input logic reset);
    logic [31:0] src_addr;
    logic [31:0] dst_addr;
    logic [31:0] length;
    logic start;
    logic done;

    // reset logic
    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            src_addr <= 0;
            dst_addr <= 0;
            length   <= 0;
            start    <= 0;
            done     <= 0;
        end
    end

    // Clocking for driver
    clocking drv_cb @(posedge clk);
        output src_addr, dst_addr, length, start;
        input  done;
    endclocking

    // Clocking for monitor
    clocking mon_cb @(posedge clk);
        input src_addr, dst_addr, length, start, done;
    endclocking

    // Modports
    modport drv (clk, reset, cb => drv_cb);
    modport mon (clk, reset, cb => mon_cb);
endinterface

