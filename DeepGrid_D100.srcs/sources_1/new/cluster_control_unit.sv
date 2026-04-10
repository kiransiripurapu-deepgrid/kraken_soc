module cluster_control_unit #(
  parameter int unsigned PER_ID_WIDTH  = 1,
  parameter int unsigned NB_CORES      = 8,
  parameter int unsigned NB_HWPES      = 8,
  parameter int unsigned ROM_BOOT_ADDR = 32'h1A000000,
  parameter int unsigned BOOT_ADDR     = 32'h1C000000
) (
  input  logic                        clk_i,
  input  logic                        rst_ni,
  input  logic                        en_sa_boot_i,
  input  logic                        fetch_en_i,
  XBAR_PERIPH_BUS.Slave               speriph_slave,
  output logic                        event_o,
  output logic                        eoc_o,
  output logic                        cluster_cg_en_o,
  output logic [NB_CORES-1:0][31:0]   boot_addr_o,
  output logic                        hwpe_en_o,
  output logic [$clog2(NB_HWPES)-1:0] hwpe_sel_o,
  output hci_package::hci_interconnect_ctrl_t hci_ctrl_o,
  output logic                        fregfile_disable_o,
  input  logic [NB_CORES-1:0]         core_halted_i,
  output logic [NB_CORES-1:0]         core_halt_o,
  output logic [NB_CORES-1:0]         core_resume_o,
  output logic [NB_CORES-1:0]         fetch_enable_o,
  output logic [1:0]                  TCDM_arb_policy_o
);

  assign event_o            = 1'b0;
  assign eoc_o              = 1'b0;
  assign cluster_cg_en_o    = 1'b1;
  assign hwpe_en_o          = 1'b0;
  assign hwpe_sel_o         = '0;
  assign hci_ctrl_o         = '0;
  assign fregfile_disable_o = 1'b0;
  assign core_halt_o        = '0;
  assign core_resume_o      = '0;
  assign fetch_enable_o     = {NB_CORES{fetch_en_i}};
  assign TCDM_arb_policy_o  = 2'b00;

  for (genvar i = 0; i < NB_CORES; i++) begin : gen_boot
    assign boot_addr_o[i] = BOOT_ADDR;
  end

  // Minimal always-responding peripheral stub (keeps fabric alive in synth).
  assign speriph_slave.gnt     = 1'b1;
  assign speriph_slave.r_valid = 1'b1;
  assign speriph_slave.r_rdata = 32'hDEADBEEF;
  assign speriph_slave.r_id    = '0;
  assign speriph_slave.r_opc   = '0;

endmodule

