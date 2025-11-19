<h1>🔹 APB Protocol Verification (UVM) — Project Overview</h1>

<h2>📁 Project Structure</h2>
<p>This repository contains a complete <strong>UVM-based APB Slave Verification Environment</strong>.  
All files are organized into standard UVM hierarchy for easy readability and reuse.</p>

<pre>
APB_Verification/
│── docs/                → Project document (detailed)
│── dut/                 → APB DUT (slave)
│── interface/           → apb_if.sv (signals + assertions)
│── tb/
│    ├── seq_item/       → apb_tx.sv
│    ├── sequences/      → smoke, read, write, random tests
│    ├── driver/         → apb_driver.sv
│    ├── monitor/        → apb_monitor.sv
│    ├── agent/          → apb_agent.sv
│    ├── scoreboard/     → apb_scoreboard.sv
│    ├── coverage/       → apb_coverage.sv
│    └── env/            → apb_env.sv
│
│── tests/
│    ├── apb_base_test.sv
│    ├── apb_smoke_test.sv
│    ├── apb_write_test.sv
│    ├── apb_read_test.sv
│    └── apb_random_test.sv
│
└── top/                 → top_tb.sv (DUT + UVM + interface)
</pre>


<h2>📌 Project Summary</h2>
<p>
This project verifies an <strong>APB Slave</strong> using <strong>SystemVerilog and UVM methodology</strong>.  
It includes complete stimulus, checking, coverage, scoreboard, and assertions.
</p>

<ul>
  <li>APB Write + Read protocol verification</li>
  <li>Assertions inside interface (protocol timing checks)</li>
  <li>Scoreboard compares expected vs actual reads</li>
  <li>Monitor publishes transactions via analysis ports</li>
  <li>Functional + code coverage goals</li>
  <li>Random and directed tests for full sign-off</li>
</ul>


<h2>🎯 Features Verified</h2>
<ul>
  <li>Correct APB handshake (PSEL, PENABLE, PWRITE)</li>
  <li>Address + data stability rules</li>
  <li>Setup → Access phase timing</li>
  <li>Read/Write data correctness</li>
  <li>Register behavior validation</li>
  <li>Back-to-back APB transfers</li>
</ul>


<h2>🧩 UVM Components Included</h2>
<ul>
  <li><strong>Sequence Item</strong> – addr, wdata, rdata, read/write type</li>
  <li><strong>Driver</strong> – Drives APB protocol (setup + access)</li>
  <li><strong>Monitor</strong> – Collects bus activity</li>
  <li><strong>Scoreboard</strong> – Reference model register map</li>
  <li><strong>Coverage</strong> – Address, read/write, data bins</li>
  <li><strong>Agent</strong> – Driver + Monitor</li>
  <li><strong>Environment</strong> – Agent + Scoreboard + Coverage</li>
  <li><strong>Tests</strong> – smoke / read / write / random</li>
</ul>


<h2>📝 Testcases Implemented</h2>
<ul>
  <li>✔ smoke_test — basic connectivity</li>
  <li>✔ write_test — directed writes</li>
  <li>✔ read_test — directed reads</li>
  <li>✔ random_test — random addr/data operations</li>
</ul>


<h2>📊 Sign-off Flow</h2>
<p>The verification flow used here matches industry standards:</p>
<ol>
  <li>Smoke tests</li>
  <li>Directed read/write tests</li>
  <li>Random APB transactions</li>
  <li>Functional coverage measurement</li>
  <li>Assertions + Scoreboard checking</li>
  <li>Regression and sign-off</li>
</ol>


<h2>🏁 Conclusion</h2>
<p>
This project demonstrates a clean, modular, and fully reusable APB UVM testbench.  
It verifies the APB protocol behavior thoroughly using a combination of:
</p>

<p><strong>✔ Assertions + ✔ Scoreboard + ✔ Coverage + ✔ Random Tests</strong></p>

<p>Perfect for showcasing your verification skills on GitHub and in interviews.</p>
