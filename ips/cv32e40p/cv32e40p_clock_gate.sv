// FPGA-safe clock gate stub.
// On Artix-7 we avoid fabric-generated gated clocks and simply forward the
// clock. Functional gating intent is already neutralized at integration time.
module cv32e40p_clock_gate (
    input  logic clk_i,
    input  logic en_i,
    input  logic scan_cg_en_i,
    output logic clk_o
);

    logic unused_ok;
    assign unused_ok = en_i | scan_cg_en_i;
    assign clk_o = clk_i;

endmodule
