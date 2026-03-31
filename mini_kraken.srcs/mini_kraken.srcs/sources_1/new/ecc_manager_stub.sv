module ecc_manager #(
  parameter int unsigned NumBanks = 4,
  parameter type ecc_mgr_req_t = logic,
  parameter type ecc_mgr_rsp_t = logic
) (
  input  logic                    clk_i,
  input  logic                    rst_ni,
  input  ecc_mgr_req_t            ecc_mgr_req_i,
  output ecc_mgr_rsp_t            ecc_mgr_rsp_o,
  input  logic [NumBanks-1:0]     bank_faults_i,
  input  logic [NumBanks-1:0]     scrub_fix_i,
  input  logic [NumBanks-1:0]     scrub_uncorrectable_i,
  output logic [NumBanks-1:0]     scrub_trigger_o,
  output logic                    test_write_mask_no
);
  assign ecc_mgr_rsp_o = '0;
  assign scrub_trigger_o = '0;
  assign test_write_mask_no = 1'b0;
endmodule
