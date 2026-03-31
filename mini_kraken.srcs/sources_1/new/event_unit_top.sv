module event_unit_top #(
  parameter int unsigned NB_CORES     = 8,
  parameter int unsigned NB_BARR      = 8,
  parameter int unsigned PER_ID_WIDTH = 9,
  parameter int unsigned EVNT_WIDTH   = 8
) (
  input  logic                        clk_i,
  input  logic                        rst_ni,
  input  logic                        test_mode_i,

  input  logic [NB_CORES-1:0][3:0]    acc_events_i,
  input  logic [NB_CORES-1:0][1:0]    dma_events_i,
  input  logic [NB_CORES-1:0][1:0]    timer_events_i,
  input  logic [NB_CORES-1:0][31:0]   cluster_events_i,

  output logic [NB_CORES-1:0][4:0]    core_irq_id_o,
  input  logic [NB_CORES-1:0][4:0]    core_irq_ack_id_i,
  output logic [NB_CORES-1:0]         core_irq_req_o,
  input  logic [NB_CORES-1:0]         core_irq_ack_i,
  input  logic [NB_CORES-1:0]         dbg_req_i,
  output logic [NB_CORES-1:0]         core_dbg_req_o,

  output logic [NB_BARR-1:0]          barrier_matched_o,
  input  logic [NB_CORES-1:0]         core_busy_i,
  output logic [NB_CORES-1:0]         core_clock_en_o,

  XBAR_PERIPH_BUS.Slave               speriph_slave,
  XBAR_PERIPH_BUS.Slave               eu_direct_link[NB_CORES-1:0],

  input  logic                        soc_periph_evt_valid_i,
  output logic                        soc_periph_evt_ready_o,
  input  logic [EVNT_WIDTH-1:0]       soc_periph_evt_data_i,

  MESSAGE_BUS.Master                  message_master
);

  assign core_irq_id_o       = '0;
  assign core_irq_req_o      = '0;
  assign core_dbg_req_o      = dbg_req_i;
  assign barrier_matched_o   = '0;
  assign core_clock_en_o     = {NB_CORES{1'b1}};
  assign soc_periph_evt_ready_o = 1'b1;

  // Keep peripheral slave responsive.
  assign speriph_slave.gnt     = 1'b1;
  assign speriph_slave.r_valid = 1'b1;
  assign speriph_slave.r_opc   = '0;
  assign speriph_slave.r_id    = '0;
  assign speriph_slave.r_rdata = 32'h0;

  // Direct-link per-core ports: respond benignly.
  for (genvar i = 0; i < NB_CORES; i++) begin : gen_eu_link
    assign eu_direct_link[i].gnt     = 1'b1;
    assign eu_direct_link[i].r_valid = 1'b1;
    assign eu_direct_link[i].r_opc   = '0;
    assign eu_direct_link[i].r_id    = '0;
    assign eu_direct_link[i].r_rdata = 32'h0;
  end

  // Message master unused in this functional synth build.
  assign message_master.req   = 1'b0;
  assign message_master.add   = '0;
  assign message_master.wen   = 1'b0;
  assign message_master.wdata = '0;
  assign message_master.be    = '0;
  assign message_master.id    = '0;

endmodule

