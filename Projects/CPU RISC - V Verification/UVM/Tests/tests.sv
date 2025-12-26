class riscv_base_test extends uvm_test;
    `uvm_component_utils(riscv_base_test)

    riscv_env env;
    virtual riscv_if vif;

    function new(string name="riscv_base_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = riscv_env::type_id::create("env", this);

        if (!uvm_config_db#(virtual riscv_if)::get(this, "", "vif", vif))
            `uvm_fatal("TEST", "Virtual interface not found")

        uvm_config_db#(virtual riscv_if)::set(
            this, "env.agent.*", "vif", vif
        );
    endfunction
endclass


class riscv_reset_test extends riscv_base_test;
    `uvm_component_utils(riscv_reset_test)

    riscv_reset_seq reset_seq;

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        reset_seq = riscv_reset_seq::type_id::create("reset_seq");
        reset_seq.start(env.agent.sequencer);

        phase.drop_objection(this);
    endtask
endclass


class riscv_rtype_test extends riscv_base_test;
    `uvm_component_utils(riscv_rtype_test)

    riscv_rtype_seq rtype_seq;

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        rtype_seq = riscv_rtype_seq::type_id::create("rtype_seq");
        rtype_seq.start(env.agent.sequencer);

        phase.drop_objection(this);
    endtask
endclass


class riscv_itype_test extends riscv_base_test;
    `uvm_component_utils(riscv_itype_test)

    riscv_itype_seq itype_seq;

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        itype_seq = riscv_itype_seq::type_id::create("itype_seq");
        itype_seq.start(env.agent.sequencer);

        phase.drop_objection(this);
    endtask
endclass


class riscv_load_test extends riscv_base_test;
    `uvm_component_utils(riscv_load_test)

    riscv_load_seq load_seq;

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        load_seq = riscv_load_seq::type_id::create("load_seq");
        load_seq.start(env.agent.sequencer);

        phase.drop_objection(this);
    endtask
endclass


class riscv_store_test extends riscv_base_test;
    `uvm_component_utils(riscv_store_test)

    riscv_store_seq store_seq;

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        store_seq = riscv_store_seq::type_id::create("store_seq");
        store_seq.start(env.agent.sequencer);

        phase.drop_objection(this);
    endtask
endclass


class riscv_branch_test extends riscv_base_test;
    `uvm_component_utils(riscv_branch_test)

    riscv_branch_seq branch_seq;

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        branch_seq = riscv_branch_seq::type_id::create("branch_seq");
        branch_seq.start(env.agent.sequencer);

        phase.drop_objection(this);
    endtask
endclass



class riscv_jump_test extends riscv_base_test;
    `uvm_component_utils(riscv_jump_test)

    riscv_jump_seq jump_seq;

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        jump_seq = riscv_jump_seq::type_id::create("jump_seq");
        jump_seq.start(env.agent.sequencer);

        phase.drop_objection(this);
    endtask
endclass



class riscv_stress_test extends riscv_base_test;
    `uvm_component_utils(riscv_stress_test)

    riscv_stress_seq stress_seq;

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        stress_seq = riscv_stress_seq::type_id::create("stress_seq");
        stress_seq.start(env.agent.sequencer);

        phase.drop_objection(this);
    endtask
endclass


/*
+UVM_TESTNAME=riscv_reset_test
+UVM_TESTNAME=riscv_rtype_test
+UVM_TESTNAME=riscv_itype_test
+UVM_TESTNAME=riscv_load_test
+UVM_TESTNAME=riscv_store_test
+UVM_TESTNAME=riscv_branch_test
+UVM_TESTNAME=riscv_jump_test
+UVM_TESTNAME=riscv_stress_test
*/
