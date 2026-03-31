module axi2mem #(
  parameter int unsigned AXI_ADDR_WIDTH = 32,
  parameter int unsigned AXI_DATA_WIDTH = 64,
  parameter int unsigned AXI_USER_WIDTH = 6,
  parameter int unsigned AXI_ID_WIDTH   = 6,
  parameter int unsigned NB_DMAS         = 4
) (
  input  logic                             clk_i,
  input  logic                             rst_ni,
  output logic [NB_DMAS-1:0]               tcdm_master_req_o,
  output logic [NB_DMAS-1:0][31:0]         tcdm_master_add_o,
  output logic [NB_DMAS-1:0]               tcdm_master_type_o,
  output logic [NB_DMAS-1:0][31:0]         tcdm_master_data_o,
  output logic [NB_DMAS-1:0][3:0]          tcdm_master_be_o,
  input  logic [NB_DMAS-1:0]               tcdm_master_gnt_i,
  input  logic [NB_DMAS-1:0]               tcdm_master_r_valid_i,
  input  logic [NB_DMAS-1:0][31:0]         tcdm_master_r_data_i,
  output logic                             busy_o,
  input  logic                             test_en_i,
  input  logic                             axi_slave_aw_valid_i,
  input  logic [AXI_ADDR_WIDTH-1:0]        axi_slave_aw_addr_i,
  input  logic [2:0]                       axi_slave_aw_prot_i,
  input  logic [3:0]                       axi_slave_aw_region_i,
  input  logic [7:0]                       axi_slave_aw_len_i,
  input  logic [2:0]                       axi_slave_aw_size_i,
  input  logic [1:0]                       axi_slave_aw_burst_i,
  input  logic                             axi_slave_aw_lock_i,
  input  logic [3:0]                       axi_slave_aw_cache_i,
  input  logic [3:0]                       axi_slave_aw_qos_i,
  input  logic [AXI_ID_WIDTH-1:0]          axi_slave_aw_id_i,
  input  logic [AXI_USER_WIDTH-1:0]        axi_slave_aw_user_i,
  output logic                             axi_slave_aw_ready_o,
  input  logic                             axi_slave_ar_valid_i,
  input  logic [AXI_ADDR_WIDTH-1:0]        axi_slave_ar_addr_i,
  input  logic [2:0]                       axi_slave_ar_prot_i,
  input  logic [3:0]                       axi_slave_ar_region_i,
  input  logic [7:0]                       axi_slave_ar_len_i,
  input  logic [2:0]                       axi_slave_ar_size_i,
  input  logic [1:0]                       axi_slave_ar_burst_i,
  input  logic                             axi_slave_ar_lock_i,
  input  logic [3:0]                       axi_slave_ar_cache_i,
  input  logic [3:0]                       axi_slave_ar_qos_i,
  input  logic [AXI_ID_WIDTH-1:0]          axi_slave_ar_id_i,
  input  logic [AXI_USER_WIDTH-1:0]        axi_slave_ar_user_i,
  output logic                             axi_slave_ar_ready_o,
  input  logic                             axi_slave_w_valid_i,
  input  logic [AXI_DATA_WIDTH-1:0]        axi_slave_w_data_i,
  input  logic [(AXI_DATA_WIDTH/8)-1:0]    axi_slave_w_strb_i,
  input  logic [AXI_USER_WIDTH-1:0]        axi_slave_w_user_i,
  input  logic                             axi_slave_w_last_i,
  output logic                             axi_slave_w_ready_o,
  output logic                             axi_slave_r_valid_o,
  output logic [AXI_DATA_WIDTH-1:0]        axi_slave_r_data_o,
  output logic [1:0]                       axi_slave_r_resp_o,
  output logic                             axi_slave_r_last_o,
  output logic [AXI_ID_WIDTH-1:0]          axi_slave_r_id_o,
  output logic [AXI_USER_WIDTH-1:0]        axi_slave_r_user_o,
  input  logic                             axi_slave_r_ready_i,
  output logic                             axi_slave_b_valid_o,
  output logic [1:0]                       axi_slave_b_resp_o,
  output logic [AXI_ID_WIDTH-1:0]          axi_slave_b_id_o,
  output logic [AXI_USER_WIDTH-1:0]        axi_slave_b_user_o,
  input  logic                             axi_slave_b_ready_i
);

  always_comb begin
    tcdm_master_req_o  = '0;
    tcdm_master_add_o  = '0;
    tcdm_master_type_o = '0;
    tcdm_master_data_o = '0;
    tcdm_master_be_o   = '0;
    busy_o             = 1'b0;

    axi_slave_aw_ready_o = 1'b1;
    axi_slave_ar_ready_o = 1'b1;
    axi_slave_w_ready_o  = 1'b1;

    axi_slave_r_valid_o = 1'b0;
    axi_slave_r_data_o  = '0;
    axi_slave_r_resp_o  = 2'b00;
    axi_slave_r_last_o  = 1'b0;
    axi_slave_r_id_o    = '0;
    axi_slave_r_user_o  = '0;

    axi_slave_b_valid_o = 1'b0;
    axi_slave_b_resp_o  = 2'b00;
    axi_slave_b_id_o    = '0;
    axi_slave_b_user_o  = '0;
  end

endmodule
