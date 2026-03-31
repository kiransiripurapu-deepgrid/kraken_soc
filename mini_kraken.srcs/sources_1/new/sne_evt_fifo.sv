`timescale 1ns/1ps

// SNE Event Ingress FIFO
// 16-entry, 32-bit, synchronous FIFO with sticky overflow,
// push/pop counters, and high-watermark tracking.
// Designed as a clean ingress buffer so a future DMA source
// can drive push_valid_i / push_data_i directly.

module sne_evt_fifo (
  input  logic        clk_i,
  input  logic        rst_ni,

  // Push interface
  input  logic        push_valid_i,
  input  logic [31:0] push_data_i,

  // Pop interface
  input  logic        pop_ready_i,
  output logic        pop_valid_o,
  output logic [31:0] pop_data_o,

  // Control
  input  logic        flush_i,
  input  logic        clear_overflow_i,
  input  logic        clear_watermark_i,

  // Status
  output logic [4:0]  count_o,
  output logic        empty_o,
  output logic        full_o,
  output logic        overflow_sticky_o,
  output logic        overflow_pulse_o,

  // Counters
  output logic [31:0] push_count_o,
  output logic [31:0] pop_count_o,

  // High-watermark: max occupancy since last clear
  output logic [4:0]  watermark_o
);

  // Storage
  logic [31:0] mem [0:15];
  logic [3:0]  wr_ptr_q;
  logic [3:0]  rd_ptr_q;
  logic [4:0]  count_q;
  logic        overflow_sticky_q;
  logic        overflow_pulse_q;
  logic [31:0] push_count_q;
  logic [31:0] pop_count_q;
  logic [4:0]  watermark_q;

  // Internal signals
  logic do_push, do_pop;

  assign do_push = push_valid_i && !full_o;
  assign do_pop  = pop_ready_i && !empty_o;

  // Outputs
  assign count_o          = count_q;
  assign empty_o          = (count_q == 5'd0);
  assign full_o           = (count_q == 5'd16);
  assign overflow_sticky_o = overflow_sticky_q;
  assign overflow_pulse_o  = overflow_pulse_q;
  assign push_count_o     = push_count_q;
  assign pop_count_o      = pop_count_q;
  assign watermark_o      = watermark_q;

  assign pop_valid_o = !empty_o;
  assign pop_data_o  = mem[rd_ptr_q];

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      wr_ptr_q         <= '0;
      rd_ptr_q         <= '0;
      count_q          <= '0;
      overflow_sticky_q <= 1'b0;
      overflow_pulse_q  <= 1'b0;
      push_count_q     <= '0;
      pop_count_q      <= '0;
      watermark_q      <= '0;
    end else begin
      overflow_pulse_q <= 1'b0;

      if (flush_i) begin
        wr_ptr_q         <= '0;
        rd_ptr_q         <= '0;
        count_q          <= '0;
        overflow_sticky_q <= 1'b0;
      end else begin
        // Push
        if (push_valid_i && !full_o) begin
          mem[wr_ptr_q]  <= push_data_i;
          wr_ptr_q       <= wr_ptr_q + 4'd1;
          push_count_q   <= push_count_q + 32'd1;
        end

        // Overflow detection
        if (push_valid_i && full_o) begin
          overflow_sticky_q <= 1'b1;
          overflow_pulse_q  <= 1'b1;
        end

        // Pop
        if (pop_ready_i && !empty_o) begin
          rd_ptr_q     <= rd_ptr_q + 4'd1;
          pop_count_q  <= pop_count_q + 32'd1;
        end

        // Count update
        if (do_push && !do_pop)
          count_q <= count_q + 5'd1;
        else if (!do_push && do_pop)
          count_q <= count_q - 5'd1;
        // simultaneous push+pop: count unchanged

        // Watermark tracking
        if (do_push && !do_pop) begin
          if ((count_q + 5'd1) > watermark_q)
            watermark_q <= count_q + 5'd1;
        end

        // Clear overflow (independent of flush)
        if (clear_overflow_i)
          overflow_sticky_q <= 1'b0;

        // Clear watermark
        if (clear_watermark_i)
          watermark_q <= count_q;
      end

      // Allow counter resets even during flush
      if (flush_i) begin
        push_count_q <= '0;
        pop_count_q  <= '0;
        watermark_q  <= '0;
      end
    end
  end

endmodule
