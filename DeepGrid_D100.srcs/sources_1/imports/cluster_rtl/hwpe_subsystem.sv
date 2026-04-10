// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

/*
 * hwpe_subsystem.sv
 * Francesco Conti <fconti@iis.ee.ethz.ch>
 */

`include "hci_helpers.sv"

module hwpe_subsystem
  import hci_package::*;
  import pulp_cluster_package::*;
#(
  parameter  hwpe_subsystem_cfg_t HWPE_CFG = hwpe_subsystem_cfg_t'{'0, '0},
  parameter  int unsigned N_CORES          = 8,
  parameter  int unsigned N_MASTER_PORT    = 9,
  parameter  int unsigned ID_WIDTH         = 8,
  parameter  hci_package::hci_size_parameter_t HCI_HWPE_SIZE = '0
)
(
  input  logic                             clk,
  input  logic                             rst_n,
  input  logic                             test_mode,
  input  logic                             hwpe_en_i,
  input  logic [$clog2(MAX_NUM_HWPES)-1:0] hwpe_sel_i,

  hci_core_intf.initiator                  hwpe_xbar_master,
  XBAR_PERIPH_BUS.Slave                    hwpe_cfg_slave,

  output logic [N_CORES-1:0][1:0]          evt_o,
  output logic                             busy_o
);

  localparam int unsigned DW = 32;
  localparam int unsigned AW = 32;
  localparam int unsigned EW = 4;
  localparam int unsigned EHW = 4;

  localparam int unsigned N_HWPES = HWPE_CFG.NumHwpes;
  localparam int unsigned HWPE_SEL_BITS = (N_HWPES > 1) ? $clog2(N_HWPES) : 1;

  logic [N_HWPES-1:0] busy;
  logic [N_HWPES-1:0][N_CORES-1:0][1:0] evt;

  logic [N_HWPES-1:0] hwpe_clk;
  logic [N_HWPES-1:0] hwpe_en_int;

  logic [HWPE_SEL_BITS-1:0] hwpe_sel_int;

  assign hwpe_sel_int = hwpe_sel_i[HWPE_SEL_BITS-1:0];

  hci_core_intf #(
    .DW   ( DW  ),
    .AW   ( AW  ),
    .EW   ( EW  ),
    .EHW  ( EHW )
  ) tcdm [0:N_HWPES-1] (.clk(clk));

  // CUTIE integration (single HWPE for now).
  // - Control via `hwpe_cfg_slave` (XBAR_PERIPH_BUS).
  // - Data movement via CUTIE's internal external-mem ports for now (no HCI use yet).
  // - Keep `hwpe_xbar_master` idle.

  logic [1:0] cutie_evt;

  cutie_hwpe_wrap i_cutie (
    .clk_i   ( clk           ),
    .rst_ni  ( rst_n         ),
    .cfg_bus ( hwpe_cfg_slave ),
    .evt_o   ( cutie_evt     ),
    .busy_o  ( busy[0]       )
  );

  // Broadcast CUTIE event to all cores (bit0 = done)
  for (genvar c = 0; c < N_CORES; c++) begin : gen_evt_bcast
    assign evt[0][c] = cutie_evt;
  end

  assign evt_o  = evt[0];
  assign busy_o = busy[0];

  // keep unused hwpe_xbar_master quiescent
  assign hwpe_xbar_master.req     = 1'b0;
  assign hwpe_xbar_master.add     = '0;
  assign hwpe_xbar_master.wen     = 1'b0;
  assign hwpe_xbar_master.data    = '0;
  assign hwpe_xbar_master.be      = '0;
  assign hwpe_xbar_master.user    = '0;
  assign hwpe_xbar_master.id      = '0;
  assign hwpe_xbar_master.r_ready = 1'b1;
  assign hwpe_xbar_master.ecc     = '0;
  assign hwpe_xbar_master.ereq    = 1'b0;
  assign hwpe_xbar_master.r_eready= 1'b1;

endmodule
