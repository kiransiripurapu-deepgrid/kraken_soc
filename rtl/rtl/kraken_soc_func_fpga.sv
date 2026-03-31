`timescale 1ns/1ps

module kraken_soc_func_fpga (
  input  logic       clk_i,
  input  logic       rst_ni,
  output logic [3:0] led_o
);

  logic [23:0] heartbeat_q;
  logic        mem_seen_q;
  logic        cutie_done_seen_q;
  logic        cutie_timeout_seen_q;
  logic [31:0] core_0_addr_dbg;
  logic [31:0] core_0_data_dbg;
  logic        core_0_req_dbg;
  logic        mem_valid_dbg;
  logic [31:0] mem_data_dbg;
  logic        cutie_busy_dbg;
  logic [1:0]  cutie_evt_dbg;

  kraken_soc_func i_soc (
    .clk_i         ( clk_i          ),
    .rst_ni        ( rst_ni         ),
    .test_en_i     ( 1'b0           ),
    .core_0_addr_o ( core_0_addr_dbg ),
    .core_0_data_o ( core_0_data_dbg ),
    .core_0_req_o  ( core_0_req_dbg ),
    .mem_valid_o   ( mem_valid_dbg  ),
    .mem_data_o    ( mem_data_dbg   ),
    .cutie_busy_o  ( cutie_busy_dbg ),
    .cutie_evt_o   ( cutie_evt_dbg  )
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      heartbeat_q          <= '0;
      mem_seen_q           <= 1'b0;
      cutie_done_seen_q    <= 1'b0;
      cutie_timeout_seen_q <= 1'b0;
      led_o                <= 4'b0000;
    end else begin
      heartbeat_q <= heartbeat_q + 24'd1;
      if (mem_valid_dbg)
        mem_seen_q <= 1'b1;
      if (cutie_evt_dbg[0])
        cutie_done_seen_q <= 1'b1;
      if (cutie_evt_dbg[1])
        cutie_timeout_seen_q <= 1'b1;

      led_o[0] <= heartbeat_q[23];
      led_o[1] <= mem_seen_q;
      led_o[2] <= cutie_busy_dbg;
      led_o[3] <= cutie_done_seen_q | cutie_timeout_seen_q;
    end
  end

endmodule
