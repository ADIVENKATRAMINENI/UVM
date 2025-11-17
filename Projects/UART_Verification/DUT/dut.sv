// UART TX DUT

`timescale 1ns/1ps
module uart_tx #(
  parameter int DATA_WIDTH = 8
)(
  input  logic                  clk,
  input  logic                  rst_n,
  input  logic                  tx_start,
  input  logic [DATA_WIDTH-1:0] tx_data,
  input  logic                  baud_tick,
  output logic                  tx_line,   // serial output
  output logic                  tx_busy
);

  typedef enum logic [1:0] {IDLE, START, DATA, STOP} tx_state_e;
  tx_state_e state;

  logic [DATA_WIDTH-1:0] shifter;
  logic [$clog2(DATA_WIDTH):0] bit_cnt;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state   <= IDLE;
      tx_line <= 1'b1; // idle high
      tx_busy <= 1'b0;
      shifter <= '0;
      bit_cnt <= '0;
    end else begin
      case (state)
        IDLE: begin
          tx_line <= 1'b1;
          tx_busy <= 1'b0;
          if (tx_start) begin
            shifter <= tx_data;
            bit_cnt <= '0;
            tx_busy <= 1'b1;
            state   <= START;
          end
        end

        START: if (baud_tick) begin
          tx_line <= 1'b0; // start bit
          state   <= DATA;
        end

        DATA: if (baud_tick) begin
          tx_line <= shifter[0];
          shifter <= {1'b0, shifter[DATA_WIDTH-1:1]};
          if (bit_cnt == DATA_WIDTH-1) begin
            state   <= STOP;
          end
          bit_cnt <= bit_cnt + 1'b1;
        end

        STOP: if (baud_tick) begin
          tx_line <= 1'b1; // stop bit
          state   <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule









// UART RX DUT
`timescale 1ns/1ps
module uart_rx #(
  parameter int DATA_WIDTH = 8
)(
  input  logic                  clk,
  input  logic                  rst_n,
  input  logic                  rx_line,   // serial input
  input  logic                  baud_tick,
  output logic [DATA_WIDTH-1:0] rx_data,
  output logic                  rx_valid
);

  typedef enum logic [1:0] {RX_IDLE, RX_START, RX_DATA, RX_STOP} rx_state_e;
  rx_state_e state;

  logic [DATA_WIDTH-1:0] shifter;
  logic [$clog2(DATA_WIDTH):0] bit_cnt;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state   <= RX_IDLE;
      shifter <= '0;
      bit_cnt <= '0;
      rx_data <= '0;
      rx_valid<= 1'b0;
    end else begin
      rx_valid <= 1'b0; // default
      case (state)
        RX_IDLE: begin
          if (rx_line == 1'b0) begin // start bit detected
            state   <= RX_START;
          end
        end

        RX_START: if (baud_tick) begin
          // assume still low (start bit)
          bit_cnt <= '0;
          state   <= RX_DATA;
        end

        RX_DATA: if (baud_tick) begin
          shifter <= {rx_line, shifter[DATA_WIDTH-1:1]}; // LSB-first
          if (bit_cnt == DATA_WIDTH-1) begin
            state <= RX_STOP;
          end
          bit_cnt <= bit_cnt + 1'b1;
        end

        RX_STOP: if (baud_tick) begin
          // assume rx_line == 1 (stop bit)
          rx_data  <= shifter;
          rx_valid <= 1'b1;
          state    <= RX_IDLE;
        end

        default: state <= RX_IDLE;
      endcase
    end
  end

endmodule









  
  
  
  
  
  

  
