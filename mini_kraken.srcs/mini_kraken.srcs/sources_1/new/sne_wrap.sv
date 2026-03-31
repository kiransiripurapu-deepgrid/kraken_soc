`timescale 1ns/1ps

module sne_wrap (
  input  logic           clk_i,
  input  logic           rst_ni,
  XBAR_PERIPH_BUS.Slave  cfg_bus,
  output logic [1:0]     evt_o,
  output logic           busy_o
);

  // sne_pkg is imported by sne_complex internally; no direct use here.

  // ── Address decode ────────────────────────────────────────────────────────
  // Offsets 0x000-0xEFF → forwarded to sne_complex via APB
  // Offsets 0xF00-0xFFF → wrapper-local diagnostic/test registers
  logic req_is_local;
  assign req_is_local = (cfg_bus.add[11:8] == 4'hF);

  // ── Wrapper-local diagnostic registers ────────────────────────────────────
  logic [31:0] test_evt_ctrl_q;
  logic [31:0] test_tcdm_data_q;
  logic [31:0] test_status_q;
  logic [31:0] test_tcdm_req_q;
  logic [31:0] test_irq_count_q;
  logic [31:0] test_evt_count_q;
  logic [31:0] test_apb_wr_count_q;
  logic [31:0] test_apb_rd_count_q;
  logic [31:0] test_apb_last_addr_q;
  logic        evt_fifo_auto_run_q;
  logic [31:0] evt_fifo_last_q;
  logic [1:0]  sne_evt_in;
  logic        evt_fifo_pop_fire;
  logic        evt_fifo_done_pulse;

  // ── New extended registers ────────────────────────────────────────────────
  logic        evt_pop_strobe_q;        // single-pop request (self-clearing)
  logic [31:0] evt_pop_strobe_data_q;   // last data popped by manual strobe
  logic [31:0] evt_batch_done_count_q;  // increments when FIFO drains empty
  logic [2:0]  evt_error_flags_q;       // sticky: [0] overflow, [1] pop-empty, [2] dual-pop conflict
  logic        fifo_was_nonempty_q;     // tracks non-empty→empty transition for batch counting

  // ── FIFO instance signals ────────────────────────────────────────────────
  logic        fifo_push_valid;
  logic [31:0] fifo_push_data;
  logic        fifo_pop_ready;
  logic        fifo_pop_valid;
  logic [31:0] fifo_pop_data;
  logic        fifo_flush;
  logic        fifo_clear_overflow;
  logic        fifo_clear_watermark;
  logic [4:0]  fifo_count;
  logic        fifo_empty;
  logic        fifo_full;
  logic        fifo_overflow_sticky;
  logic        fifo_overflow_pulse;
  logic [31:0] fifo_push_count;
  logic [31:0] fifo_pop_count;
  logic [4:0]  fifo_watermark;

  sne_evt_fifo i_evt_fifo (
    .clk_i            ( clk_i               ),
    .rst_ni           ( rst_ni              ),
    .push_valid_i     ( fifo_push_valid     ),
    .push_data_i      ( fifo_push_data      ),
    .pop_ready_i      ( fifo_pop_ready      ),
    .pop_valid_o      ( fifo_pop_valid      ),
    .pop_data_o       ( fifo_pop_data       ),
    .flush_i          ( fifo_flush          ),
    .clear_overflow_i ( fifo_clear_overflow ),
    .clear_watermark_i( fifo_clear_watermark),
    .count_o          ( fifo_count          ),
    .empty_o          ( fifo_empty          ),
    .full_o           ( fifo_full           ),
    .overflow_sticky_o( fifo_overflow_sticky),
    .overflow_pulse_o ( fifo_overflow_pulse ),
    .push_count_o     ( fifo_push_count     ),
    .pop_count_o      ( fifo_pop_count      ),
    .watermark_o      ( fifo_watermark      )
  );

  // ── Local register read mux ──────────────────────────────────────────────
  // Backward-compatible: 0xF00-0xF30 unchanged. New: 0xF34-0xF40.
  logic [31:0] local_rdata;
  always_comb begin
    unique case (cfg_bus.add[7:2])
      6'h00:   local_rdata = test_evt_ctrl_q;      // 0xF00
      6'h01:   local_rdata = test_tcdm_data_q;     // 0xF04
      6'h02:   local_rdata = test_status_q;         // 0xF08
      6'h03:   local_rdata = test_tcdm_req_q;      // 0xF0C
      6'h04:   local_rdata = test_irq_count_q;     // 0xF10
      6'h05:   local_rdata = test_evt_count_q;     // 0xF14
      6'h06:   local_rdata = test_apb_wr_count_q;  // 0xF18
      6'h07:   local_rdata = test_apb_rd_count_q;  // 0xF1C
      6'h08:   local_rdata = test_apb_last_addr_q; // 0xF20
      6'h09:   local_rdata = evt_fifo_last_q;      // 0xF24
      6'h0A:   local_rdata = {24'd0, fifo_overflow_sticky, evt_fifo_auto_run_q,
                              fifo_empty, fifo_full,
                              sne_interrupt, fifo_count}; // 0xF28
      6'h0B:   local_rdata = fifo_push_count;       // 0xF2C
      6'h0C:   local_rdata = fifo_pop_count;         // 0xF30
      6'h0D:   local_rdata = evt_pop_strobe_data_q;  // 0xF34 — last manual-popped data
      6'h0E:   local_rdata = evt_batch_done_count_q; // 0xF38
      6'h0F:   local_rdata = {29'd0, evt_error_flags_q}; // 0xF3C
      6'h10:   local_rdata = {27'd0, fifo_watermark};    // 0xF40
      default: local_rdata = 32'hDEAD_C0DE;
    endcase
  end

  // ── XBAR_PERIPH_BUS → APB bridge ──────────────────────────────────────────
  typedef enum logic [1:0] {
    APB_IDLE,
    APB_SETUP,
    APB_ACCESS,
    LOCAL_RESP
  } apb_state_e;

  apb_state_e apb_state_q, apb_state_d;

  logic        apb_psel;
  logic        apb_penable;
  logic        apb_pwrite;
  logic [31:0] apb_paddr;
  logic [31:0] apb_pwdata;
  logic [31:0] apb_prdata;
  logic        apb_pready;
  logic        apb_pslverr;

  // Latch the request on grant
  logic [31:0] req_addr_q;
  logic [31:0] req_wdata_q;
  logic        req_pwrite_q;
  logic        req_is_local_q;
  logic [31:0] local_rdata_q;

  // Track APB transactions for diagnostics
  logic        apb_txn_complete;
  logic        apb_txn_was_write;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      apb_state_q    <= APB_IDLE;
      req_addr_q     <= '0;
      req_wdata_q    <= '0;
      req_pwrite_q   <= 1'b0;
      req_is_local_q <= 1'b0;
      local_rdata_q  <= '0;
    end else begin
      apb_state_q <= apb_state_d;
      if (apb_state_q == APB_IDLE && cfg_bus.req) begin
        req_addr_q     <= cfg_bus.add;
        req_wdata_q    <= cfg_bus.wdata;
        req_pwrite_q   <= ~cfg_bus.wen; // XBAR wen=1 → read; APB pwrite=1 → write
        req_is_local_q <= req_is_local;
        local_rdata_q  <= local_rdata;  // capture read data for next-cycle response
      end
    end
  end

  always_comb begin
    apb_state_d      = apb_state_q;
    apb_psel         = 1'b0;
    apb_penable      = 1'b0;
    apb_pwrite       = req_pwrite_q;
    apb_paddr        = req_addr_q;
    apb_pwdata       = req_wdata_q;
    apb_txn_complete = 1'b0;
    apb_txn_was_write = req_pwrite_q;

    cfg_bus.gnt     = 1'b0;
    cfg_bus.r_valid = 1'b0;
    cfg_bus.r_rdata = apb_prdata;
    cfg_bus.r_opc   = 1'b0;
    cfg_bus.r_id    = cfg_bus.id;

    unique case (apb_state_q)
      APB_IDLE: begin
        if (cfg_bus.req) begin
          cfg_bus.gnt = 1'b1;
          if (req_is_local) begin
            // Local register — grant now, respond next cycle
            apb_state_d = LOCAL_RESP;
          end else begin
            apb_state_d = APB_SETUP;
          end
        end
      end

      LOCAL_RESP: begin
        // Deliver response one cycle after grant — reads only.
        // For writes, the SoC already pushes the response on the grant cycle,
        // so asserting r_valid here would cause a spurious double-push.
        if (!req_pwrite_q) begin
          // This was a read (XBAR wen=1 → pwrite=0)
          cfg_bus.r_valid = 1'b1;
          cfg_bus.r_rdata = local_rdata_q;
        end
        apb_state_d = APB_IDLE;
      end

      APB_SETUP: begin
        apb_psel    = 1'b1;
        apb_penable = 1'b0;
        apb_state_d = APB_ACCESS;
      end

      APB_ACCESS: begin
        apb_psel    = 1'b1;
        apb_penable = 1'b1;
        if (apb_pready) begin
          // For reads, deliver the response via r_valid.
          // For writes, the SoC already pushed the response on the grant
          // cycle, so r_valid must stay low to avoid a double-push.
          if (!req_pwrite_q) begin
            cfg_bus.r_valid = 1'b1;
            cfg_bus.r_rdata = apb_prdata;
          end
          apb_txn_complete = 1'b1;
          apb_state_d      = APB_IDLE;
        end
      end

      default: apb_state_d = APB_IDLE;
    endcase
  end

  // ── Wrapper-local register write logic ────────────────────────────────────
  logic local_wr_fire;
  assign local_wr_fire = cfg_bus.req && cfg_bus.gnt && req_is_local && !cfg_bus.wen;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      test_evt_ctrl_q        <= '0;
      test_tcdm_data_q       <= '0;
      test_status_q          <= 32'hCAFE_0000;
      test_tcdm_req_q        <= '0;
      test_irq_count_q       <= '0;
      test_evt_count_q       <= '0;
      test_apb_wr_count_q    <= '0;
      test_apb_rd_count_q    <= '0;
      test_apb_last_addr_q   <= '0;
      evt_fifo_auto_run_q    <= 1'b0;
      evt_fifo_last_q        <= '0;
      evt_pop_strobe_q       <= 1'b0;
      evt_pop_strobe_data_q  <= '0;
      evt_batch_done_count_q <= '0;
      evt_error_flags_q      <= '0;
      fifo_was_nonempty_q    <= 1'b0;
    end else begin
      // Self-clearing pop strobe
      evt_pop_strobe_q <= 1'b0;

      // Event injection: increment event counter when EVT_CTRL is written
      if (local_wr_fire && cfg_bus.add[7:2] == 6'h00) begin
        test_evt_ctrl_q  <= cfg_bus.wdata;
        test_evt_count_q <= test_evt_count_q + 32'd1;
      end

      // Scratch/test registers
      if (local_wr_fire) begin
        unique case (cfg_bus.add[7:2])
          6'h01: test_tcdm_data_q     <= cfg_bus.wdata;
          6'h02: test_status_q        <= cfg_bus.wdata;
          6'h03: test_tcdm_req_q      <= cfg_bus.wdata;
          6'h04: test_irq_count_q     <= cfg_bus.wdata;
          6'h05: test_evt_count_q     <= cfg_bus.wdata;
          6'h06: test_apb_wr_count_q  <= cfg_bus.wdata;
          6'h07: test_apb_rd_count_q  <= cfg_bus.wdata;
          6'h08: test_apb_last_addr_q <= cfg_bus.wdata;
          6'h09: begin
            // FIFO push via register write — handled combinationally below
            evt_fifo_last_q <= cfg_bus.wdata;
          end
          6'h0A: begin
            evt_fifo_auto_run_q <= cfg_bus.wdata[0];
            // bit[1]: flush FIFO
            // bit[2]: clear overflow only
            // (flush and clear_overflow are driven combinationally to FIFO)
          end
          6'h0B: ; // push_count is inside FIFO module now (read-only from wrapper)
          6'h0C: ; // pop_count is inside FIFO module now (read-only from wrapper)
          6'h0D: begin
            // Pop strobe: write any value to pop one entry
            evt_pop_strobe_q <= 1'b1;
          end
          6'h0E: evt_batch_done_count_q <= cfg_bus.wdata;
          6'h0F: begin
            // W1C: clear error flags by writing 1s
            evt_error_flags_q <= evt_error_flags_q & ~cfg_bus.wdata[2:0];
          end
          6'h10: ; // watermark: clear handled via fifo_clear_watermark
          default: ;
        endcase
      end

      // Track real APB transactions to sne_complex
      if (apb_txn_complete) begin
        test_apb_last_addr_q <= req_addr_q;
        if (apb_txn_was_write)
          test_apb_wr_count_q <= test_apb_wr_count_q + 32'd1;
        else
          test_apb_rd_count_q <= test_apb_rd_count_q + 32'd1;
      end

      // Count interrupts from sne_complex
      if (sne_interrupt)
        test_irq_count_q <= test_irq_count_q + 32'd1;

      // Capture manual pop data
      if (evt_pop_strobe_q && fifo_pop_valid)
        evt_pop_strobe_data_q <= fifo_pop_data;

      // Error flag: pop-while-empty
      if (evt_pop_strobe_q && fifo_empty)
        evt_error_flags_q[1] <= 1'b1;

      // Error flag: auto-run and manual pop at the same time
      if (evt_pop_strobe_q && evt_fifo_auto_run_q)
        evt_error_flags_q[2] <= 1'b1;

      // Error flag: overflow (mirrors FIFO sticky, but in error register)
      if (fifo_overflow_pulse)
        evt_error_flags_q[0] <= 1'b1;

      // Batch-done tracking: FIFO went from non-empty to empty
      fifo_was_nonempty_q <= !fifo_empty;
      if (fifo_was_nonempty_q && fifo_empty)
        evt_batch_done_count_q <= evt_batch_done_count_q + 32'd1;
    end
  end

  // ── FIFO push/pop/control wiring ─────────────────────────────────────────
  // Push: register write to 0xF24
  assign fifo_push_valid = local_wr_fire && (cfg_bus.add[7:2] == 6'h09);
  assign fifo_push_data  = cfg_bus.wdata;

  // Pop: auto-run OR manual strobe (auto-run takes priority for backward compat)
  assign evt_fifo_pop_fire = evt_fifo_auto_run_q && !fifo_empty;
  assign fifo_pop_ready    = evt_fifo_pop_fire || (evt_pop_strobe_q && !evt_fifo_auto_run_q);

  // Flush: write bit[1] of 0xF28
  assign fifo_flush = local_wr_fire && (cfg_bus.add[7:2] == 6'h0A) && cfg_bus.wdata[1];

  // Clear overflow: write bit[2] of 0xF28, or implicitly via flush
  assign fifo_clear_overflow = local_wr_fire && (cfg_bus.add[7:2] == 6'h0A) && cfg_bus.wdata[2];

  // Clear watermark: write any value to 0xF40
  assign fifo_clear_watermark = local_wr_fire && (cfg_bus.add[7:2] == 6'h10);

  // Done pulse: FIFO is about to drain its last entry
  assign evt_fifo_done_pulse = evt_fifo_pop_fire && (fifo_count == 5'd1);

  // Event input to sne_complex: FIFO data when popping, else direct register
  assign sne_evt_in = evt_fifo_pop_fire ? fifo_pop_data[1:0]
                                         : test_evt_ctrl_q[1:0];

  // ── SNE complex instance ──────────────────────────────────────────────────
  logic sne_interrupt;

  sne_complex #(
    .BASE_ADDRESS ( 32'h0 )
  ) i_sne (
    .system_clk_i       ( clk_i        ),
    .system_rst_ni      ( rst_ni       ),
    .sne_interco_clk_i  ( clk_i        ),
    .sne_interco_rst_ni ( rst_ni       ),
    .sne_engine_clk_i   ( clk_i        ),
    .sne_engine_rst_ni  ( rst_ni       ),

    .interrupt_o        ( sne_interrupt ),

    .power_gate         ( 1'b0         ),
    .power_sleep        ( 1'b0         ),

    .evt_i              ( sne_evt_in   ),

    // TCDM not used — tie off
    .tcdm_gnt_i         ( 2'b00       ),
    .tcdm_r_data_i      ( '0          ),
    .tcdm_r_valid_i     ( 2'b00       ),
    .tcdm_req_o         (             ),
    .tcdm_add_o         (             ),
    .tcdm_wen_o         (             ),
    .tcdm_be_o          (             ),
    .tcdm_data_o        (             ),

    // APB from bridge
    .apb_slave_pwrite   ( apb_pwrite   ),
    .apb_slave_psel     ( apb_psel     ),
    .apb_slave_penable  ( apb_penable  ),
    .apb_slave_paddr    ( apb_paddr    ),
    .apb_slave_pwdata   ( apb_pwdata   ),
    .apb_slave_prdata   ( apb_prdata   ),
    .apb_slave_pready   ( apb_pready   ),
    .apb_slave_pslverr  ( apb_pslverr  )
  );

  assign evt_o  = {fifo_overflow_pulse, (sne_interrupt | evt_fifo_done_pulse)};
  assign busy_o = (apb_state_q != APB_IDLE) | (!fifo_empty) | evt_fifo_auto_run_q;

endmodule
