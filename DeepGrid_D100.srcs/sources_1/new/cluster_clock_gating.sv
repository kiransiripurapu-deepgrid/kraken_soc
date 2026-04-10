module cluster_clock_gating (
  input  logic clk_i,
  input  logic en_i,
  input  logic test_en_i,
  output logic clk_o
);
  tc_clk_gating i_tc_clk_gating (
    .clk_i     ( clk_i     ),
    .en_i      ( en_i      ),
    .test_en_i ( test_en_i ),
    .clk_o     ( clk_o     )
  );
endmodule
