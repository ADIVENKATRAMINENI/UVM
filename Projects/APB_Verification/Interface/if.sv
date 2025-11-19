interface apb_if #(parameter ADDR_WIDTH=8, DATA_WIDTH=32) (input logic PCLK);

  logic PRESETn;
  logic PSEL;
  logic PENABLE;
  logic [ADDR_WIDTH-1:0] PADDR;
  logic PWRITE;
  logic [DATA_WIDTH-1:0] PWDATA;
  logic [DATA_WIDTH-1:0] PRDATA;
  logic PREADY;
  logic PSLVERR;

  // Clocking block for driver
  clocking cb @(posedge PCLK);
    default input #1 step output #2 step;
    output PSEL, PENABLE, PADDR, PWDATA, PWRITE;
    input PRESETn, PRDATA, PREADY, PSLVERR;
  endclocking

  // Modports
  modport drv (clocking cb, input PRESETn);
  modport mon (input PRESETn, PSEL, PENABLE, PADDR, PWRITE, PWDATA, PRDATA, PREADY, PSLVERR);

  // APB Assertions
  // SETUP -> ENABLE
  assert property (@(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && !PENABLE) |-> ##1 PENABLE
  );

  // Stable signals during ENABLE
  assert property (@(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && PENABLE) |-> $stable(PADDR) && $stable(PWRITE) && $stable(PWDATA)
  );

  // Stable PRDATA during read
  assert property (@(posedge PCLK)
    disable iff (!PRESETn)
    (PSEL && PENABLE && !PWRITE) |-> $stable(PRDATA)
  );

  // PSEL stable during ENABLE
  apb_psel_stable: assert property (@(posedge PCLK)
    disable iff (!PRESETn)
    PSEL && PENABLE |-> $stable(PSEL)
  ) else $error("APB ERROR: PSEL changed during ENABLE phase!");

  // Transfer completes only when PREADY=1
  apb_transfer_wait_for_pready: assert property (@(posedge PCLK)
    disable iff (!PRESETn)
    PENABLE |-> PREADY
  ) else $error("APB ERROR: Transfer in ENABLE without PREADY!");

endinterface

