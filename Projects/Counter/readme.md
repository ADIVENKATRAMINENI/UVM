# 🧩 UVM Counter Verification Project 

## 🎯 Goal

The goal of this project was to **build a complete UVM-based verification environment from scratch** for a simple 4-bit counter DUT. It demonstrates the **full UVM flow** from creating transactions, sequences, and agents to running simulations and observing DUT behavior using **EDA Playground**.

---

## 🧠 Key Concepts Covered

* **UVM Hierarchy** — `test → env → agent → sequencer/driver/monitor`
* **Factory & Configuration** — `uvm_config_db` for passing virtual interfaces
* **Stimulus Generation** — using `uvm_sequence` and `uvm_sequence_item`
* **Driver/Sequencer Handshake** — `seq_item_port ↔ seq_item_export`
* **Monitor & Analysis Port** — collecting DUT activity
* **Objections** — controlling simulation end (`raise_objection`, `drop_objection`)
* **Reporting** — using `uvm_info` for simulation logs

---

## ⚙️ Step-by-Step Summary

### 1️⃣ DUT & Interface

* **DUT**: A 4-bit synchronous counter with *clk*, *reset*, and *enable*.
* **Interface (`counter_if`)**: Groups these signals together and connects the DUT and UVM environment.

### 2️⃣ Transaction (`counter_item`)

* Represents one operation (reset/enable values).
* Declares `rand` fields with constraints and is registered with the factory using:

  ```systemverilog
  `uvm_object_utils_begin(counter_item)
  ```

### 3️⃣ Sequencer & Sequence

* **Sequencer**: Handles transaction flow to the driver.
* **Sequence (`counter_seq`)**: Generates a series of randomized `counter_item` transactions and controls objections.

### 4️⃣ Driver

* Drives the DUT pins using values from the sequence.
* Fetches transactions using `seq_item_port.get_next_item()` and logs actions with `uvm_info`.

### 5️⃣ Monitor

* Passively observes DUT signals every clock cycle.
* Creates new `counter_item` objects and broadcasts them using `uvm_analysis_port`.

### 6️⃣ Agent & Environment

* **Agent** groups the driver, sequencer, and monitor.
* **Environment (`counter_env`)** instantiates the agent and connects TLM ports.

### 7️⃣ Test

* **`counter_test`** builds the environment and starts the main sequence.
* Uses `raise_objection` / `drop_objection` to keep simulation active during stimulus generation.

### 8️⃣ Top Module

* Instantiates DUT and interface.
* Connects virtual interface to UVM using:

  ```systemverilog
  uvm_config_db#(virtual counter_if)::set(null, "*", "vif", cif);
  run_test("counter_test");
  ```
* Starts simulation in EDA Playground.

---

## 🧩 Outcome

1. Successfully observed UVM phase flow (`build → connect → run`)
2. Randomized stimulus applied to DUT (reset/enable patterns)
3. Monitor printed live DUT values every cycle
4. Simulation ended gracefully using objections

---

## 💡 My Learning Highlights

* Learned **how UVM components communicate** through ports, exports, and analysis paths.
* Understood **factory creation, configuration propagation, and phase control**.
* Built confidence in writing a **complete UVM testbench** that can scale for real IPs or subsystems.

---

## 🧾 Quick Reference (Core Files)

| File                 | Description                                    |
| -------------------- | ---------------------------------------------- |
| `counter.sv`         | 4-bit counter DUT                              |
| `counter_if.sv`      | Interface definition                           |
| `counter_item.sv`    | Transaction (sequence item)                    |
| `counter_seq.sv`     | Stimulus generator (sequence)                  |
| `counter_driver.sv`  | Drives DUT pins                                |
| `counter_monitor.sv` | Observes DUT activity                          |
| `counter_agent.sv`   | Combines driver, sequencer, monitor            |
| `counter_env.sv`     | Holds the agent                                |
| `counter_test.sv`    | Top-level UVM test                             |
| `top.sv`             | Connects DUT, interface, and starts simulation |

---

## 🚀 Result

Running this project in **EDA Playground** produced sequential logs like:

```
UVM_INFO @0ns: build_phase
UVM_INFO @20ns: DRV Driving item: reset=0 enable=1
UVM_INFO @30ns: MON Observed: reset=0 enable=1 count=3
...
```

indicating successful stimulus-to-response flow across the entire UVM testbench.

---

✅ **Summary:**<br>
This project forms a solid foundation for understanding *how a UVM testbench is structured and operates*.<br>
It’s an ideal starting point for beginners exploring **IP and subsystem-level verification** workflows.
