`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

// Include your package
import riscv_pkg::*;

module tb_top;

    // -------------------------------
    // Clock & Reset
    // -------------------------------
    logic clk;
    logic rst_n;

    // -------------------------------
    // Interface
    // -------------------------------
    riscv_if riscv_vif (
        .clk   (clk),
        .rst_n (rst_n)
    );

    // -------------------------------
    // DUT Instance
    // -------------------------------
    riscv_core dut (
        .clk        (clk),
        .rst_n      (rst_n),

        // Instruction side
        .instr      (riscv_vif.instr),
        .pc         (riscv_vif.pc),

        // Register writeback
        .rd_addr    (riscv_vif.rd_addr),
        .rd_data    (riscv_vif.rd_data),
        .rd_we      (riscv_vif.rd_we),

        // Memory interface
        .mem_addr   (riscv_vif.mem_addr),
        .mem_wdata  (riscv_vif.mem_wdata),
        .mem_rdata  (riscv_vif.mem_rdata),
        .mem_we     (riscv_vif.mem_we),
        .mem_re     (riscv_vif.mem_re)
    );

    // -------------------------------
    // Clock Generation (100 MHz)
    // -------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // -------------------------------
    // Reset Generation
    // -------------------------------
    initial begin
        rst_n = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
    end

    // -------------------------------
    // UVM Configuration
    // -------------------------------
    initial begin
        // Make interface visible to UVM
        uvm_config_db#(virtual riscv_if)::set(
            null, "*", "vif", riscv_vif
        );

        // Start UVM
        run_test();
    end

    // -------------------------------
    // Optional Wave Dump
    // -------------------------------
    initial begin
        $dumpfile("riscv_uvm.vcd");
        $dumpvars(0, tb_top);
    end

endmodule




/*
# Reset test
vsim +UVM_TESTNAME=riscv_reset_test tb_top

# R-type test
vsim +UVM_TESTNAME=riscv_rtype_test tb_top

# Stress test
vsim +UVM_TESTNAME=riscv_stress_test tb_top
*/
