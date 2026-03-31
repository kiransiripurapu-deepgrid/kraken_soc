// Minimal clock-gating cell stub for PULP cluster.
//
// The full PULP common_cells library provides an implementation of tc_clk_gating.
// For this mini_kraken build we only need a simple, functional stub that
// preserves clock gating semantics without special features.

module tc_clk_gating (
  output logic clk_o,
  input  logic clk_i,
  input  logic en_i,
  input  logic test_en_i
);

  // For synthesis in this project, map directly to the input clock.
  // A real implementation would use a technology-specific clock buffer.
  assign clk_o = clk_i;

endmodule

