interface fifo_if #(parameter DATA_WIDTH=8)(input logic clk);
  logic rst_n;
  logic wr_en;
  logic rd_en;
  logic [DATA_WIDTH-1:0]din;
  logic [DATA_WIDTH-1:0]dout;
  logic full,empty,almost_full,almost_empty;
  
  
 
  clocking cb @(posedge clk);
    default input #1step output #1step;
    output wr_en,rd_en,din;
    input full,empty,almost_full,almost_empty,rst_n,dout;
  endclocking
  
  modport drv(clocking cb, input rst_n);
  modport mon(input wr_en,rd_en,din,full,empty,almost_full,almost_empty,rst_n,dout);
    
endinterface 


