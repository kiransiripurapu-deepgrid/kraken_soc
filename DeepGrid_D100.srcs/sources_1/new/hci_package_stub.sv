package hci_package;
  // Return either the argument minus 1 or 0 if 0; useful for IO vector width declaration.
  function automatic integer unsigned iomsb(input integer unsigned width);
    return (width != 32'd0) ? unsigned'(width - 1) : 32'd0;
  endfunction

  typedef struct packed {
    logic [1:0] arb_policy;
    logic       invert_prio;
    logic [7:0] low_prio_max_stall;
  } hci_interconnect_ctrl_t;

  typedef struct packed {
    int unsigned DW;
    int unsigned AW;
    int unsigned BW;
    int unsigned UW;
    int unsigned IW;
    int unsigned EW;
    int unsigned EHW;
  } hci_size_parameter_t;

  localparam int unsigned DEFAULT_DW  = 32;
  localparam int unsigned DEFAULT_AW  = 32;
  localparam int unsigned DEFAULT_BW  = 8;
  localparam int unsigned DEFAULT_UW  = 1;
  localparam int unsigned DEFAULT_IW  = 8;
  localparam int unsigned DEFAULT_EW  = 1;
  localparam int unsigned DEFAULT_EHW = 1;

  localparam hci_size_parameter_t DEFAULT_HCI_SIZE = '{
    DW  : DEFAULT_DW,
    AW  : DEFAULT_AW,
    BW  : DEFAULT_BW,
    UW  : DEFAULT_UW,
    IW  : DEFAULT_IW,
    EW  : DEFAULT_EW,
    EHW : DEFAULT_EHW
  };

  typedef struct packed {
    logic                                     req_start;
    hwpe_stream_package::ctrl_addressgen_v3_t addressgen_ctrl;
  } hci_streamer_ctrl_t;

  typedef struct packed {
    logic                                      ready_start;
    logic                                      done;
    hwpe_stream_package::flags_addressgen_v3_t addressgen_flags;
  } hci_streamer_flags_t;

  typedef enum logic [1:0] {
    STREAMER_IDLE,
    STREAMER_WORKING,
    STREAMER_DONE
  } hci_streamer_state_t;

  typedef enum logic [1:0] {
    COPY,
    NO_ECC,
    NO_DATA,
    CTRL_ONLY
  } hci_copy_t;

  typedef struct packed {
    logic [31:0] addr;
    logic        write;
    logic [31:0] wdata;
    logic [7:0]  wstrb;
    logic        valid;
  } hci_ecc_req_t;

  typedef struct packed {
    logic [31:0] rdata;
    logic        error;
    logic        ready;
  } hci_ecc_rsp_t;

endpackage : hci_package
