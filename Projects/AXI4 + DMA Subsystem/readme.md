# DMA_AXI4_Verification

## 📁 Project Directory
```text
DMA_AXI4_Verification/
│── docs/ → Project document (detailed)
│── rtl/ → DUT + AXI memory + interfaces
│   ├── axi_if.sv → AXI4 interface signals
│   ├── cfg_if.sv → DMA config interface
│   ├── dma.sv → DMA module (DUT)
│   ├── axi_mem.sv → Memory model
│── tb/
│   ├── dma_pkg.sv → Package for sequences, transaction items
│   ├── dma_txn.sv → Transaction item
│   ├── dma_sequences.sv → Smoke, burst, random sequences
│   ├── dma_driver.sv → Driver
│   ├── axi_monitor.sv → Monitor
│   ├── dma_scoreboard.sv → Scoreboard
│   ├── dma_coverage.sv → Coverage
│   ├── dma_agent.sv → Agent
│   ├── dma_env.sv → Environment
│── tests/
│   ├── base_test.sv
│   ├── smoke_test.sv
│   ├── burst_test.sv
│   ├── random_test.sv
│── tb_top.sv
📌 Project Summary
This project verifies a Simple Memory-Copy DMA Subsystem using SystemVerilog and UVM methodology. It includes complete stimulus, checking, coverage, scoreboard, and assertions.

Highlights:

Memory-to-memory DMA transfers over AXI4

Assertions inside interfaces (protocol timing checks)

Scoreboard compares expected vs actual memory content

Monitor publishes read/write transactions via analysis ports

Functional + code coverage goals

Random, directed, and stress tests for full verification

🎯 Features Verified
Correct DMA programming via cfg_if interface (SRC, DST, LEN, START/DONE)

AXI4 handshake correctness (AW, W, AR, R channels)

Read/write data correctness in memory

Back-to-back and burst transfers

Partial and full beats handling

Large transfers and stress/random scenarios

🧩 UVM Components Included
Transaction – dma_txn: src_addr, dst_addr, length

Sequence Items – dma_base_seq and specialized sequences (directed, random, back-to-back, large, stress)

Driver – Drives cfg_if and initiates DMA transfers

Monitor – Observes AXI4 read/write channels

Scoreboard – Compares memory model vs DUT transfer results

Coverage – Length, src/dst addresses, back-to-back, burst coverage

Agent – Driver + Monitor

Environment – Agent + Scoreboard + Coverage

Tests – dma_base_test runs all sequences

📝 Testcases Implemented
✔ smoke_test — simple DMA transfer verification

✔ directed_test — specific src/dst/length DMA transfer

✔ back_to_back_test — multiple consecutive DMA transfers

✔ large_test — single large transfer

✔ random_test — randomized DMA transfers

✔ stress_test — heavy load/randomized sequences

📊 Verification / Sign-off Flow
The verification flow used here follows industry standards:

Smoke test to verify basic connectivity

Directed and deterministic tests

Back-to-back and burst transfers

Randomized transactions for corner cases

Large transfer scenarios

Scoreboard and functional coverage checking

Regression and full verification sign-off

🏁 Conclusion
This project demonstrates a clean, modular, and fully reusable DMA UVM testbench. It verifies the memory-copy DMA subsystem thoroughly using a combination of:

✔ Assertions + ✔ Scoreboard + ✔ Coverage + ✔ Random & Directed Tests
