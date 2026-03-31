// Minimal ibex_pkg stub for extracted PULP cluster RTL.
//
// Only the symbols referenced from core_region.sv are provided.

package ibex_pkg;

  typedef enum logic [1:0] {
    RV32MNone         = 2'b00,
    RV32MSingleCycle  = 2'b01,
    RV32MMultiCycle   = 2'b10
  } ibex_rv32m_e;

  typedef enum logic [1:0] {
    RegFileFF    = 2'b00,
    RegFileLatch = 2'b01,
    RegFileFPGA  = 2'b10
  } ibex_regfile_e;

  // Minimal RV32B extension selector; core_region only needs RV32BNone.
  typedef enum logic [1:0] {
    RV32BNone = 2'b00
  } ibex_rv32b_e;

endpackage : ibex_pkg

