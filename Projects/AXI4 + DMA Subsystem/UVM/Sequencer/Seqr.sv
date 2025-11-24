class dma_seqr extends uvm_sequencer#(dma_txn);
  `uvm_component_utils(dma_seqr)
  
  function void(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass
