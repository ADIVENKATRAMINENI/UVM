//======================================================
// RISC-V UVM Environment
//======================================================

class riscv_env extends uvm_env;

    `uvm_component_utils(riscv_env)

    // ---------------------------------------------
    // Environment Components
    // ---------------------------------------------
    riscv_agent      agent;
    riscv_scoreboard scoreboard;
    riscv_coverage   coverage;

    // ---------------------------------------------
    // Constructor
    // ---------------------------------------------
    function new(string name="riscv_env", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    // ---------------------------------------------
    // Build Phase
    // ---------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create agent
        agent = riscv_agent::type_id::create("agent", this);

        // Create scoreboard
        scoreboard = riscv_scoreboard::type_id::create("scoreboard", this);

        // Create coverage
        coverage = riscv_coverage::type_id::create("coverage", this);
    endfunction

    // ---------------------------------------------
    // Connect Phase
    // ---------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Instruction transactions
        agent.monitor.instr_ap.connect(scoreboard.instr_imp);
        agent.monitor.instr_ap.connect(coverage.instr_imp);

        // Memory transactions
        agent.monitor.mem_ap.connect(scoreboard.mem_imp);
        agent.monitor.mem_ap.connect(coverage.mem_imp);
    endfunction

endclass

