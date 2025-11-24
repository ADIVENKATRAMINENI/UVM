# **DMA + AXI4 Subsystem Verification (UVM) - Project Overview**

This repository contains a complete **UVM-based Simple Memory-Copy DMA + AXI4 Subsystem Verification Environment**.

📁 Project Structure
<p>This repository contains a complete <strong>UVM-based Simple Memory-Copy DMA Subsystem Verification Environment</strong>.</p>

DMA_AXI4_Verification/
│── docs/ → Project document (detailed)
│── rtl/ → DUT + AXI memory + interfaces
│ ├── axi_if.sv → AXI4 interface signals
│ ├── cfg_if.sv → DMA config interface
│ ├── dma.sv → DMA module (DUT)
│ ├── axi_mem.sv → Memory model
│── tb/
│ ├── dma_pkg.sv → Package for sequences, transaction items
│ ├── dma_txn.sv → Transaction item
│ ├── dma_sequences.sv → Smoke, burst, random sequences
│ ├── dma_driver.sv → Driver
│ ├── axi_monitor.sv → Monitor
│ ├── dma_scoreboard.sv → Scoreboard
│ ├── dma_coverage.sv → Coverage
│ ├── dma_agent.sv → Agent
│ ├── dma_env.sv → Environment
│── tests/
│ ├── base_test.sv
│ ├── smoke_test.sv
│ ├── burst_test.sv
│ ├── random_test.sv
│── tb_top.sv

📌 Project Summary
<p> This project verifies a <strong>Simple Memory-Copy DMA Subsystem</strong> using <strong>SystemVerilog and UVM methodology</strong>. It includes complete stimulus, checking, coverage, scoreboard, and assertions. </p> <ul> <li>Memory-to-memory DMA transfers over AXI4</li> <li>Assertions inside interfaces (protocol timing checks)</li> <li>Scoreboard compares expected vs actual memory content</li> <li>Monitor publishes read/write transactions via analysis ports</li> <li>Functional + code coverage goals</li> <li>Random, directed, and stress tests for full verification</li> </ul>
🎯 Features Verified
<ul> <li>Correct DMA programming via cfg_if interface (SRC, DST, LEN, START/DONE)</li> <li>AXI4 handshake correctness (AW, W, AR, R channels)</li> <li>Read/write data correctness in memory</li> <li>Back-to-back and burst transfers</li> <li>Partial and full beats handling</li> <li>Large transfers and stress/random scenarios</li> </ul>
🧩 UVM Components Included
<ul> <li><strong>Transaction</strong> – dma_txn: src_addr, dst_addr, length</li> <li><strong>Sequence Items</strong> – dma_base_seq and specialized sequences (directed, random, back-to-back, large, stress)</li> <li><strong>Driver</strong> – Drives cfg_if and initiates DMA transfers</li> <li><strong>Monitor</strong> – Observes AXI4 read/write channels</li> <li><strong>Scoreboard</strong> – Compares memory model vs DUT transfer results</li> <li><strong>Coverage</strong> – Length, src/dst addresses, back-to-back, burst coverage</li> <li><strong>Agent</strong> – Driver + Monitor</li> <li><strong>Environment</strong> – Agent + Scoreboard + Coverage</li> <li><strong>Tests</strong> – dma_base_test runs all sequences</li> </ul>
📝 Testcases Implemented
<ul> <li>✔ smoke_test — simple DMA transfer verification</li> <li>✔ directed_test — specific src/dst/length DMA transfer</li> <li>✔ back_to_back_test — multiple consecutive DMA transfers</li> <li>✔ large_test — single large transfer</li> <li>✔ random_test — randomized DMA transfers</li> <li>✔ stress_test — heavy load/randomized sequences</li> </ul>
📊 Sign-off Flow
<p>The verification flow used here matches industry standards:</p> <ol> <li>Smoke test to verify basic connectivity</li> <li>Directed and deterministic tests</li> <li>Back-to-back and burst transfers</li> <li>Randomized transactions for corner cases</li> <li>Large transfer scenarios</li> <li>Scoreboard and functional coverage checking</li> <li>Regression and full verification sign-off</li> </ol>
🏁 Conclusion
<p> This project demonstrates a clean, modular, and fully reusable DMA UVM testbench. It verifies the memory-copy DMA subsystem thoroughly using a combination of: </p> <p><strong>✔ Assertions + ✔ Scoreboard + ✔ Coverage + ✔ Random & Directed Tests</strong></p>
