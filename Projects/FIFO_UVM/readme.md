#Project Overview 

##This FIFO_Verification project contains a complete UVM verification environment for a synchronous FIFO design.
###The folder is organized in a standard industry structure as follows:

fifo_verification/
│
├── dut/                 # FIFO RTL (pointer + MSB wrap design)
├── tb/                  # UVM testbench files
│   ├── fifo_if.sv       # Interface
│   ├── fifo_pkg.sv      # All UVM classes packaged
│   ├── seq_item/        # Sequence item (transaction)
│   ├── sequence/        # Sequences (directed + random)
│   ├── driver/          # Driver
│   ├── monitor/         # Monitor
│   ├── scoreboard/      # Reference model + checks
│   ├── coverage/        # Functional coverage
│   ├── env/             # Environment
│   ├── test/            # Smoke, directed, random tests
│   └── top/             # tb_top.sv (DUT + interface + UVM connect)
│
├── docs/                # Project documentation (explains everything)
├── waveforms/           # Screenshots / waveform captures
└── run.do               # QuestaSim run script (optional)


This structure shows how a real UVM verification project is organized — including DUT, interface, top TB, all UVM components/objects, and documentation.
