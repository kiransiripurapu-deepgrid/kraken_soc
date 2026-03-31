module mchan #(
  parameter int unsigned NB_CTRLS                 = 2,
  parameter int unsigned NB_TRANSFERS             = 16,
  parameter int unsigned GLOBAL_TRANS_QUEUE_DEPTH = 4,
  parameter int unsigned TCDM_ADD_WIDTH           = 13,
  parameter int unsigned EXT_ADD_WIDTH            = 32,
  parameter int unsigned NB_OUTSND_TRANS          = 8,
  parameter int unsigned MCHAN_BURST_LENGTH       = 256,
  parameter int unsigned AXI_ADDR_WIDTH           = 32,
  parameter int unsigned AXI_DATA_WIDTH           = 64,
  parameter int unsigned AXI_USER_WIDTH           = 6,
  parameter int unsigned AXI_ID_WIDTH             = 4,
  parameter int unsigned PE_ID_WIDTH              = 1,
  parameter int unsigned DATA_WIDTH               = 32,
  parameter int unsigned BE_WIDTH                 = DATA_WIDTH/8
) (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic test_mode_i,

  input  logic [NB_CTRLS-1:0]                   ctrl_targ_req_i,
  input  logic [NB_CTRLS-1:0][EXT_ADD_WIDTH-1:0] ctrl_targ_add_i,
  input  logic [NB_CTRLS-1:0]                   ctrl_targ_type_i,
  input  logic [NB_CTRLS-1:0][BE_WIDTH-1:0]     ctrl_targ_be_i,
  input  logic [NB_CTRLS-1:0][DATA_WIDTH-1:0]   ctrl_targ_data_i,
  input  logic [NB_CTRLS-1:0][PE_ID_WIDTH-1:0]  ctrl_targ_id_i,
  output logic [NB_CTRLS-1:0]                   ctrl_targ_gnt_o,
  output logic [NB_CTRLS-1:0]                   ctrl_targ_r_opc_o,
  output logic [NB_CTRLS-1:0][PE_ID_WIDTH-1:0]  ctrl_targ_r_id_o,
  output logic [NB_CTRLS-1:0]                   ctrl_targ_r_valid_o,
  output logic [NB_CTRLS-1:0][DATA_WIDTH-1:0]   ctrl_targ_r_data_o,

  output logic [3:0]                            tcdm_init_req_o,
  output logic [3:0][TCDM_ADD_WIDTH-1:0]        tcdm_init_add_o,
  output logic [3:0]                            tcdm_init_type_o,
  output logic [3:0][BE_WIDTH-1:0]              tcdm_init_be_o,
  output logic [3:0][DATA_WIDTH-1:0]            tcdm_init_data_o,
  output logic [3:0]                            tcdm_init_sid_o,
  input  logic [3:0]                            tcdm_init_gnt_i,
  input  logic [3:0]                            tcdm_init_r_valid_i,
  input  logic [3:0][DATA_WIDTH-1:0]            tcdm_init_r_data_i,

  output logic                                  axi_master_aw_valid_o,
  output logic [AXI_ADDR_WIDTH-1:0]             axi_master_aw_addr_o,
  output logic [2:0]                            axi_master_aw_prot_o,
  output logic [3:0]                            axi_master_aw_region_o,
  output logic [7:0]                            axi_master_aw_len_o,
  output logic [2:0]                            axi_master_aw_size_o,
  output logic [1:0]                            axi_master_aw_burst_o,
  output logic                                  axi_master_aw_lock_o,
  output logic [3:0]                            axi_master_aw_cache_o,
  output logic [3:0]                            axi_master_aw_qos_o,
  output logic [AXI_ID_WIDTH-1:0]               axi_master_aw_id_o,
  output logic [AXI_USER_WIDTH-1:0]             axi_master_aw_user_o,
  input  logic                                  axi_master_aw_ready_i,

  output logic                                  axi_master_ar_valid_o,
  output logic [AXI_ADDR_WIDTH-1:0]             axi_master_ar_addr_o,
  output logic [2:0]                            axi_master_ar_prot_o,
  output logic [3:0]                            axi_master_ar_region_o,
  output logic [7:0]                            axi_master_ar_len_o,
  output logic [2:0]                            axi_master_ar_size_o,
  output logic [1:0]                            axi_master_ar_burst_o,
  output logic                                  axi_master_ar_lock_o,
  output logic [3:0]                            axi_master_ar_cache_o,
  output logic [3:0]                            axi_master_ar_qos_o,
  output logic [AXI_ID_WIDTH-1:0]               axi_master_ar_id_o,
  output logic [AXI_USER_WIDTH-1:0]             axi_master_ar_user_o,
  input  logic                                  axi_master_ar_ready_i,

  output logic                                  axi_master_w_valid_o,
  output logic [AXI_DATA_WIDTH-1:0]             axi_master_w_data_o,
  output logic [(AXI_DATA_WIDTH/8)-1:0]         axi_master_w_strb_o,
  output logic [AXI_USER_WIDTH-1:0]             axi_master_w_user_o,
  output logic                                  axi_master_w_last_o,
  input  logic                                  axi_master_w_ready_i,

  input  logic                                  axi_master_r_valid_i,
  input  logic [AXI_DATA_WIDTH-1:0]             axi_master_r_data_i,
  input  logic [1:0]                            axi_master_r_resp_i,
  input  logic                                  axi_master_r_last_i,
  input  logic [AXI_ID_WIDTH-1:0]               axi_master_r_id_i,
  input  logic [AXI_USER_WIDTH-1:0]             axi_master_r_user_i,
  output logic                                  axi_master_r_ready_o,

  input  logic                                  axi_master_b_valid_i,
  input  logic [1:0]                            axi_master_b_resp_i,
  input  logic [AXI_ID_WIDTH-1:0]               axi_master_b_id_i,
  input  logic [AXI_USER_WIDTH-1:0]             axi_master_b_user_i,
  output logic                                  axi_master_b_ready_o,

  output logic [NB_CTRLS+1:0]                    term_evt_o,
  output logic [NB_CTRLS+1:0]                    term_int_o,
  output logic                                  busy_o
);

  always_comb begin
    ctrl_targ_gnt_o     = '0;
    ctrl_targ_r_opc_o   = '0;
    ctrl_targ_r_id_o    = '0;
    ctrl_targ_r_valid_o = '0;
    ctrl_targ_r_data_o  = '0;

    tcdm_init_req_o     = '0;
    tcdm_init_add_o     = '0;
    tcdm_init_type_o    = '0;
    tcdm_init_be_o      = '0;
    tcdm_init_data_o    = '0;
    tcdm_init_sid_o     = '0;

    axi_master_aw_valid_o = 1'b0;
    axi_master_aw_addr_o  = '0;
    axi_master_aw_prot_o  = '0;
    axi_master_aw_region_o= '0;
    axi_master_aw_len_o   = '0;
    axi_master_aw_size_o  = '0;
    axi_master_aw_burst_o = '0;
    axi_master_aw_lock_o  = 1'b0;
    axi_master_aw_cache_o = '0;
    axi_master_aw_qos_o   = '0;
    axi_master_aw_id_o    = '0;
    axi_master_aw_user_o  = '0;

    axi_master_ar_valid_o = 1'b0;
    axi_master_ar_addr_o  = '0;
    axi_master_ar_prot_o  = '0;
    axi_master_ar_region_o= '0;
    axi_master_ar_len_o   = '0;
    axi_master_ar_size_o  = '0;
    axi_master_ar_burst_o = '0;
    axi_master_ar_lock_o  = 1'b0;
    axi_master_ar_cache_o = '0;
    axi_master_ar_qos_o   = '0;
    axi_master_ar_id_o    = '0;
    axi_master_ar_user_o  = '0;

    axi_master_w_valid_o  = 1'b0;
    axi_master_w_data_o   = '0;
    axi_master_w_strb_o   = '0;
    axi_master_w_user_o   = '0;
    axi_master_w_last_o   = 1'b0;

    axi_master_r_ready_o  = 1'b0;
    axi_master_b_ready_o  = 1'b0;

    term_evt_o = '0;
    term_int_o = '0;
    busy_o     = 1'b0;
  end

endmodule

