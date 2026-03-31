`ifndef HCI_CORE_INTF_SV
`define HCI_CORE_INTF_SV

interface hci_core_intf #(
  parameter int unsigned DW  = 32,
  parameter int unsigned AW  = 32,
  parameter int unsigned BW  = 8,
  parameter int unsigned UW  = 0,
  parameter int unsigned IW  = 0,
  parameter int unsigned EW  = 0,
  parameter int unsigned EHW = 0
`ifndef SYNTHESIS
  ,
  parameter bit WAIVE_RSP3_ASSERT = 1'b0,
  parameter bit WAIVE_RSP5_ASSERT = 1'b0
`endif
)(
  input logic clk
);

  logic               req;
  logic [AW-1:0]      add;
  logic               wen;
  logic [DW-1:0]      data;
  logic [DW/8-1:0]    be;
  logic               gnt;
  logic               r_valid;
  logic [DW-1:0]      r_data;
  logic               r_opc;
  logic               r_ready;
  logic               user;
  logic               id;
  logic               ecc;
  logic               ereq;
  logic               r_eready;

  modport initiator (
    output req, add, wen, data, be, r_ready, user, id, ecc, ereq, r_eready,
    input  gnt, r_valid, r_data, r_opc
  );

  modport target (
    input  req, add, wen, data, be, r_ready, user, id, ecc, ereq, r_eready,
    output gnt, r_valid, r_data, r_opc
  );

endinterface

`endif
