interface uart_if (input logic clk);
  logic rst_n;
  logic tx_start;
  logic [7:0] tx_data;
  logic tx_busy;
  
  
  logic serial_line;
  
  logic[7:0]rx_data;
  logic rx_valid;
  
  
  clocking cb @(posedge clk);
    default input #1step output #1step;
    output tx_start,tx_data;
    input rst_n,rx_data,rx_valid,tx_busy,serial_line;
  endclocking
  
  modport drv(clocking cb,input rst_n);
    modport mon(input tx_data,tx_start,tx_busy,serial_line,rx_data,rx_valid,rst_n);


  // Disable assertions during reset
  `define ASSERT_RESET disable iff (!rst_n)

  // --------------------------------------------
  // A1: No tx_start request while TX is busy
  // --------------------------------------------
  property no_tx_start_when_busy;
    @(posedge clk) `ASSERT_RESET (tx_busy |-> !tx_start);
  endproperty
  assert property(no_tx_start_when_busy)
    else $error("UART ASSERTION FAILED: tx_start asserted when tx_busy = 1");


  // --------------------------------------------
  // A2: Start bit must be LOW when frame starts
  // --------------------------------------------
  property start_bit_low;
    @(posedge clk) `ASSERT_RESET (tx_start |-> serial_line== 1'b0);
  endproperty
  assert property(start_bit_low)
    else $error("UART ASSERTION FAILED: Start bit not LOW at frame start");


  // --------------------------------------------
  // A3: Stop bit must remain HIGH after frame
  // --------------------------------------------
  property stop_bit_high;
    @(posedge clk) `ASSERT_RESET (!tx_busy |-> serial_line == 1'b1);
  endproperty
  assert property(stop_bit_high)
    else $error("UART ASSERTION FAILED: Stop bit not HIGH during idle state");


  // --------------------------------------------
  // A4: TX line must remain HIGH when idle
  // --------------------------------------------
  property idle_line_high;
    @(posedge clk) `ASSERT_RESET (!tx_busy && !tx_start |-> serial_line == 1'b1);
  endproperty
  assert property(idle_line_high)
    else $error("UART ASSERTION FAILED: TX line not HIGH when idle");


  // --------------------------------------------
  // A5: RX must only report a byte when a full frame was received
  // --------------------------------------------
  property rx_valid_only_after_frame;
    @(posedge clk) `ASSERT_RESET (rx_valid |-> !tx_busy);
  endproperty
  assert property(rx_valid_only_after_frame)
    else $error("UART ASSERTION FAILED: rx_valid asserted while tx_busy = 1");
  
  
  endinterface
  
