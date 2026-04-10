module prim_subreg #(
  parameter int unsigned DW = 32,
  parameter              SWACCESS = "RW",
  parameter logic [DW-1:0] RESVAL = '0
) (
  input  logic           clk_i,
  input  logic           rst_ni,
  input  logic           we,
  input  logic [DW-1:0]  wd,
  input  logic           de,
  input  logic [DW-1:0]  d,
  output logic           qe,
  output logic [DW-1:0]  q,
  output logic [DW-1:0]  qs
);

  logic [DW-1:0] next_q;

  always_comb begin
    next_q = q;

    if (de) begin
      next_q = d;
    end

    if (we) begin
      if (SWACCESS == "W0C") begin
        next_q = next_q & ~wd;
      end else begin
        next_q = wd;
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      q <= RESVAL;
    end else begin
      q <= next_q;
    end
  end

  assign qe = we;
  assign qs = q;

endmodule
