// dma_sequencer.sv
`include "dma_pkg.sv"

class dma_sequencer extends uvm_sequencer #(dma_txn);
    `uvm_component_utils(dma_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
