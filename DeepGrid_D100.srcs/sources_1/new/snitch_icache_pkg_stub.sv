package snitch_icache_pkg;

  // Minimal stand-in for the real Snitch I-cache event structure.
  typedef struct packed {
    logic dummy;
  } icache_l1_events_t;

  typedef struct packed {
    logic dummy;
  } icache_l0_events_t;

  // Minimal request/response record types used by cluster_peripherals.
  typedef struct packed {
    logic dummy;
  } icache_req_t;

  typedef struct packed {
    logic dummy;
  } icache_rsp_t;

endpackage : snitch_icache_pkg;