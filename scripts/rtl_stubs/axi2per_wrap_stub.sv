module axi2per_wrap #(
  parameter int unsigned PER_ADDR_WIDTH = 32,
  parameter int unsigned PER_ID_WIDTH   = 5,
  parameter int unsigned AXI_ADDR_WIDTH = 32,
  parameter int unsigned AXI_DATA_WIDTH = 64,
  parameter int unsigned AXI_USER_WIDTH = 6,
  parameter int unsigned AXI_ID_WIDTH   = 6,
  parameter int unsigned BUFFER_DEPTH   = 2,
  parameter int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH/8,
  parameter type         axi_req_t      = logic,
  parameter type         axi_resp_t     = logic
) (
  input  logic         clk_i,
  input  logic         rst_ni,
  input  logic         test_en_i,
  input  axi_req_t     axi_slave_req_i,
  output axi_resp_t    axi_slave_resp_o,
  XBAR_TCDM_BUS.Master periph_master,
  output logic         busy_o
);
  always_comb begin
    axi_slave_resp_o = '0;
    periph_master.req     = 1'b0;
    periph_master.add     = '0;
    periph_master.wen     = 1'b1;
    periph_master.wdata   = '0;
    periph_master.be      = '0;
    busy_o = 1'b0;
  end
endmodule
