class riscv_base_seq extends uvm_sequence #(riscv_txn);
    `uvm_object_utils(riscv_base_seq)

    function new(string name="riscv_base_seq");
        super.new(name);
    endfunction

endclass


class riscv_reset_seq extends riscv_base_seq;
    `uvm_object_utils(riscv_reset_seq)

    function new(string name="riscv_reset_seq");
        super.new(name);
    endfunction

    virtual task body();
        riscv_txn txn;

        `uvm_info("RESET_SEQ", "Applying reset (no instruction)", UVM_LOW)

        txn = riscv_txn::type_id::create("txn");
        txn.instr = 32'h00000013; // NOP (ADDI x0,x0,0)
        txn.pc    = 32'h0;

        start_item(txn);
        finish_item(txn);
    endtask
endclass

class riscv_rtype_seq extends riscv_base_seq;
    `uvm_object_utils(riscv_rtype_seq)

    function new(string name="riscv_rtype_seq");
        super.new(name);
    endfunction

    virtual task body();
        riscv_txn txn;

        foreach (int i [0:5]) begin
            txn = riscv_txn::type_id::create($sformatf("rtype_txn_%0d", i));

            // Example: ADD x3, x1, x2
            txn.instr = {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011};
            txn.pc    = 32'h100 + i*4;

            start_item(txn);
            finish_item(txn);
        end
    endtask
endclass


class riscv_itype_seq extends riscv_base_seq;
    `uvm_object_utils(riscv_itype_seq)

    function new(string name="riscv_itype_seq");
        super.new(name);
    endfunction

    virtual task body();
        riscv_txn txn;

        // ADDI x5, x1, 10
        txn = riscv_txn::type_id::create("addi_txn");
        txn.instr = {12'd10, 5'd1, 3'b000, 5'd5, 7'b0010011};
        txn.pc    = 32'h200;

        start_item(txn);
        finish_item(txn);
    endtask
endclass

class riscv_load_seq extends riscv_base_seq;
    `uvm_object_utils(riscv_load_seq)

    function new(string name="riscv_load_seq");
        super.new(name);
    endfunction

    virtual task body();
        riscv_txn txn;

        // LW x6, 0(x1)
        txn = riscv_txn::type_id::create("lw_txn");
        txn.instr = {12'd0, 5'd1, 3'b010, 5'd6, 7'b0000011};
        txn.pc    = 32'h300;

        start_item(txn);
        finish_item(txn);
    endtask
endclass

class riscv_load_seq extends riscv_base_seq;
    `uvm_object_utils(riscv_load_seq)

    function new(string name="riscv_load_seq");
        super.new(name);
    endfunction

    virtual task body();
        riscv_txn txn;

        // LW x6, 0(x1)
        txn = riscv_txn::type_id::create("lw_txn");
        txn.instr = {12'd0, 5'd1, 3'b010, 5'd6, 7'b0000011};
        txn.pc    = 32'h300;

        start_item(txn);
        finish_item(txn);
    endtask
endclass


class riscv_store_seq extends riscv_base_seq;
    `uvm_object_utils(riscv_store_seq)

    function new(string name="riscv_store_seq");
        super.new(name);
    endfunction

    virtual task body();
        riscv_txn txn;

        // SW x2, 4(x1)
        txn = riscv_txn::type_id::create("sw_txn");
        txn.instr = {7'd0, 5'd2, 5'd1, 3'b010, 5'd4, 7'b0100011};
        txn.pc    = 32'h400;

        start_item(txn);
        finish_item(txn);
    endtask
endclass



class riscv_branch_seq extends riscv_base_seq;
    `uvm_object_utils(riscv_branch_seq)

    function new(string name="riscv_branch_seq");
        super.new(name);
    endfunction

    virtual task body();
        riscv_txn txn;

        // BEQ x1, x2, +8
        txn = riscv_txn::type_id::create("beq_txn");
        txn.instr = {7'b0000000,5'd2,5'd1,3'b000,5'd8,7'b1100011};
        txn.pc    = 32'h500;

        start_item(txn);
        finish_item(txn);
    endtask
endclass



class riscv_jump_seq extends riscv_base_seq;
    `uvm_object_utils(riscv_jump_seq)

    function new(string name="riscv_jump_seq");
        super.new(name);
    endfunction

    virtual task body();
        riscv_txn txn;

        // JAL x1, +16
        txn = riscv_txn::type_id::create("jal_txn");
        txn.instr = {20'd16, 5'd1, 7'b1101111};
        txn.pc    = 32'h600;

        start_item(txn);
        finish_item(txn);
    endtask
endclass



class riscv_stress_seq extends riscv_base_seq;
    `uvm_object_utils(riscv_stress_seq)

    function new(string name="riscv_stress_seq");
        super.new(name);
    endfunction

    virtual task body();
        riscv_txn txn;

        // ADDI x1, x0, 5
        txn = riscv_txn::type_id::create("stress_1");
        txn.instr = {12'd5,5'd0,3'b000,5'd1,7'b0010011};
        txn.pc = 32'h700;
        start_item(txn); finish_item(txn);

        // ADD x2, x1, x1 (RAW hazard)
        txn = riscv_txn::type_id::create("stress_2");
        txn.instr = {7'd0,5'd1,5'd1,3'b000,5'd2,7'b0110011};
        txn.pc = 32'h704;
        start_item(txn); finish_item(txn);
    endtask
endclass



