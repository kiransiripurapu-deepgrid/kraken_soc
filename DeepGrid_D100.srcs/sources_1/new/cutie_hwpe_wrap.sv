`timescale 1ns/1ps

module cutie_hwpe_wrap (
  input  logic           clk_i,
  input  logic           rst_ni,
  XBAR_PERIPH_BUS.Slave  cfg_bus,
  output logic [1:0]     evt_o,
  output logic           busy_o
);

  import cutie_params::*;

  // Replicate key CUTIE derived widths (must match `cutie_top` defaults)
  localparam int unsigned EFFECTIVETRITSPERWORD = N_I/WEIGHT_STAGGER;
  localparam int unsigned PHYSICALTRITSPERWORD  = ((EFFECTIVETRITSPERWORD + 4) / 5) * 5;
  localparam int unsigned PHYSICALBITSPERWORD   = PHYSICALTRITSPERWORD / 5 * 8;
  localparam int unsigned EXCESSBITS            = (PHYSICALTRITSPERWORD - EFFECTIVETRITSPERWORD) * 2;
  localparam int unsigned EFFECTIVEWORDWIDTH    = PHYSICALBITSPERWORD - EXCESSBITS;
  localparam int unsigned NUMBANKS              = K * WEIGHT_STAGGER;
  localparam int unsigned TOTNUMTRITS           = IMAGEWIDTH * IMAGEHEIGHT * N_I;
  localparam int unsigned TRITSPERBANK          = (TOTNUMTRITS + NUMBANKS - 1) / NUMBANKS;
  localparam int unsigned ACTMEMBANKDEPTH       = (TRITSPERBANK + EFFECTIVETRITSPERWORD - 1) / EFFECTIVETRITSPERWORD;
  localparam int unsigned ACTMEMFULLADDRESSBITWIDTH    = $clog2(NUMBANKS * ACTMEMBANKDEPTH);
  localparam int unsigned WEIGHTMEMFULLADDRESSBITWIDTH = $clog2(WEIGHTBANKDEPTH);
  localparam int unsigned BANKSETSBITWIDTH             = (NUMACTMEMBANKSETS > 1) ? $clog2(NUMACTMEMBANKSETS) : 1;
  localparam int unsigned THRESH_WORDS                 = (N_O + 31) / 32;

  // -------------------------
  // MMIO registers (minimal)
  // -------------------------
  logic        reg_start;
  logic        reg_running;
  logic        reg_compute_disable;
  logic        reg_testmode;
  logic        pulse_store_to_fifo;

  logic [31:0] reg_img_w;
  logic [31:0] reg_img_h;
  logic [31:0] reg_k;
  logic [31:0] reg_ni;
  logic [31:0] reg_no;
  logic [31:0] reg_stride_w;
  logic [31:0] reg_stride_h;
  logic        reg_padding;

  logic        reg_pool_en;
  logic        reg_pool_type;
  logic [31:0] reg_pool_k;
  logic        reg_pool_pad;

  logic        reg_skip_in;
  logic        reg_skip_out;
  logic        reg_is_tcn;
  logic        reg_linear_mode;
  logic [31:0] reg_tcn_width;
  logic [31:0] reg_tcn_width_mod_dil;
  logic [31:0] reg_tcn_k;
  logic [31:0] reg_linear_word_count;

  logic signed [31:0] reg_thresh_pos;
  logic signed [31:0] reg_thresh_neg;
  logic [0:N_O-1]     reg_thresh_save_en;

  // Activation memory external port control
  logic [31:0] reg_act_bankset;
  logic [31:0] reg_act_addr;
  logic [31:0] reg_act_wdata_lo;
  logic [31:0] reg_act_wdata_hi;
  logic        pulse_act_wr;
  logic        pulse_act_rd;

  // Weight memory external port control
  logic [31:0] reg_wgt_bank;
  logic [31:0] reg_wgt_addr;
  logic [31:0] reg_wgt_wdata_lo;
  logic [31:0] reg_wgt_wdata_hi;
  logic        pulse_wgt_wr;
  logic        pulse_wgt_rd;

  // Linear memory external write control
  logic [31:0] reg_linear_addr;
  logic [31:0] reg_linear_wdata;
  logic        pulse_linear_act_wr;
  logic        pulse_linear_wgt_wr;

  // Readback latches
  logic [PHYSICALBITSPERWORD-1:0] act_rdata_q;
  logic                           act_rvalid_q;
  logic [PHYSICALBITSPERWORD-1:0] wgt_rdata_q;
  logic                           wgt_rvalid_q;
  logic                           compute_done_q;
  logic                           compute_done_sticky_q;
  logic [31:0]                    result_signature_q;
  logic [31:0]                    linear_out0_q;
  logic [31:0]                    linear_out1_q;
  logic [31:0]                    linear_signature_q;
  logic [31:0]                    run_watchdog_q;
  logic                           timeout_evt_q;
  logic                           timeout_evt_sticky_q;
  logic                           linear_done_q;
  logic [1:0]                     desc_selected_bank_q;
  logic                           desc_auto_swap_q;
  logic [1:0]                     desc_valid_q;
  logic [31:0]                    desc_img_w_q [0:1];
  logic [31:0]                    desc_img_h_q [0:1];
  logic [31:0]                    desc_k_q [0:1];
  logic [31:0]                    desc_ni_q [0:1];
  logic [31:0]                    desc_no_q [0:1];
  logic [31:0]                    desc_stride_w_q [0:1];
  logic [31:0]                    desc_stride_h_q [0:1];
  logic                           desc_padding_q [0:1];
  logic                           desc_pool_en_q [0:1];
  logic                           desc_pool_type_q [0:1];
  logic [31:0]                    desc_pool_k_q [0:1];
  logic                           desc_pool_pad_q [0:1];
  logic                           desc_skip_in_q [0:1];
  logic                           desc_skip_out_q [0:1];
  logic                           desc_is_tcn_q [0:1];
  logic                           desc_linear_mode_q [0:1];
  logic [31:0]                    desc_tcn_width_q [0:1];
  logic [31:0]                    desc_tcn_width_mod_dil_q [0:1];
  logic [31:0]                    desc_tcn_k_q [0:1];
  logic [31:0]                    desc_linear_word_count_q [0:1];
  logic [31:0]                    desc_act_bankset_q [0:1];
  logic [1:0]                     burst_target_q;
  logic [31:0]                    burst_bank_q;
  logic [31:0]                    burst_addr_q;
  logic [31:0]                    burst_count_q;
  logic [31:0]                    burst_data_lo_q;
  logic [31:0]                    burst_data_hi_q;
  logic                           burst_busy_q;
  logic                           burst_done_q;
  logic                           burst_pulse_act_wr;
  logic                           burst_pulse_wgt_wr;
  logic                           burst_pulse_linear_act_wr;
  logic                           burst_pulse_linear_wgt_wr;
  logic [31:0]                    burst_remaining_q;
  logic                           desc_start_req_q;
  logic [31:0]                    fp_signature_d;
  logic [31:0]                    linear_wr_addr_sel;
  logic [31:0]                    linear_wr_data_sel;

  // The DroNet-oriented firmware path can legitimately run for much longer
  // than the earlier smoke-test transactions, so keep the timeout generous.
  localparam int unsigned CUTIE_RUN_TIMEOUT_CYCLES = 32'd250000;

  function automatic logic [PHYSICALBITSPERWORD-1:0] pack_cfg_word(
    input logic [31:0] lo_word,
    input logic [31:0] hi_word
  );
    logic [63:0] full_word;
    begin
      full_word = {hi_word, lo_word};
      pack_cfg_word = full_word[PHYSICALBITSPERWORD-1:0];
    end
  endfunction

  function automatic logic [31:0] readback_word(
    input logic [PHYSICALBITSPERWORD-1:0] data_word,
    input int unsigned                    chunk_idx
  );
    logic [63:0] padded_word;
    begin
      padded_word = '0;
      padded_word[PHYSICALBITSPERWORD-1:0] = data_word;
      readback_word = padded_word[chunk_idx*32 +: 32];
    end
  endfunction

  function automatic logic [31:0] fold_result_signature(
    input logic [0:PIPELINEDEPTH-1][0:(N_O/PIPELINEDEPTH)-1][$clog2(K*K*N_I):0] fp_words
  );
    logic [31:0] sig;
    begin
      sig = 32'h0;
      for (int p = 0; p < PIPELINEDEPTH; p++) begin
        for (int o = 0; o < (N_O/PIPELINEDEPTH); o++) begin
          sig ^= {{(32-($clog2(K*K*N_I)+1)){1'b0}}, fp_words[p][o]};
          sig = {sig[30:0], sig[31]} ^ (32'h9E37_79B9 + {27'd0, p[1:0], o[2:0]});
        end
      end
      fold_result_signature = sig;
    end
  endfunction

  function automatic logic signed [7:0] byte_at32(
    input logic [31:0] word_i,
    input int unsigned idx
  );
    begin
      byte_at32 = signed'(word_i[idx*8 +: 8]);
    end
  endfunction

  function automatic logic signed [31:0] dot8_words(
    input logic [31:0] act_word,
    input logic [31:0] weight_word
  );
    logic signed [31:0] acc;
    begin
      acc = '0;
      for (int i = 0; i < 4; i++) begin
        acc += byte_at32(act_word, i) * byte_at32(weight_word, i);
      end
      dot8_words = acc;
    end
  endfunction

  // one-cycle pulses
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      pulse_act_wr <= 1'b0;
      pulse_act_rd <= 1'b0;
      pulse_wgt_wr <= 1'b0;
      pulse_wgt_rd <= 1'b0;
      pulse_store_to_fifo <= 1'b0;
      pulse_linear_act_wr <= 1'b0;
      pulse_linear_wgt_wr <= 1'b0;
      reg_start    <= 1'b0;
    end else begin
      pulse_act_wr <= 1'b0;
      pulse_act_rd <= 1'b0;
      pulse_wgt_wr <= 1'b0;
      pulse_wgt_rd <= 1'b0;
      pulse_store_to_fifo <= 1'b0;
      pulse_linear_act_wr <= 1'b0;
      pulse_linear_wgt_wr <= 1'b0;
      reg_start    <= 1'b0;
      if (desc_start_req_q) begin
        reg_start <= 1'b1;
        pulse_store_to_fifo <= 1'b1;
      end
      if (cfg_bus.req && cfg_bus.gnt && !cfg_bus.wen) begin
        unique case (cfg_bus.add[11:2]) // word offsets
          10'h000: reg_start    <= cfg_bus.wdata[0]; // START (pulse)
          10'h003: pulse_store_to_fifo <= cfg_bus.wdata[0]; // STORE_TO_FIFO (pulse)
          10'h040: pulse_act_wr <= cfg_bus.wdata[0]; // ACT_WR (pulse)
          10'h045: pulse_act_rd <= cfg_bus.wdata[0]; // ACT_RD (pulse)
          10'h048: pulse_wgt_wr <= cfg_bus.wdata[0]; // WGT_WR (pulse)
          10'h04D: pulse_wgt_rd <= cfg_bus.wdata[0]; // WGT_RD (pulse)
          10'h060: pulse_linear_act_wr <= cfg_bus.wdata[0]; // LINEAR_ACT_WR (pulse)
          10'h061: pulse_linear_wgt_wr <= cfg_bus.wdata[0]; // LINEAR_WGT_WR (pulse)
          default: ;
        endcase
      end
    end
  end

  // register file
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      reg_running         <= 1'b0;
      reg_compute_disable <= 1'b1;
      reg_testmode        <= 1'b0;
      reg_img_w    <= IMAGEWIDTH;
      reg_img_h    <= IMAGEHEIGHT;
      reg_k        <= K;
      reg_ni       <= N_I;
      reg_no       <= N_O;
      reg_stride_w <= 1;
      reg_stride_h <= 1;
      reg_padding  <= 1'b0;

      reg_pool_en   <= 1'b0;
      reg_pool_type <= 1'b0;
      reg_pool_k    <= 2;
      reg_pool_pad  <= 1'b0;

      reg_skip_in  <= 1'b0;
      reg_skip_out <= 1'b0;
      reg_is_tcn   <= 1'b0;
      reg_linear_mode <= 1'b0;
      reg_tcn_width <= 1;
      reg_tcn_width_mod_dil <= 1;
      reg_tcn_k <= 1;
      reg_linear_word_count <= 32'd0;

      reg_thresh_pos     <= '0;
      reg_thresh_neg     <= '0;
      reg_thresh_save_en <= '0;

      reg_act_bankset <= '0;
      reg_act_addr    <= '0;
      reg_act_wdata_lo<= '0;
      reg_act_wdata_hi<= '0;

      reg_wgt_bank    <= '0;
      reg_wgt_addr    <= '0;
      reg_wgt_wdata_lo<= '0;
      reg_wgt_wdata_hi<= '0;
      reg_linear_addr <= '0;
      reg_linear_wdata<= '0;
      run_watchdog_q  <= '0;
      timeout_evt_q   <= 1'b0;
      timeout_evt_sticky_q <= 1'b0;
      compute_done_sticky_q <= 1'b0;
      result_signature_q <= 32'd0;
      desc_selected_bank_q <= 2'd0;
      desc_auto_swap_q <= 1'b0;
      desc_valid_q <= 2'b00;
      for (int i = 0; i < 2; i++) begin
        desc_img_w_q[i] <= IMAGEWIDTH;
        desc_img_h_q[i] <= IMAGEHEIGHT;
        desc_k_q[i] <= K;
        desc_ni_q[i] <= N_I;
        desc_no_q[i] <= N_O;
        desc_stride_w_q[i] <= 32'd1;
        desc_stride_h_q[i] <= 32'd1;
        desc_padding_q[i] <= 1'b0;
        desc_pool_en_q[i] <= 1'b0;
        desc_pool_type_q[i] <= 1'b0;
        desc_pool_k_q[i] <= 32'd2;
        desc_pool_pad_q[i] <= 1'b0;
        desc_skip_in_q[i] <= 1'b0;
        desc_skip_out_q[i] <= 1'b0;
        desc_is_tcn_q[i] <= 1'b0;
        desc_linear_mode_q[i] <= 1'b0;
        desc_tcn_width_q[i] <= 32'd1;
        desc_tcn_width_mod_dil_q[i] <= 32'd1;
        desc_tcn_k_q[i] <= 32'd1;
        desc_linear_word_count_q[i] <= 32'd0;
        desc_act_bankset_q[i] <= '0;
      end
      burst_target_q <= 2'd0;
      burst_bank_q <= 32'd0;
      burst_addr_q <= 32'd0;
      burst_count_q <= 32'd0;
      burst_data_lo_q <= 32'd0;
      burst_data_hi_q <= 32'd0;
      burst_busy_q <= 1'b0;
      burst_done_q <= 1'b0;
      burst_remaining_q <= 32'd0;
      desc_start_req_q <= 1'b0;
    end else begin
      timeout_evt_q <= 1'b0;
      burst_done_q <= 1'b0;
      desc_start_req_q <= 1'b0;

      if (reg_start) begin
        reg_running         <= 1'b1;
        reg_compute_disable <= reg_linear_mode ? 1'b1 : 1'b0;
        run_watchdog_q      <= '0;
        timeout_evt_sticky_q <= 1'b0;
        compute_done_sticky_q <= 1'b0;
        result_signature_q <= 32'd0;
      end
      if (compute_done_q || linear_done_q) begin
        reg_running <= 1'b0;
        run_watchdog_q <= '0;
        compute_done_sticky_q <= 1'b1;
      end
      if (reg_running && !compute_done_q && !linear_done_q) begin
        if (run_watchdog_q == CUTIE_RUN_TIMEOUT_CYCLES) begin
          reg_running   <= 1'b0;
          timeout_evt_q <= 1'b1;
          timeout_evt_sticky_q <= 1'b1;
          run_watchdog_q <= '0;
        end else begin
          run_watchdog_q <= run_watchdog_q + 32'd1;
        end
      end else begin
        run_watchdog_q <= '0;
      end

      if (cfg_bus.req && cfg_bus.gnt && !cfg_bus.wen) begin
        unique case (cfg_bus.add[11:2])
          10'h001: reg_compute_disable <= cfg_bus.wdata[0];
          10'h002: reg_testmode        <= cfg_bus.wdata[0];

          10'h010: reg_img_w    <= cfg_bus.wdata;
          10'h011: reg_img_h    <= cfg_bus.wdata;
          10'h012: reg_k        <= cfg_bus.wdata;
          10'h013: reg_ni       <= cfg_bus.wdata;
          10'h014: reg_no       <= cfg_bus.wdata;
          10'h015: reg_stride_w <= cfg_bus.wdata;
          10'h016: reg_stride_h <= cfg_bus.wdata;
          10'h017: reg_padding  <= cfg_bus.wdata[0];

          10'h020: reg_pool_en   <= cfg_bus.wdata[0];
          10'h021: reg_pool_type <= cfg_bus.wdata[0];
          10'h022: reg_pool_k    <= cfg_bus.wdata;
          10'h023: reg_pool_pad  <= cfg_bus.wdata[0];

          10'h024: reg_skip_in  <= cfg_bus.wdata[0];
          10'h025: reg_skip_out <= cfg_bus.wdata[0];
          10'h026: reg_is_tcn   <= cfg_bus.wdata[0];
          10'h027: reg_tcn_width <= cfg_bus.wdata;
          10'h028: reg_tcn_width_mod_dil <= cfg_bus.wdata;
          10'h029: reg_tcn_k <= cfg_bus.wdata;
          10'h02A: reg_linear_mode <= cfg_bus.wdata[0];
          10'h02B: reg_linear_word_count <= cfg_bus.wdata;

          10'h030: reg_thresh_pos <= cfg_bus.wdata;
          10'h031: reg_thresh_neg <= cfg_bus.wdata;
          10'h032: begin
            for (int i = 0; i < 32; i++) begin
              if (i < N_O) reg_thresh_save_en[i] <= cfg_bus.wdata[i];
            end
          end
          10'h033: begin
            for (int i = 0; i < 32; i++) begin
              if ((32 + i) < N_O) reg_thresh_save_en[32 + i] <= cfg_bus.wdata[i];
            end
          end
          10'h034: begin
            for (int i = 0; i < 32; i++) begin
              if ((64 + i) < N_O) reg_thresh_save_en[64 + i] <= cfg_bus.wdata[i];
            end
          end

          10'h041: reg_act_bankset  <= cfg_bus.wdata;
          10'h042: reg_act_addr     <= cfg_bus.wdata;
          10'h043: reg_act_wdata_lo <= cfg_bus.wdata;
          10'h044: reg_act_wdata_hi <= cfg_bus.wdata;

          10'h049: reg_wgt_bank     <= cfg_bus.wdata;
          10'h04A: reg_wgt_addr     <= cfg_bus.wdata;
          10'h04B: reg_wgt_wdata_lo <= cfg_bus.wdata;
          10'h04C: reg_wgt_wdata_hi <= cfg_bus.wdata;

          10'h062: reg_linear_addr  <= cfg_bus.wdata;
          10'h063: reg_linear_wdata <= cfg_bus.wdata;
          10'h070: burst_target_q   <= cfg_bus.wdata[1:0];
          10'h071: burst_bank_q     <= cfg_bus.wdata;
          10'h072: burst_addr_q     <= cfg_bus.wdata;
          10'h073: burst_count_q    <= cfg_bus.wdata;
          10'h074: burst_data_lo_q  <= cfg_bus.wdata;
          10'h075: burst_data_hi_q  <= cfg_bus.wdata;
          10'h080: desc_selected_bank_q <= cfg_bus.wdata[1:0];
          10'h081: desc_auto_swap_q <= cfg_bus.wdata[0];

          default: ;
        endcase
      end

      if (cfg_bus.req && cfg_bus.gnt && !cfg_bus.wen && cfg_bus.add[11:2] == 10'h082) begin
        if (cfg_bus.wdata[0]) begin
          desc_img_w_q[desc_selected_bank_q[0]] <= reg_img_w;
          desc_img_h_q[desc_selected_bank_q[0]] <= reg_img_h;
          desc_k_q[desc_selected_bank_q[0]] <= reg_k;
          desc_ni_q[desc_selected_bank_q[0]] <= reg_ni;
          desc_no_q[desc_selected_bank_q[0]] <= reg_no;
          desc_stride_w_q[desc_selected_bank_q[0]] <= reg_stride_w;
          desc_stride_h_q[desc_selected_bank_q[0]] <= reg_stride_h;
          desc_padding_q[desc_selected_bank_q[0]] <= reg_padding;
          desc_pool_en_q[desc_selected_bank_q[0]] <= reg_pool_en;
          desc_pool_type_q[desc_selected_bank_q[0]] <= reg_pool_type;
          desc_pool_k_q[desc_selected_bank_q[0]] <= reg_pool_k;
          desc_pool_pad_q[desc_selected_bank_q[0]] <= reg_pool_pad;
          desc_skip_in_q[desc_selected_bank_q[0]] <= reg_skip_in;
          desc_skip_out_q[desc_selected_bank_q[0]] <= reg_skip_out;
          desc_is_tcn_q[desc_selected_bank_q[0]] <= reg_is_tcn;
          desc_linear_mode_q[desc_selected_bank_q[0]] <= reg_linear_mode;
          desc_tcn_width_q[desc_selected_bank_q[0]] <= reg_tcn_width;
          desc_tcn_width_mod_dil_q[desc_selected_bank_q[0]] <= reg_tcn_width_mod_dil;
          desc_tcn_k_q[desc_selected_bank_q[0]] <= reg_tcn_k;
          desc_linear_word_count_q[desc_selected_bank_q[0]] <= reg_linear_word_count;
          desc_act_bankset_q[desc_selected_bank_q[0]] <= reg_act_bankset;
          desc_valid_q[desc_selected_bank_q[0]] <= 1'b1;
        end
        if (cfg_bus.wdata[1] && desc_valid_q[desc_selected_bank_q[0]]) begin
          reg_img_w <= desc_img_w_q[desc_selected_bank_q[0]];
          reg_img_h <= desc_img_h_q[desc_selected_bank_q[0]];
          reg_k <= desc_k_q[desc_selected_bank_q[0]];
          reg_ni <= desc_ni_q[desc_selected_bank_q[0]];
          reg_no <= desc_no_q[desc_selected_bank_q[0]];
          reg_stride_w <= desc_stride_w_q[desc_selected_bank_q[0]];
          reg_stride_h <= desc_stride_h_q[desc_selected_bank_q[0]];
          reg_padding <= desc_padding_q[desc_selected_bank_q[0]];
          reg_pool_en <= desc_pool_en_q[desc_selected_bank_q[0]];
          reg_pool_type <= desc_pool_type_q[desc_selected_bank_q[0]];
          reg_pool_k <= desc_pool_k_q[desc_selected_bank_q[0]];
          reg_pool_pad <= desc_pool_pad_q[desc_selected_bank_q[0]];
          reg_skip_in <= desc_skip_in_q[desc_selected_bank_q[0]];
          reg_skip_out <= desc_skip_out_q[desc_selected_bank_q[0]];
          reg_is_tcn <= desc_is_tcn_q[desc_selected_bank_q[0]];
          reg_linear_mode <= desc_linear_mode_q[desc_selected_bank_q[0]];
          reg_tcn_width <= desc_tcn_width_q[desc_selected_bank_q[0]];
          reg_tcn_width_mod_dil <= desc_tcn_width_mod_dil_q[desc_selected_bank_q[0]];
          reg_tcn_k <= desc_tcn_k_q[desc_selected_bank_q[0]];
          reg_linear_word_count <= desc_linear_word_count_q[desc_selected_bank_q[0]];
          reg_act_bankset <= desc_act_bankset_q[desc_selected_bank_q[0]];
        end
        if (cfg_bus.wdata[2] && desc_valid_q[desc_selected_bank_q[0]]) begin
          reg_img_w <= desc_img_w_q[desc_selected_bank_q[0]];
          reg_img_h <= desc_img_h_q[desc_selected_bank_q[0]];
          reg_k <= desc_k_q[desc_selected_bank_q[0]];
          reg_ni <= desc_ni_q[desc_selected_bank_q[0]];
          reg_no <= desc_no_q[desc_selected_bank_q[0]];
          reg_stride_w <= desc_stride_w_q[desc_selected_bank_q[0]];
          reg_stride_h <= desc_stride_h_q[desc_selected_bank_q[0]];
          reg_padding <= desc_padding_q[desc_selected_bank_q[0]];
          reg_pool_en <= desc_pool_en_q[desc_selected_bank_q[0]];
          reg_pool_type <= desc_pool_type_q[desc_selected_bank_q[0]];
          reg_pool_k <= desc_pool_k_q[desc_selected_bank_q[0]];
          reg_pool_pad <= desc_pool_pad_q[desc_selected_bank_q[0]];
          reg_skip_in <= desc_skip_in_q[desc_selected_bank_q[0]];
          reg_skip_out <= desc_skip_out_q[desc_selected_bank_q[0]];
          reg_is_tcn <= desc_is_tcn_q[desc_selected_bank_q[0]];
          reg_linear_mode <= desc_linear_mode_q[desc_selected_bank_q[0]];
          reg_tcn_width <= desc_tcn_width_q[desc_selected_bank_q[0]];
          reg_tcn_width_mod_dil <= desc_tcn_width_mod_dil_q[desc_selected_bank_q[0]];
          reg_tcn_k <= desc_tcn_k_q[desc_selected_bank_q[0]];
          reg_linear_word_count <= desc_linear_word_count_q[desc_selected_bank_q[0]];
          reg_act_bankset <= desc_act_bankset_q[desc_selected_bank_q[0]];
          desc_start_req_q <= 1'b1;
          if (desc_auto_swap_q)
            desc_selected_bank_q <= desc_selected_bank_q ^ 2'd1;
        end
        if (cfg_bus.wdata[3])
          desc_selected_bank_q <= desc_selected_bank_q ^ 2'd1;
      end

      if (cfg_bus.req && cfg_bus.gnt && !cfg_bus.wen && cfg_bus.add[11:2] == 10'h076 && cfg_bus.wdata[0]) begin
        burst_busy_q <= (burst_count_q != 32'd0);
        burst_remaining_q <= burst_count_q;
      end else if (burst_busy_q) begin
        if (burst_remaining_q <= 32'd1) begin
          burst_busy_q <= 1'b0;
          burst_done_q <= 1'b1;
          burst_remaining_q <= 32'd0;
        end else begin
          burst_remaining_q <= burst_remaining_q - 32'd1;
        end
        burst_addr_q <= burst_addr_q + 32'd1;
      end

      if (pulse_act_wr || pulse_act_rd)
        reg_act_addr <= reg_act_addr + 32'd1;
      if (pulse_wgt_wr || pulse_wgt_rd)
        reg_wgt_addr <= reg_wgt_addr + 32'd1;
      if (pulse_linear_act_wr || pulse_linear_wgt_wr)
        reg_linear_addr <= reg_linear_addr + 32'd1;

    end
  end

  // Single-point cfg_bus response driving avoids multi-driven interface fields.
  always_comb begin
    cfg_bus.gnt     = cfg_bus.req;
    cfg_bus.r_valid = cfg_bus.req & cfg_bus.wen;
    cfg_bus.r_opc   = 1'b0;
    cfg_bus.r_id    = cfg_bus.id;
    unique case (cfg_bus.add[11:2])
      10'h000: cfg_bus.r_rdata = {29'b0, timeout_evt_sticky_q, compute_done_sticky_q, reg_running};
      10'h001: cfg_bus.r_rdata = {31'b0, reg_compute_disable};
      10'h002: cfg_bus.r_rdata = {31'b0, reg_testmode};
      10'h003: cfg_bus.r_rdata = 32'h0;

      10'h010: cfg_bus.r_rdata = reg_img_w;
      10'h011: cfg_bus.r_rdata = reg_img_h;
      10'h012: cfg_bus.r_rdata = reg_k;
      10'h013: cfg_bus.r_rdata = reg_ni;
      10'h014: cfg_bus.r_rdata = reg_no;
      10'h015: cfg_bus.r_rdata = reg_stride_w;
      10'h016: cfg_bus.r_rdata = reg_stride_h;
      10'h017: cfg_bus.r_rdata = {31'b0, reg_padding};

      10'h020: cfg_bus.r_rdata = {31'b0, reg_pool_en};
      10'h021: cfg_bus.r_rdata = {31'b0, reg_pool_type};
      10'h022: cfg_bus.r_rdata = reg_pool_k;
      10'h023: cfg_bus.r_rdata = {31'b0, reg_pool_pad};
      10'h024: cfg_bus.r_rdata = {31'b0, reg_skip_in};
      10'h025: cfg_bus.r_rdata = {31'b0, reg_skip_out};
      10'h026: cfg_bus.r_rdata = {31'b0, reg_is_tcn};
      10'h027: cfg_bus.r_rdata = reg_tcn_width;
      10'h028: cfg_bus.r_rdata = reg_tcn_width_mod_dil;
      10'h029: cfg_bus.r_rdata = reg_tcn_k;
      10'h02A: cfg_bus.r_rdata = {31'b0, reg_linear_mode};
      10'h02B: cfg_bus.r_rdata = reg_linear_word_count;

      10'h030: cfg_bus.r_rdata = reg_thresh_pos;
      10'h031: cfg_bus.r_rdata = reg_thresh_neg;
      10'h032: cfg_bus.r_rdata = 32'h0;
      10'h033: cfg_bus.r_rdata = 32'h0;
      10'h034: cfg_bus.r_rdata = 32'h0;

      10'h041: cfg_bus.r_rdata = reg_act_bankset;
      10'h042: cfg_bus.r_rdata = reg_act_addr;
      10'h043: cfg_bus.r_rdata = reg_act_wdata_lo;
      10'h044: cfg_bus.r_rdata = reg_act_wdata_hi;
      10'h045: cfg_bus.r_rdata = 32'h0;

      10'h049: cfg_bus.r_rdata = reg_wgt_bank;
      10'h04A: cfg_bus.r_rdata = reg_wgt_addr;
      10'h04B: cfg_bus.r_rdata = reg_wgt_wdata_lo;
      10'h04C: cfg_bus.r_rdata = reg_wgt_wdata_hi;
      10'h04D: cfg_bus.r_rdata = 32'h0;

      10'h050: cfg_bus.r_rdata = {31'b0, compute_done_sticky_q};
      10'h051: cfg_bus.r_rdata = {31'b0, act_rvalid_q};
      10'h052: cfg_bus.r_rdata = readback_word(act_rdata_q, 0);
      10'h053: cfg_bus.r_rdata = readback_word(act_rdata_q, 1);
      10'h054: cfg_bus.r_rdata = {31'b0, wgt_rvalid_q};
      10'h055: cfg_bus.r_rdata = readback_word(wgt_rdata_q, 0);
      10'h056: cfg_bus.r_rdata = readback_word(wgt_rdata_q, 1);
      10'h057: cfg_bus.r_rdata = reg_linear_mode ? linear_signature_q : result_signature_q;
      10'h058: cfg_bus.r_rdata = linear_out0_q;
      10'h059: cfg_bus.r_rdata = linear_out1_q;
      10'h070: cfg_bus.r_rdata = {30'd0, burst_target_q};
      10'h071: cfg_bus.r_rdata = burst_bank_q;
      10'h072: cfg_bus.r_rdata = burst_addr_q;
      10'h073: cfg_bus.r_rdata = burst_count_q;
      10'h074: cfg_bus.r_rdata = burst_data_lo_q;
      10'h075: cfg_bus.r_rdata = burst_data_hi_q;
      10'h076: cfg_bus.r_rdata = {29'd0, burst_done_q, burst_busy_q, (burst_remaining_q != 32'd0)};
      10'h077: cfg_bus.r_rdata = burst_remaining_q;
      10'h080: cfg_bus.r_rdata = {30'd0, desc_selected_bank_q};
      10'h081: cfg_bus.r_rdata = {29'd0, desc_auto_swap_q, desc_valid_q};
      10'h082: cfg_bus.r_rdata = 32'h0;
      default: cfg_bus.r_rdata = 32'h0;
    endcase
  end

  // CUTIE external memory write pulses
  logic [BANKSETSBITWIDTH-1:0] actmem_bankset;
  logic [ACTMEMFULLADDRESSBITWIDTH-1:0] actmem_addr;
  logic [PHYSICALBITSPERWORD-1:0] actmem_wdata;

  logic [$clog2(N_O)-1:0] wgt_bank;
  logic [WEIGHTMEMFULLADDRESSBITWIDTH-1:0] wgt_addr;
  logic [PHYSICALBITSPERWORD-1:0] wgt_wdata;

  assign burst_pulse_act_wr        = burst_busy_q && (burst_target_q == 2'd0);
  assign burst_pulse_wgt_wr        = burst_busy_q && (burst_target_q == 2'd1);
  assign burst_pulse_linear_act_wr = burst_busy_q && (burst_target_q == 2'd2);
  assign burst_pulse_linear_wgt_wr = burst_busy_q && (burst_target_q == 2'd3);

  assign actmem_bankset = burst_pulse_act_wr ? burst_bank_q[BANKSETSBITWIDTH-1:0]
                                             : reg_act_bankset[BANKSETSBITWIDTH-1:0];
  assign actmem_addr    = burst_pulse_act_wr ? burst_addr_q[ACTMEMFULLADDRESSBITWIDTH-1:0]
                                             : reg_act_addr[ACTMEMFULLADDRESSBITWIDTH-1:0];
  assign actmem_wdata   = burst_pulse_act_wr ? pack_cfg_word(burst_data_lo_q, burst_data_hi_q)
                                             : pack_cfg_word(reg_act_wdata_lo, reg_act_wdata_hi);

  assign wgt_bank  = burst_pulse_wgt_wr ? burst_bank_q[$clog2(N_O)-1:0] : reg_wgt_bank[$clog2(N_O)-1:0];
  assign wgt_addr  = burst_pulse_wgt_wr ? burst_addr_q[WEIGHTMEMFULLADDRESSBITWIDTH-1:0]
                                        : reg_wgt_addr[WEIGHTMEMFULLADDRESSBITWIDTH-1:0];
  assign wgt_wdata = burst_pulse_wgt_wr ? pack_cfg_word(burst_data_lo_q, burst_data_hi_q)
                                        : pack_cfg_word(reg_wgt_wdata_lo, reg_wgt_wdata_hi);

  // CUTIE instance
  logic [PHYSICALBITSPERWORD-1:0] actmem_external_acts_o;
  logic                          actmem_external_valid_o;
  logic [PHYSICALBITSPERWORD-1:0] weightmem_external_weights_o;
  logic                          weightmem_external_valid_o;
  logic                          compute_done_o;
  logic                          compute_done_muxed;

  localparam int unsigned LINEAR_ACT_MEM_DEPTH = 1024;
  localparam int unsigned LINEAR_WGT_MEM_DEPTH = 2048;

  typedef enum logic {
    LINEAR_IDLE,
    LINEAR_RUN
  } linear_state_e;

  linear_state_e linear_state_q;
  logic [31:0] linear_word_idx_q;
  logic signed [31:0] linear_acc0_q;
  logic signed [31:0] linear_acc1_q;
  logic [31:0] linear_act_word_d;
  logic [31:0] linear_wgt0_word_d;
  logic [31:0] linear_wgt_word_d;
  logic signed [31:0] linear_dot0_d;
  logic signed [31:0] linear_dot1_d;
  logic signed [31:0] linear_out0_d;
  logic signed [31:0] linear_out1_d;
  logic [31:0] linear_signature_d;
  logic [31:0] linear_act_mem [0:LINEAR_ACT_MEM_DEPTH-1];
  logic [31:0] linear_wgt_mem [0:LINEAR_WGT_MEM_DEPTH-1];

  assign linear_wr_addr_sel = (burst_pulse_linear_act_wr || burst_pulse_linear_wgt_wr) ? burst_addr_q : reg_linear_addr;
  assign linear_wr_data_sel = (burst_pulse_linear_act_wr || burst_pulse_linear_wgt_wr) ? burst_data_lo_q : reg_linear_wdata;

  // Linear memory write path (MMIO-driven)
  always_ff @(posedge clk_i) begin
    if (pulse_linear_act_wr || burst_pulse_linear_act_wr)
      linear_act_mem[linear_wr_addr_sel[$clog2(LINEAR_ACT_MEM_DEPTH)-1:0]] <= linear_wr_data_sel;
    if (pulse_linear_wgt_wr || burst_pulse_linear_wgt_wr)
      linear_wgt_mem[linear_wr_addr_sel[$clog2(LINEAR_WGT_MEM_DEPTH)-1:0]] <= linear_wr_data_sel;
  end

  logic [0:PIPELINEDEPTH-1][0:(N_O/PIPELINEDEPTH)-1][$clog2(K*K*N_I):0] fp_output_unused;

  assign fp_signature_d = fold_result_signature(fp_output_unused);
  assign linear_act_word_d = linear_act_mem[linear_word_idx_q];
  assign linear_wgt0_word_d = linear_wgt_mem[linear_word_idx_q];
  assign linear_wgt_word_d = linear_wgt_mem[linear_word_idx_q + reg_linear_word_count];
  assign linear_dot0_d = dot8_words(linear_act_word_d, linear_wgt0_word_d);
  assign linear_dot1_d = dot8_words(linear_act_word_d, linear_wgt_word_d);
  assign linear_out0_d = linear_acc0_q + linear_dot0_d;
  assign linear_out1_d = linear_acc1_q + linear_dot1_d;
  assign linear_signature_d = linear_out0_d[31:0] ^
                              ((linear_out1_d[31:0] << 1) & 32'hFFFF_FFFF) ^
                              (linear_out1_d[31:0] >> 31);

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      linear_state_q <= LINEAR_IDLE;
      linear_word_idx_q <= 32'd0;
      linear_acc0_q <= '0;
      linear_acc1_q <= '0;
      linear_out0_q <= 32'd0;
      linear_out1_q <= 32'd0;
      linear_signature_q <= 32'd0;
      linear_done_q <= 1'b0;
    end else begin
      linear_done_q <= 1'b0;
      if (reg_start && reg_linear_mode) begin
        linear_state_q <= LINEAR_RUN;
        linear_word_idx_q <= 32'd0;
        linear_acc0_q <= '0;
        linear_acc1_q <= '0;
        linear_out0_q <= 32'd0;
        linear_out1_q <= 32'd0;
        linear_signature_q <= 32'd0;
      end else begin
        case (linear_state_q)
          LINEAR_IDLE: begin
            if (!reg_running) begin
              linear_word_idx_q <= 32'd0;
            end
          end
          LINEAR_RUN: begin
            linear_acc0_q <= linear_out0_d;
            linear_acc1_q <= linear_out1_d;
            if (linear_word_idx_q + 32'd1 >= reg_linear_word_count) begin
              linear_out0_q <= linear_out0_d[31:0];
              linear_out1_q <= linear_out1_d[31:0];
              linear_signature_q <= linear_signature_d;
              linear_done_q <= 1'b1;
              linear_state_q <= LINEAR_IDLE;
            end else begin
              linear_word_idx_q <= linear_word_idx_q + 32'd1;
              linear_state_q <= LINEAR_RUN;
            end
          end
          default: linear_state_q <= LINEAR_IDLE;
        endcase
      end
    end
  end

  cutie_top cutie_i (
    .clk_i ( clk_i ),
    .rst_ni( rst_ni ),

    .actmem_external_bank_set_i ( actmem_bankset ),
    .actmem_external_we_i       ( pulse_act_wr | burst_pulse_act_wr ),
    .actmem_external_req_i      ( pulse_act_wr | pulse_act_rd | burst_pulse_act_wr ),
    .actmem_external_addr_i     ( actmem_addr ),
    .actmem_external_wdata_i    ( actmem_wdata   ),

    .weightmem_external_bank_i  ( wgt_bank ),
    .weightmem_external_we_i    ( pulse_wgt_wr | burst_pulse_wgt_wr ),
    .weightmem_external_req_i   ( pulse_wgt_wr | pulse_wgt_rd | burst_pulse_wgt_wr ),
    .weightmem_external_addr_i  ( wgt_addr ),
    .weightmem_external_wdata_i ( wgt_wdata      ),

    .ocu_thresh_pos_i           ( reg_thresh_pos[$clog2(K*K*N_I):0] ),
    .ocu_thresh_neg_i           ( reg_thresh_neg[$clog2(K*K*N_I):0] ),
    .ocu_thresholds_save_enable_i ( reg_thresh_save_en[0:N_O-1] ),

    .LUCA_store_to_fifo_i       ( pulse_store_to_fifo ),
    .LUCA_testmode_i            ( reg_testmode      ),
    .LUCA_layer_imagewidth_i    ( reg_img_w[$clog2(IMAGEWIDTH):0] ),
    .LUCA_layer_imageheight_i   ( reg_img_h[$clog2(IMAGEHEIGHT):0] ),
    .LUCA_layer_k_i             ( reg_k[$clog2(K):0] ),
    .LUCA_layer_ni_i            ( reg_ni[$clog2(N_I):0] ),
    .LUCA_layer_no_i            ( reg_no[$clog2(N_O):0] ),
    .LUCA_layer_stride_width_i  ( reg_stride_w[$clog2(K)-1:0] ),
    .LUCA_layer_stride_height_i ( reg_stride_h[$clog2(K)-1:0] ),
    .LUCA_layer_padding_type_i  ( reg_padding ),
    .LUCA_pooling_enable_i      ( reg_pool_en ),
    .LUCA_pooling_pooling_type_i( reg_pool_type ),
    .LUCA_pooling_kernel_i      ( reg_pool_k[$clog2(K)-1:0] ),
    .LUCA_pooling_padding_type_i( reg_pool_pad ),
    .LUCA_layer_skip_in_i       ( reg_skip_in ),
    .LUCA_layer_skip_out_i      ( reg_skip_out ),
    .LUCA_layer_is_tcn_i        ( reg_is_tcn ),
    .LUCA_layer_tcn_width_i     ( reg_tcn_width[$clog2(TCN_WIDTH)-1:0] ),
    .LUCA_layer_tcn_width_mod_dil_i ( reg_tcn_width_mod_dil[$clog2(TCN_WIDTH)-1:0] ),
    .LUCA_layer_tcn_k_i         ( reg_tcn_k[$clog2(K)-1:0] ),

    .LUCA_compute_disable_i     ( reg_compute_disable ),

    .actmem_external_acts_o     ( actmem_external_acts_o ),
    .actmem_external_valid_o    ( actmem_external_valid_o ),
    .weightmem_external_weights_o ( weightmem_external_weights_o ),
    .weightmem_external_valid_o  ( weightmem_external_valid_o ),
    .fp_output_o                 ( fp_output_unused ),
    .compute_done_o              ( compute_done_o )
  );

  assign compute_done_muxed = reg_linear_mode ? linear_done_q : compute_done_o;

  // latch readbacks
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      act_rdata_q    <= '0;
      act_rvalid_q   <= 1'b0;
      wgt_rdata_q    <= '0;
      wgt_rvalid_q   <= 1'b0;
      compute_done_q <= 1'b0;
    end else begin
      act_rvalid_q   <= actmem_external_valid_o;
      wgt_rvalid_q   <= weightmem_external_valid_o;
      if (actmem_external_valid_o) act_rdata_q <= actmem_external_acts_o;
      if (weightmem_external_valid_o) wgt_rdata_q <= weightmem_external_weights_o;
      compute_done_q <= compute_done_muxed;
      if (compute_done_o && !reg_linear_mode)
        result_signature_q <= fp_signature_d;
    end
  end

  assign evt_o  = {timeout_evt_q, compute_done_q};
  assign busy_o = (reg_running & ~compute_done_q) | burst_busy_q;

endmodule
