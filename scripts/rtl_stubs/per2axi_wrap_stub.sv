module per2axi_wrap #(
  parameter int unsigned NB_CORES       = 4,
  parameter int unsigned PER_ADDR_WIDTH = 32,
  parameter int unsigned PER_ID_WIDTH   = 5,
  parameter int unsigned AXI_ADDR_WIDTH = 32,
  parameter int unsigned AXI_DATA_WIDTH = 64,
  parameter int unsigned AXI_USER_WIDTH = 6,
  parameter int unsigned AXI_ID_WIDTH   = 4,
  parameter int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH/8,
  parameter int unsigned ID_WIDTH       = PER_ID_WIDTH,
  parameter type         axi_req_t      = logic,
  parameter type         axi_resp_t     = logic
) (
  input  logic           clk_i,
  input  logic           rst_ni,
  input  logic           test_en_i,
  XBAR_PERIPH_BUS.Slave  periph_slave,
  output axi_req_t       axi_master_req_o,
  input  axi_resp_t      axi_master_resp_i,
  output logic           busy_o
);
  always_comb begin
    axi_master_req_o = '0;
    periph_slave.gnt     = 1'b1;
    periph_slave.r_valid = 1'b0;
    periph_slave.r_opc   = 1'b0;
    periph_slave.r_id    = '0;
    periph_slave.r_rdata = '0;
    busy_o = 1'b0;
  end
endmodule
