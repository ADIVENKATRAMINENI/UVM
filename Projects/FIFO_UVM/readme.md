<h1>📁 Project Overview</h1>

<p>
This <b>FIFO_Verification</b> project contains a complete UVM verification environment for a synchronous FIFO design.
<br>
The folder is organized in a standard industry structure as follows:
</p>

<pre>
fifo_verification/
│
├── dut/                      # FIFO RTL (pointer + MSB wrap design)
│   └── fifo.sv
│
├── tb/                       # UVM testbench files
│   ├── fifo_if.sv            # Interface
│   ├── fifo_pkg.sv           # All UVM classes packaged
│   │
│   ├── seq_item/             # Sequence item (transaction)
│   │   └── fifo_seq_item.sv
│   │
│   ├── sequence/             # Sequences (directed + random)
│   │   └── fifo_sequence.sv
│   │
│   ├── driver/               # Driver
│   │   └── fifo_driver.sv
│   │
│   ├── monitor/              # Monitor
│   │   └── fifo_monitor.sv
│   │
│   ├── scoreboard/           # Reference model + checks
│   │   └── fifo_scoreboard.sv
│   │
│   ├── coverage/             # Functional coverage
│   │   └── fifo_coverage.sv
│   │
│   ├── env/                  # Environment
│   │   └── fifo_env.sv
│   │
│   ├── test/                 # Smoke, directed, random tests
│   │   ├── fifo_base_test.sv
│   │   ├── fifo_smoke_test.sv
│   │   ├── fifo_directed_test.sv
│   │   └── fifo_random_test.sv
│   │
│   └── top/                  # tb_top.sv (DUT + interface + UVM connect)
│       └── tb_top.sv
│
├── docs/                     # Project documentation (explains everything)
│   └── FIFO_Verification_Report.md
│
├── waveforms/                # Screenshots / waveform captures
│
└── run.do                    # QuestaSim run script (optional)
</pre>

<p>
This structure shows how a real UVM verification project is organized — including DUT, interface, top TB, all UVM components/objects, and documentation.
</p>
