<h1>🚀 UART TX + RX Loopback Verification – SystemVerilog + UVM</h1>

<p>
This project implements a complete <b>UART Transmitter + Receiver loopback verification environment</b>. 
The UART TX serial output (<code>tx_line</code>) is directly connected to the UART RX serial input (<code>rx_line</code>), ensuring full protocol validation end-to-end.
</p>

<h2>📌 DUT Concept</h2>
<ul>
  <li><b>UART TX</b>: Generates serial waveform from parallel byte</li>
  <li><b>UART RX</b>: Reconstructs received serial waveform back to parallel byte</li>
  <li><b>Loopback</b>: <code>tx_line → rx_line</code></li>
  <li>Baud synchronization using <code>baud_tick</code></li>
</ul>

<h2>🎯 Verification Goals</h2>
<ul>
  <li>Start/Data/Parity/Stop bit protocol correctness</li>
  <li>Frame timing based on <code>baud_tick</code></li>
  <li>Data integrity: <code>TX data == RX data</code></li>
  <li>Random & directed stimulus + protocol coverage + assertions</li>
</ul>

<h2>📁 Repository Structure</h2>
<pre>
uart_verification/
│
├── dut/                       # UART TX and UART RX RTL
│
├── tb/                        # UVM Testbench files
│   ├── uart_if.sv             # Interface + Assertions
│   ├── uart_pkg.sv            # All UVM classes packaged
│   ├── seq_item/              # Transaction item
│   ├── sequence/              # Smoke / back-to-back / gap / random
│   ├── driver/                # Drives tx_start & tx_data
│   ├── monitor/               # Observes TX + RX activity
│   ├── scoreboard/            # Expected TX queue vs RX result match
│   ├── coverage/              # Functional coverage on rx_data
│   ├── env/                   # Agent + Scoreboard + Coverage
│   ├── test/                  # UVM testcase files
│   └── top/                   # tb_top.sv (DUT ⟷ UVM env)
│
├── docs/                      # Complete project documentation

</pre>

<h2>🧪 Testcases Implemented</h2>
<ul>
  <li><b>smoke_test</b> – Basic loopback sanity</li>
  <li><b>back_to_back_test</b> – No idle between frames</li>
  <li><b>gap_test</b> – Random idle spacing between frames</li>
  <li><b>random_test</b> – Stress test with 50 randomized bytes</li>
</ul>

<h2>🧠 Scoreboard Logic</h2>
<pre>
TX monitor → exp_fifo.push_back(data)
RX monitor → act_fifo.get(data)
Compare: expected == actual
</pre>

<h2>🛡 Assertions (Built Inside Interface)</h2>
<ul>
  <li>No <code>tx_start</code> while <code>tx_busy = 1</code></li>
  <li>Start bit must be LOW</li>
  <li>Stop bit must be HIGH</li>
  <li>Idle line must remain HIGH</li>
  <li><code>rx_valid</code> only after complete frame reception</li>
</ul>

<h2>📊 Verification Sign-Off Flow (Industry Standard)</h2>
<pre>
Directed Tests  +
Random Tests    +
Scoreboard      +
Assertions      +
Coverage
= Full UART Verification Sign-off 💯
</pre>

<h2>▶ How to Run</h2>
<pre>
vsim -c tb_top -do "run -all"
or
+UVM_TESTNAME=random_test
</pre>

<p>
This project demonstrates a <b>professional UVM verification environment</b> for a full UART TX↔RX system and is suitable for <b>GitHub portfolio, resume, and interviews</b>.
</p>
