interface riscv_if (
    input logic clk,
    input logic reset
);

    // ===============================
    // DUT <-> Testbench Signals
    // ===============================

    // Instruction Memory Interface
    logic [31:0] imem_addr;
    logic [31:0] imem_rdata;

    // Data Memory Interface
    logic [31:0] dmem_addr;
    logic [31:0] dmem_wdata;
    logic [3:0]  dmem_wstrb;
    logic        dmem_we;
    logic [31:0] dmem_rdata;

    // Architectural State (observed)
    logic [31:0] pc_out;
    logic [31:0] regs_out [0:31];

    // ===============================
    // Clocking Block (for TB)
    // ===============================
  clocking cb @(posedge clk);
    default input #1step output #1step;

    // TB reads what CPU drives
    input  imem_addr;
    input  dmem_addr;
    input  dmem_wdata;
    input  dmem_wstrb;
    input  dmem_we;
    input  pc_out;
    input  regs_out;
    
    // TB drives memory responses
    output imem_rdata;
    output dmem_rdata;
endclocking


    // ===============================
    // MODPORTS 
    // ===============================

    // DUT modport
    modport DUT (
        input  clk,
        input  reset,
        output imem_addr,
        input  imem_rdata,
        output dmem_addr,
        output dmem_wdata,
        output dmem_wstrb,
        output dmem_we,
        input  dmem_rdata,
        output pc_out,
        output regs_out
    );

    // Driver (Memory model / instruction feeder)
    modport DRIVER (
        clocking cb,
        output imem_rdata,
        output dmem_rdata
    );

    // Monitor (passive observation)
    modport MONITOR (
        clocking cb
    );

    // ===============================
    // Assertions (SVA)
    // ===============================

    // x0 must always be zero
    property x0_never_changes;
        @(posedge clk) disable iff (reset)
        regs_out[0] == 32'h0;
    endproperty
    assert property (x0_never_changes)
        else $error("ASSERTION FAIL: x0 register changed!");

    // PC must be 4-byte aligned
    property pc_alignment;
        @(posedge clk) disable iff (reset)
        pc_out[1:0] == 2'b00;
    endproperty
    assert property (pc_alignment)
        else $error("ASSERTION FAIL: PC misaligned!");

    // No memory writes during reset
    property no_write_during_reset;
        @(posedge clk)
        reset |-> !dmem_we;
    endproperty
    assert property (no_write_during_reset)
        else $error("ASSERTION FAIL: Write during reset!");

    // Store must have valid write strobe
    property store_has_strobe;
        @(posedge clk) disable iff (reset)
        dmem_we |-> (dmem_wstrb != 4'b0000);
    endproperty
    assert property (store_has_strobe)
        else $error("ASSERTION FAIL: Store without strobe!");


endinterface

