# DMA_AXI4_Verification

## 📁 Project Directory
```text
DMA_AXI4_Verification/
│── docs/ → Project document (detailed)
│── rtl/ → DUT + AXI memory + interfaces
│   ├── axi_if.sv       → AXI4 interface signals
│   ├── cfg_if.sv       → DMA config interface
│   ├── dma.sv          → DMA module (DUT)
│   ├── axi_mem.sv      → Memory model
│── tb/
│   ├── dma_pkg.sv       → Package for sequences, transaction items
│   ├── dma_txn.sv       → Transaction item
│   ├── dma_sequences.sv → Smoke, burst, random sequences
│   ├── dma_driver.sv    → Driver
│   ├── axi_monitor.sv   → Monitor
│   ├── dma_scoreboard.sv→ Scoreboard
│   ├── dma_coverage.sv  → Coverage
│   ├── dma_agent.sv     → Agent
│   ├── dma_env.sv       → Environment
│── tests/
│   ├── base_test.sv
│   ├── smoke_test.sv
│   ├── burst_test.sv
│   ├── random_test.sv
│── tb_top.sv
