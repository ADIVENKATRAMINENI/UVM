//====================
// counter.sv (DUT)
//====================
module counter(
  input  logic       clk,
  input  logic       reset,   // async active-high
  input  logic       enable,
  output logic [3:0] count
);
  always_ff @(posedge clk or posedge reset) begin
    if (reset)      count <= '0;
    else if (enable) count <= count + 1'b1;
  end
endmodule









//====================
// counter_if.sv (Interface)
//====================
interface counter_if(input logic clk);
  logic       reset;
  logic       enable;
  logic [3:0] count;
endinterface
