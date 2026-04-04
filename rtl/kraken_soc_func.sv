`timescale 1ns/1ps

// Functional Kraken-style SoC for Arty A7-100T.
// Keeps the original 1-core cluster + local SRAM structure from kraken_soc,
// and adds a firmware-controlled CUTIE config window rather than a hidden
// synthetic accelerator sequencer.

module kraken_soc_func import axi_pkg::*; #(
  parameter int unsigned AXI_ADDR_WIDTH = 32,
  parameter int unsigned AXI_DATA_WIDTH = 64,
  parameter int unsigned AXI_ID_WIDTH   = 4,
  parameter bit          STRICT_SINGLE_OUTSTANDING = 1'b0
) (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        test_en_i,
  output logic [31:0] core_0_addr_o,
  output logic [31:0] core_0_data_o,
  output logic        core_0_req_o,
  output logic        mem_valid_o,
  output logic [31:0] mem_data_o,
  output logic        cutie_busy_o,
  output logic [1:0]  cutie_evt_o
);

  logic rst_sync_ff_q;
  logic rst_n_q;

  logic [0:0]       core_instr_req;
  logic [0:0]       core_instr_gnt;
  logic [0:0][31:0] core_instr_addr;
  logic [0:0]       core_instr_rvalid;
  logic [0:0][31:0] core_instr_rdata;
  logic             instr_req_fire;
  logic             instr_rsp_pop;
  logic             instr_rsp_can_accept;
  logic [1:0]       instr_rsp_count_q;
  logic [31:0]      instr_rsp_q0;
  logic [31:0]      instr_rsp_q1;
  logic             instr_rsp_pending_q;
  logic [31:0]      instr_rsp_data_q;
  logic             instr_rvalid_q;
  logic [31:0]      instr_rdata_q;
  logic [0:0]       core_data_req;
  logic [0:0]       core_data_gnt;
  logic [0:0]       core_data_we;
  logic [0:0][3:0]  core_data_be;
  logic [0:0][31:0] core_data_addr;
  logic [0:0][31:0] core_data_wdata;
  logic [0:0]       core_data_rvalid;
  logic [0:0][31:0] core_data_rdata;

  logic [15:0] mem_addr;
  logic [31:0] mem_rdata;
  logic        instr_is_l2;
  logic [31:0] instr_resp_new;
  logic [15:0] data_mem_addr;
  logic [31:0] data_mem_rdata;
  logic        dma_mem_req;
  logic [15:0] dma_mem_addr;
  logic [31:0] dma_mem_rdata;
  logic        data_is_local;
  logic        data_is_mmio;
  logic        data_is_cutie_cfg;
  logic        data_is_sne_cfg;
  logic [5:0]  mmio_word_addr;
  logic        data_req_fire;
  logic [31:0] data_resp_new;
  logic        data_rsp_push_fire;
  logic [31:0] data_rsp_push_data;
  logic        data_rsp_pop;
  logic        data_rsp_can_accept;
  logic        sne_cfg_rvalid;
  logic [1:0]  data_rsp_count_q;
  logic [31:0] data_rsp_q0;
  logic [31:0] data_rsp_q1;
  logic        data_rsp_pending_q;
  logic [31:0] data_rsp_data_q;
  logic        data_rvalid_q;
  logic [31:0] data_rdata_q;
  logic [31:0] mmio_rdata;
  logic [31:0] mmio_scratch0_q;
  logic [31:0] mmio_scratch1_q;
  logic [31:0] mmio_gpio_q;
  logic [31:0] uart_tx_reg_q;
  logic [31:0] uart_status_q;
  logic [31:0] bad_access_q;
  logic [31:0] cutie_status_q;
  logic [31:0] cutie_readback_q;
  logic [31:0] cutie_status_live;
  logic [31:0] accel_irq_status_q;
  logic [31:0] accel_irq_mask_q;
  logic [31:0] accel_busy_live;
  logic        cutie_done_seen_q;
  logic        cutie_timeout_seen_q;
  logic        sne_done_seen_q;
  logic        sne_error_seen_q;
  logic [31:0] cycle_counter_q;
  logic [31:0] cutie_done_count_q;
  logic [31:0] cutie_timeout_count_q;
  logic [31:0] sne_done_count_q;
  logic [31:0] sne_error_count_q;
  logic        cutie_cfg_req_cpu;
  logic        cutie_cfg_wen_cpu;
  logic [31:0] cutie_cfg_addr_cpu;
  logic [31:0] cutie_cfg_wdata_cpu;
  logic [31:0] cutie_cfg_addr_q;
  logic        cutie_cfg_req_dma;
  logic        cutie_cfg_wen_dma;
  logic [31:0] cutie_cfg_addr_dma;
  logic [31:0] cutie_cfg_wdata_dma;
  logic        cutie_cfg_req_mux;
  logic        cutie_cfg_wen_mux;
  logic [31:0] cutie_cfg_addr_mux;
  logic [31:0] cutie_cfg_wdata_mux;
  logic        cutie_cfg_cpu_blocked;
  typedef enum logic [3:0] {
    DMA_IDLE,
    DMA_DESC_REQ,
    DMA_DESC_CAP,
    DMA_PREP_RD0,
    DMA_CAP_RD0,
    DMA_PREP_RD1,
    DMA_CAP_RD1,
    DMA_CFG_BANK,
    DMA_CFG_ADDR,
    DMA_CFG_LO,
    DMA_CFG_HI,
    DMA_CFG_WR,
    DMA_DONE,
    DMA_ERROR
  } cutie_dma_state_e;
  cutie_dma_state_e dma_state_q;
  logic [31:0] dma_desc_ptr_q;
  logic [31:0] dma_next_desc_q;
  logic [31:0] dma_src_addr_q;
  logic [31:0] dma_dst_addr_q;
  logic [31:0] dma_bank_q;
  logic [31:0] dma_word_count_q;
  logic [31:0] dma_control_q;
  logic [31:0] dma_remaining_q;
  logic [31:0] dma_curr_src_q;
  logic [31:0] dma_curr_dst_q;
  logic [31:0] dma_read_lo_q;
  logic [31:0] dma_read_hi_q;
  logic [31:0] dma_status_q;
  logic [31:0] dma_done_count_q;
  logic [31:0] dma_error_count_q;
  logic [2:0]  dma_fetch_index_q;
  logic [1:0]  dma_target_q;
  logic        dma_busy_q;
  logic        dma_done_q;
  logic        dma_error_q;
  logic        dma_irq_en_q;
  logic        dma_chain_en_q;
  logic [31:0] dma_words_this_iter;
  localparam logic [31:0] MMIO_BASE_ADDR      = 32'h1A10_0000;
  localparam logic [31:0] CUTIE_CFG_BASE_ADDR = 32'h1A11_0000;
  localparam logic [31:0] SNE_CFG_BASE_ADDR   = 32'h1A12_0000;
  localparam logic [31:0] LOCAL_MEM_LAST_ADDR = 32'h0003_FFFF;
  localparam logic [31:0] BAD_ACCESS_RDATA = 32'hDEAD_BEEF;
  localparam logic [5:0] MMIO_SCRATCH0_OFFSET    = 6'h00;
  localparam logic [5:0] MMIO_SCRATCH1_OFFSET    = 6'h01;
  localparam logic [5:0] MMIO_GPIO_OFFSET        = 6'h02;
  localparam logic [5:0] MMIO_UART_TX_OFFSET     = 6'h03;
  localparam logic [5:0] MMIO_UART_STATUS_OFFSET = 6'h04;
  localparam logic [5:0] MMIO_BAD_ACCESS_OFFSET  = 6'h05;
  localparam logic [5:0] MMIO_CYCLE_COUNT_OFFSET = 6'h06;
  localparam logic [5:0] MMIO_CUTIE_DONE_COUNT_OFFSET = 6'h07;
  localparam logic [5:0] MMIO_CUTIE_TIMEOUT_COUNT_OFFSET = 6'h08;
  localparam logic [5:0] MMIO_CUTIE_STATUS_OFFSET = 6'h0C;
  localparam logic [5:0] MMIO_CUTIE_READBACK_OFFSET = 6'h0D;
  localparam logic [5:0] MMIO_ACCEL_IRQ_STATUS_OFFSET = 6'h0E;
  localparam logic [5:0] MMIO_ACCEL_IRQ_MASK_OFFSET = 6'h0F;
  localparam logic [5:0] MMIO_ACCEL_BUSY_OFFSET = 6'h10;
  localparam logic [5:0] MMIO_SNE_DONE_COUNT_OFFSET = 6'h11;
  localparam logic [5:0] MMIO_SNE_ERROR_COUNT_OFFSET = 6'h12;
  localparam logic [5:0] MMIO_DMA_DESC_PTR_OFFSET = 6'h13;
  localparam logic [5:0] MMIO_DMA_STATUS_OFFSET = 6'h14;
  localparam logic [5:0] MMIO_DMA_REMAINING_OFFSET = 6'h15;
  localparam logic [5:0] MMIO_DMA_CUR_SRC_OFFSET = 6'h16;
  localparam logic [5:0] MMIO_DMA_CUR_DST_OFFSET = 6'h17;
  localparam logic [5:0] MMIO_DMA_DONE_COUNT_OFFSET = 6'h18;
  localparam logic [5:0] MMIO_DMA_ERROR_COUNT_OFFSET = 6'h19;
  localparam logic [31:0] CUTIE_ACT_WR_ADDR = 32'h0000_0100;
  localparam logic [31:0] CUTIE_ACT_BANK_ADDR = 32'h0000_0104;
  localparam logic [31:0] CUTIE_ACT_DST_ADDR = 32'h0000_0108;
  localparam logic [31:0] CUTIE_ACT_LO_ADDR = 32'h0000_010C;
  localparam logic [31:0] CUTIE_ACT_HI_ADDR = 32'h0000_0110;
  localparam logic [31:0] CUTIE_WGT_WR_ADDR = 32'h0000_0120;
  localparam logic [31:0] CUTIE_WGT_BANK_ADDR = 32'h0000_0124;
  localparam logic [31:0] CUTIE_WGT_DST_ADDR = 32'h0000_0128;
  localparam logic [31:0] CUTIE_WGT_LO_ADDR = 32'h0000_012C;
  localparam logic [31:0] CUTIE_WGT_HI_ADDR = 32'h0000_0130;
  localparam logic [31:0] CUTIE_LINEAR_ACT_WR_ADDR = 32'h0000_0180;
  localparam logic [31:0] CUTIE_LINEAR_WGT_WR_ADDR = 32'h0000_0184;
  localparam logic [31:0] CUTIE_LINEAR_DST_ADDR = 32'h0000_0188;
  localparam logic [31:0] CUTIE_LINEAR_DATA_ADDR = 32'h0000_018C;

  // Keep a short local reset release delay so the simplified always-ready
  // instruction/data responses do not hit the core on the very first cycle
  // out of reset. This was part of the last known-good functional behavior.
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rst_sync_ff_q <= 1'b0;
      rst_n_q       <= 1'b0;
    end else begin
      rst_sync_ff_q <= 1'b1;
      rst_n_q       <= rst_sync_ff_q;
    end
  end

  pulp_cluster #(
    .NR_CORES        ( 1              ),
    .AXI_ADDR_WIDTH  ( AXI_ADDR_WIDTH ),
    .AXI_DATA_WIDTH  ( AXI_DATA_WIDTH ),
    .AXI_ID_WIDTH    ( AXI_ID_WIDTH   ),
    .TCDM_ADDR_WIDTH ( 13             ),
    .TCDM_DATA_WIDTH ( 64             )
  ) i_pulp_cluster (
    .clk_i               ( clk_i             ),
    .rst_ni              ( rst_n_q           ),
    .test_en_i           ( test_en_i         ),
    .core_instr_req_o    ( core_instr_req    ),
    .core_instr_gnt_i    ( core_instr_gnt    ),
    .core_instr_addr_o   ( core_instr_addr   ),
    .core_instr_rvalid_i ( core_instr_rvalid ),
    .core_instr_rdata_i  ( core_instr_rdata  ),
    .core_data_req_o     ( core_data_req     ),
    .core_data_gnt_i     ( core_data_gnt     ),
    .core_data_we_o      ( core_data_we      ),
    .core_data_be_o      ( core_data_be      ),
    .core_data_addr_o    ( core_data_addr    ),
    .core_data_wdata_o   ( core_data_wdata   ),
    .core_data_rvalid_i  ( core_data_rvalid  ),
    .core_data_rdata_i   ( core_data_rdata   )
  );

  assign mem_addr             = core_instr_addr[0][17:2];
  assign instr_is_l2          = (core_instr_addr[0] <= LOCAL_MEM_LAST_ADDR);
  assign data_mem_addr        = core_data_addr[0][17:2];
  assign data_is_local        = ~data_is_mmio & ~data_is_cutie_cfg & (core_data_addr[0] <= LOCAL_MEM_LAST_ADDR);
  assign instr_rsp_pop        = rst_n_q & (instr_rsp_count_q != 2'd0) & ~STRICT_SINGLE_OUTSTANDING;
  assign instr_rsp_can_accept = (instr_rsp_count_q != 2'd2) || instr_rsp_pop;
  assign core_instr_gnt[0]    = core_instr_req[0] &
                                (STRICT_SINGLE_OUTSTANDING ? ~instr_rsp_pending_q : instr_rsp_can_accept);
  assign instr_req_fire       = core_instr_req[0] & core_instr_gnt[0];
  assign core_instr_rvalid[0] = STRICT_SINGLE_OUTSTANDING ? instr_rsp_pending_q : instr_rvalid_q;
  assign core_instr_rdata[0]  = STRICT_SINGLE_OUTSTANDING ? instr_rsp_data_q : instr_rdata_q;
  assign data_is_mmio         = (core_data_addr[0][31:12] == MMIO_BASE_ADDR[31:12]);
  assign data_is_cutie_cfg    = (core_data_addr[0][31:12] == CUTIE_CFG_BASE_ADDR[31:12]);
  assign data_is_sne_cfg      = (core_data_addr[0][31:12] == SNE_CFG_BASE_ADDR[31:12]);
  assign mmio_word_addr       = core_data_addr[0][7:2];
  assign data_rsp_pop         = rst_n_q & (data_rsp_count_q != 2'd0) & ~STRICT_SINGLE_OUTSTANDING;
  assign data_rsp_can_accept  = (data_rsp_count_q != 2'd2) || data_rsp_pop;
  assign cutie_cfg_cpu_blocked = dma_busy_q;
  assign core_data_gnt[0]     = core_data_req[0] &
                                (data_is_sne_cfg ? sne_cfg_bus.gnt :
                                 (data_is_cutie_cfg ? (~cutie_cfg_cpu_blocked & cutie_cfg_bus.gnt) :
                                  (STRICT_SINGLE_OUTSTANDING ? ~data_rsp_pending_q : data_rsp_can_accept)));
  assign data_req_fire        = core_data_req[0] & core_data_gnt[0];
  assign core_data_rvalid[0]  = STRICT_SINGLE_OUTSTANDING ? data_rsp_pending_q : data_rvalid_q;
  assign core_data_rdata[0]   = STRICT_SINGLE_OUTSTANDING ? data_rsp_data_q : data_rdata_q;

  kraken_soc_func_unified_mem #(
    .DATA_WIDTH ( 32    ),
    .NUM_WORDS  ( 65536 )
  ) i_l2_mem (
    .clk_i        ( clk_i                        ),
    .instr_req_i  ( instr_req_fire & instr_is_l2 ),
    .instr_addr_i ( mem_addr                     ),
    .instr_rdata_o( mem_rdata                    ),
    .data_req_i   ( data_req_fire & data_is_local ),
    .data_we_i    ( core_data_we[0]              ),
    .data_addr_i  ( data_mem_addr                ),
    .data_wdata_i ( core_data_wdata[0]           ),
    .data_be_i    ( core_data_be[0]               ),
    .data_rdata_o ( data_mem_rdata               ),
    .dma_req_i    ( dma_mem_req                  ),
    .dma_addr_i   ( dma_mem_addr                 ),
    .dma_rdata_o  ( dma_mem_rdata                )
  );

  assign instr_resp_new = instr_is_l2 ? mem_rdata : BAD_ACCESS_RDATA;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      instr_rsp_count_q <= 2'd0;
      instr_rsp_q0      <= 32'd0;
      instr_rsp_q1      <= 32'd0;
      instr_rsp_pending_q <= 1'b0;
      instr_rsp_data_q    <= 32'd0;
      instr_rvalid_q    <= 1'b0;
      instr_rdata_q     <= 32'd0;
    end else begin
      if (STRICT_SINGLE_OUTSTANDING) begin
        instr_rsp_pending_q <= instr_req_fire;
        if (instr_req_fire)
          instr_rsp_data_q <= instr_resp_new;

        instr_rsp_count_q <= 2'd0;
        instr_rsp_q0      <= 32'd0;
        instr_rsp_q1      <= 32'd0;
        instr_rvalid_q    <= 1'b0;
        instr_rdata_q     <= 32'd0;
      end else begin
        instr_rsp_pending_q <= 1'b0;
        instr_rvalid_q <= instr_rsp_pop;
        if (instr_rsp_pop) begin
          instr_rdata_q <= instr_rsp_q0;
        end

        unique case ({instr_req_fire, instr_rsp_pop})
          2'b00: begin
            // no push/pop
          end
          2'b01: begin
            // pop only
            if (instr_rsp_count_q == 2'd2)
              instr_rsp_q0 <= instr_rsp_q1;
            instr_rsp_count_q <= instr_rsp_count_q - 2'd1;
          end
          2'b10: begin
            // push only
            if (instr_rsp_count_q == 2'd0)
              instr_rsp_q0 <= instr_resp_new;
            else if (instr_rsp_count_q == 2'd1)
              instr_rsp_q1 <= instr_resp_new;
            instr_rsp_count_q <= (instr_rsp_count_q == 2'd2) ? 2'd2 : (instr_rsp_count_q + 2'd1);
          end
          2'b11: begin
            // push and pop in same cycle (count stays constant)
            if (instr_rsp_count_q == 2'd1) begin
              instr_rsp_q0 <= instr_resp_new;
            end else if (instr_rsp_count_q == 2'd2) begin
              instr_rsp_q0 <= instr_rsp_q1;
              instr_rsp_q1 <= instr_resp_new;
            end
          end
        endcase
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      mmio_scratch0_q <= 32'd0;
      mmio_scratch1_q <= 32'd0;
      mmio_gpio_q     <= 32'd0;
      uart_tx_reg_q   <= 32'd0;
      uart_status_q   <= 32'h0000_0001;
      bad_access_q    <= 32'd0;
      cycle_counter_q <= 32'd0;
      cutie_done_count_q <= 32'd0;
      cutie_timeout_count_q <= 32'd0;
      sne_done_count_q <= 32'd0;
      sne_error_count_q <= 32'd0;
      cutie_done_seen_q <= 1'b0;
      cutie_timeout_seen_q <= 1'b0;
      sne_done_seen_q <= 1'b0;
      sne_error_seen_q <= 1'b0;
      accel_irq_status_q <= 32'd0;
      accel_irq_mask_q <= 32'h0000_000F;
      dma_status_q <= 32'd0;
`ifndef SYNTHESIS
    end else if (data_req_fire && core_data_we[0] && (data_is_mmio === 1'b1) &&
                 !$isunknown(core_data_addr[0][7:2]) && !$isunknown(core_data_wdata[0])) begin
`else
    end else if (data_req_fire && core_data_we[0] && data_is_mmio) begin
`endif
      cycle_counter_q <= cycle_counter_q + 32'd1;
      if (cutie_evt_o[0]) begin
        cutie_done_count_q <= cutie_done_count_q + 32'd1;
        cutie_done_seen_q <= 1'b1;
        accel_irq_status_q[0] <= 1'b1;
      end
      if (cutie_evt_o[1]) begin
        cutie_timeout_count_q <= cutie_timeout_count_q + 32'd1;
        cutie_timeout_seen_q <= 1'b1;
        accel_irq_status_q[1] <= 1'b1;
      end
      if (sne_evt[0]) begin
        sne_done_count_q <= sne_done_count_q + 32'd1;
        sne_done_seen_q <= 1'b1;
        accel_irq_status_q[2] <= 1'b1;
      end
      if (sne_evt[1]) begin
        sne_error_count_q <= sne_error_count_q + 32'd1;
        sne_error_seen_q <= 1'b1;
        accel_irq_status_q[3] <= 1'b1;
      end
      unique case (mmio_word_addr)
        MMIO_SCRATCH0_OFFSET:    mmio_scratch0_q <= core_data_wdata[0];
        MMIO_SCRATCH1_OFFSET:    mmio_scratch1_q <= core_data_wdata[0];
        MMIO_GPIO_OFFSET:        mmio_gpio_q     <= core_data_wdata[0];
        MMIO_UART_TX_OFFSET:     uart_tx_reg_q   <= core_data_wdata[0];
        MMIO_BAD_ACCESS_OFFSET:  bad_access_q    <= core_data_wdata[0];
        MMIO_CYCLE_COUNT_OFFSET: cycle_counter_q <= core_data_wdata[0];
        MMIO_CUTIE_DONE_COUNT_OFFSET: cutie_done_count_q <= core_data_wdata[0];
        MMIO_CUTIE_TIMEOUT_COUNT_OFFSET: cutie_timeout_count_q <= core_data_wdata[0];
        MMIO_ACCEL_IRQ_STATUS_OFFSET: accel_irq_status_q <= accel_irq_status_q & ~core_data_wdata[0];
        MMIO_ACCEL_IRQ_MASK_OFFSET: accel_irq_mask_q <= core_data_wdata[0];
        MMIO_SNE_DONE_COUNT_OFFSET: sne_done_count_q <= core_data_wdata[0];
        MMIO_SNE_ERROR_COUNT_OFFSET: sne_error_count_q <= core_data_wdata[0];
        MMIO_DMA_STATUS_OFFSET: begin
          if (core_data_wdata[0][1]) begin
            dma_status_q[1] <= 1'b0;
            dma_status_q[2] <= 1'b0;
            dma_status_q[31:16] <= 16'd0;
          end
        end
        default: ;
      endcase
    end else if (data_req_fire && ~data_is_local && ~data_is_mmio && ~data_is_cutie_cfg && ~data_is_sne_cfg) begin
      cycle_counter_q <= cycle_counter_q + 32'd1;
      if (cutie_evt_o[0]) begin
        cutie_done_count_q <= cutie_done_count_q + 32'd1;
        cutie_done_seen_q <= 1'b1;
        accel_irq_status_q[0] <= 1'b1;
      end
      if (cutie_evt_o[1]) begin
        cutie_timeout_count_q <= cutie_timeout_count_q + 32'd1;
        cutie_timeout_seen_q <= 1'b1;
        accel_irq_status_q[1] <= 1'b1;
      end
      if (sne_evt[0]) begin
        sne_done_count_q <= sne_done_count_q + 32'd1;
        sne_done_seen_q <= 1'b1;
        accel_irq_status_q[2] <= 1'b1;
      end
      if (sne_evt[1]) begin
        sne_error_count_q <= sne_error_count_q + 32'd1;
        sne_error_seen_q <= 1'b1;
        accel_irq_status_q[3] <= 1'b1;
      end
      bad_access_q <= bad_access_q + 32'd1;
    end else begin
      cycle_counter_q <= cycle_counter_q + 32'd1;
      if (cutie_evt_o[0]) begin
        cutie_done_count_q <= cutie_done_count_q + 32'd1;
        cutie_done_seen_q <= 1'b1;
        accel_irq_status_q[0] <= 1'b1;
      end
      if (cutie_evt_o[1]) begin
        cutie_timeout_count_q <= cutie_timeout_count_q + 32'd1;
        cutie_timeout_seen_q <= 1'b1;
        accel_irq_status_q[1] <= 1'b1;
      end
      if (sne_evt[0]) begin
        sne_done_count_q <= sne_done_count_q + 32'd1;
        sne_done_seen_q <= 1'b1;
        accel_irq_status_q[2] <= 1'b1;
      end
      if (sne_evt[1]) begin
        sne_error_count_q <= sne_error_count_q + 32'd1;
        sne_error_seen_q <= 1'b1;
        accel_irq_status_q[3] <= 1'b1;
      end
      if (data_req_fire && core_data_we[0] && (data_is_cutie_cfg === 1'b1) &&
          (core_data_addr[0][11:0] == 12'h000) && core_data_wdata[0][0]) begin
        cutie_done_seen_q <= 1'b0;
        cutie_timeout_seen_q <= 1'b0;
        accel_irq_status_q[1:0] <= 2'b00;
      end
    end
  end

  always_comb begin
    if (data_is_cutie_cfg) begin
      data_resp_new = core_data_we[0] ? 32'd0 : cutie_cfg_bus.r_rdata;
    end else if (data_is_sne_cfg) begin
      data_resp_new = sne_cfg_bus.r_rdata;
    end else if (data_is_mmio) begin
      data_resp_new = core_data_we[0] ? 32'd0 : mmio_rdata;
    end else if (data_is_local) begin
      data_resp_new = data_mem_rdata;
    end else begin
      data_resp_new = core_data_we[0] ? 32'd0 : BAD_ACCESS_RDATA;
    end
  end

  assign sne_cfg_rvalid     = (sne_cfg_bus.r_valid === 1'b1);
  assign data_rsp_push_fire = (data_req_fire && (!data_is_sne_cfg || core_data_we[0])) ||
                              sne_cfg_rvalid;
  assign data_rsp_push_data = sne_cfg_rvalid ? sne_cfg_bus.r_rdata : data_resp_new;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      data_rsp_count_q <= 2'd0;
      data_rsp_q0      <= 32'd0;
      data_rsp_q1      <= 32'd0;
      data_rsp_pending_q <= 1'b0;
      data_rsp_data_q    <= 32'd0;
      data_rvalid_q    <= 1'b0;
      data_rdata_q     <= 32'd0;
    end else begin
      if (STRICT_SINGLE_OUTSTANDING) begin
        data_rsp_pending_q <= data_rsp_push_fire;
        if (data_rsp_push_fire)
          data_rsp_data_q <= data_rsp_push_data;

        data_rsp_count_q <= 2'd0;
        data_rsp_q0      <= 32'd0;
        data_rsp_q1      <= 32'd0;
        data_rvalid_q    <= 1'b0;
        data_rdata_q     <= 32'd0;
      end else begin
        data_rsp_pending_q <= 1'b0;
        data_rvalid_q <= data_rsp_pop;
        if (data_rsp_pop) begin
          data_rdata_q <= data_rsp_q0;
        end

        casez ({data_rsp_push_fire, data_rsp_pop})
          2'b00: begin
            // no push/pop
          end
          2'b01: begin
            // pop only
            if (data_rsp_count_q == 2'd2)
              data_rsp_q0 <= data_rsp_q1;
            data_rsp_count_q <= data_rsp_count_q - 2'd1;
          end
          2'b10: begin
            // push only
            if (data_rsp_count_q == 2'd0)
              data_rsp_q0 <= data_rsp_push_data;
            else if (data_rsp_count_q == 2'd1)
              data_rsp_q1 <= data_rsp_push_data;
            data_rsp_count_q <= (data_rsp_count_q == 2'd2) ? 2'd2 : (data_rsp_count_q + 2'd1);
          end
          2'b11: begin
            // push and pop in same cycle
            if (data_rsp_count_q == 2'd1) begin
              data_rsp_q0 <= data_rsp_push_data;
            end else if (data_rsp_count_q == 2'd2) begin
              data_rsp_q0 <= data_rsp_q1;
              data_rsp_q1 <= data_rsp_push_data;
            end
          end
          default: begin
            // Hold state if any sideband source is still unknown during bring-up.
          end
        endcase
      end
    end
  end

  assign cutie_cfg_req_cpu   = core_data_req[0] && (data_is_cutie_cfg === 1'b1);
  assign cutie_cfg_wen_cpu   = ~core_data_we[0];
  assign cutie_cfg_addr_cpu  = {20'd0, core_data_addr[0][11:0]};
  assign cutie_cfg_wdata_cpu = core_data_wdata[0];
  assign dma_words_this_iter = (dma_target_q < 2) ? ((dma_remaining_q > 32'd1) ? 32'd2 : 32'd1) : 32'd1;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      dma_state_q <= DMA_IDLE;
      dma_desc_ptr_q <= 32'd0;
      dma_next_desc_q <= 32'd0;
      dma_src_addr_q <= 32'd0;
      dma_dst_addr_q <= 32'd0;
      dma_bank_q <= 32'd0;
      dma_word_count_q <= 32'd0;
      dma_control_q <= 32'd0;
      dma_remaining_q <= 32'd0;
      dma_curr_src_q <= 32'd0;
      dma_curr_dst_q <= 32'd0;
      dma_read_lo_q <= 32'd0;
      dma_read_hi_q <= 32'd0;
      dma_fetch_index_q <= 3'd0;
      dma_target_q <= 2'd0;
      dma_busy_q <= 1'b0;
      dma_done_q <= 1'b0;
      dma_error_q <= 1'b0;
      dma_done_count_q <= 32'd0;
      dma_error_count_q <= 32'd0;
      dma_irq_en_q <= 1'b0;
      dma_chain_en_q <= 1'b0;
    end else begin
      dma_done_q <= 1'b0;
      dma_error_q <= 1'b0;
      if (data_req_fire && core_data_we[0] && (data_is_mmio === 1'b1)) begin
        unique case (mmio_word_addr)
          MMIO_DMA_DESC_PTR_OFFSET: dma_desc_ptr_q <= core_data_wdata[0];
          MMIO_DMA_DONE_COUNT_OFFSET: dma_done_count_q <= core_data_wdata[0];
          MMIO_DMA_ERROR_COUNT_OFFSET: dma_error_count_q <= core_data_wdata[0];
          default: ;
        endcase
      end
      if (data_req_fire && core_data_we[0] && (data_is_mmio === 1'b1) &&
          (mmio_word_addr == MMIO_DMA_STATUS_OFFSET) && core_data_wdata[0][0] && !dma_busy_q) begin
        dma_state_q <= DMA_DESC_REQ;
        dma_fetch_index_q <= 3'd0;
        dma_busy_q <= 1'b1;
        dma_status_q[0] <= 1'b1;
        dma_status_q[1] <= 1'b0;
        dma_status_q[2] <= 1'b0;
        dma_status_q[31:16] <= 16'd0;
      end else begin
        unique case (dma_state_q)
          DMA_IDLE: begin end
          DMA_DESC_REQ: dma_state_q <= DMA_DESC_CAP;
          DMA_DESC_CAP: begin
            unique case (dma_fetch_index_q)
              3'd0: dma_src_addr_q <= dma_mem_rdata;
              3'd1: dma_dst_addr_q <= dma_mem_rdata;
              3'd2: dma_bank_q <= dma_mem_rdata;
              3'd3: dma_word_count_q <= dma_mem_rdata;
              3'd4: dma_control_q <= dma_mem_rdata;
              3'd5: dma_next_desc_q <= dma_mem_rdata;
              default: ;
            endcase
            if (dma_fetch_index_q == 3'd5) begin
              dma_curr_src_q <= dma_src_addr_q[17:2];
              dma_curr_dst_q <= dma_dst_addr_q;
              dma_remaining_q <= dma_word_count_q;
              dma_target_q <= dma_control_q[1:0];
              dma_irq_en_q <= dma_control_q[8];
              dma_chain_en_q <= dma_control_q[9];
              if (dma_word_count_q == 32'd0) begin
                dma_state_q <= DMA_ERROR;
                dma_status_q[31:16] <= 16'h0001;
              end else begin
                dma_state_q <= DMA_PREP_RD0;
              end
            end else begin
              dma_fetch_index_q <= dma_fetch_index_q + 3'd1;
              dma_state_q <= DMA_DESC_REQ;
            end
          end
          DMA_PREP_RD0: dma_state_q <= DMA_CAP_RD0;
          DMA_CAP_RD0: begin
            dma_read_lo_q <= dma_mem_rdata;
            if ((dma_target_q < 2) && (dma_remaining_q > 32'd1))
              dma_state_q <= DMA_PREP_RD1;
            else begin
              dma_read_hi_q <= 32'd0;
              dma_state_q <= (dma_target_q < 2) ? DMA_CFG_BANK : DMA_CFG_ADDR;
            end
          end
          DMA_PREP_RD1: dma_state_q <= DMA_CAP_RD1;
          DMA_CAP_RD1: begin
            dma_read_hi_q <= dma_mem_rdata;
            dma_state_q <= DMA_CFG_BANK;
          end
          DMA_CFG_BANK: dma_state_q <= DMA_CFG_ADDR;
          DMA_CFG_ADDR: dma_state_q <= DMA_CFG_LO;
          DMA_CFG_LO: dma_state_q <= (dma_target_q < 2) ? DMA_CFG_HI : DMA_CFG_WR;
          DMA_CFG_HI: dma_state_q <= DMA_CFG_WR;
          DMA_CFG_WR: begin
            dma_curr_src_q <= dma_curr_src_q + dma_words_this_iter;
            dma_curr_dst_q <= dma_curr_dst_q + 32'd1;
            if (dma_remaining_q <= dma_words_this_iter)
              dma_remaining_q <= 32'd0;
            else
              dma_remaining_q <= dma_remaining_q - dma_words_this_iter;

            if (dma_remaining_q <= dma_words_this_iter) begin
              if (dma_chain_en_q && (dma_next_desc_q != 32'd0)) begin
                dma_desc_ptr_q <= dma_next_desc_q;
                dma_fetch_index_q <= 3'd0;
                dma_state_q <= DMA_DESC_REQ;
              end else begin
                dma_state_q <= DMA_DONE;
              end
            end else begin
              dma_state_q <= DMA_PREP_RD0;
            end
          end
          DMA_DONE: begin
            dma_busy_q <= 1'b0;
            dma_done_q <= 1'b1;
            dma_status_q[0] <= 1'b0;
            dma_status_q[1] <= 1'b1;
            dma_done_count_q <= dma_done_count_q + 32'd1;
            dma_state_q <= DMA_IDLE;
          end
          DMA_ERROR: begin
            dma_busy_q <= 1'b0;
            dma_error_q <= 1'b1;
            dma_status_q[0] <= 1'b0;
            dma_status_q[2] <= 1'b1;
            dma_error_count_q <= dma_error_count_q + 32'd1;
            dma_state_q <= DMA_IDLE;
          end
          default: dma_state_q <= DMA_IDLE;
        endcase
      end
    end
  end

  always_comb begin
    dma_mem_req = 1'b0;
    dma_mem_addr = dma_curr_src_q[15:0];
    cutie_cfg_req_dma = 1'b0;
    cutie_cfg_wen_dma = 1'b0;
    cutie_cfg_addr_dma = 32'd0;
    cutie_cfg_wdata_dma = 32'd0;

    unique case (dma_state_q)
      DMA_DESC_REQ,
      DMA_DESC_CAP: begin
        dma_mem_req = 1'b1;
        dma_mem_addr = dma_desc_ptr_q[17:2] + dma_fetch_index_q;
      end
      DMA_PREP_RD0,
      DMA_CAP_RD0: begin
        dma_mem_req = 1'b1;
        dma_mem_addr = dma_curr_src_q[15:0];
      end
      DMA_PREP_RD1,
      DMA_CAP_RD1: begin
        dma_mem_req = 1'b1;
        dma_mem_addr = dma_curr_src_q + 32'd1;
      end
      DMA_CFG_BANK: begin
        cutie_cfg_req_dma = 1'b1;
        cutie_cfg_addr_dma = (dma_target_q == 2'd0) ? CUTIE_ACT_BANK_ADDR : CUTIE_WGT_BANK_ADDR;
        cutie_cfg_wdata_dma = dma_bank_q;
      end
      DMA_CFG_ADDR: begin
        cutie_cfg_req_dma = 1'b1;
        unique case (dma_target_q)
          2'd0: cutie_cfg_addr_dma = CUTIE_ACT_DST_ADDR;
          2'd1: cutie_cfg_addr_dma = CUTIE_WGT_DST_ADDR;
          default: cutie_cfg_addr_dma = CUTIE_LINEAR_DST_ADDR;
        endcase
        cutie_cfg_wdata_dma = dma_curr_dst_q;
      end
      DMA_CFG_LO: begin
        cutie_cfg_req_dma = 1'b1;
        unique case (dma_target_q)
          2'd0: cutie_cfg_addr_dma = CUTIE_ACT_LO_ADDR;
          2'd1: cutie_cfg_addr_dma = CUTIE_WGT_LO_ADDR;
          default: cutie_cfg_addr_dma = CUTIE_LINEAR_DATA_ADDR;
        endcase
        cutie_cfg_wdata_dma = dma_read_lo_q;
      end
      DMA_CFG_HI: begin
        cutie_cfg_req_dma = 1'b1;
        cutie_cfg_addr_dma = (dma_target_q == 2'd0) ? CUTIE_ACT_HI_ADDR : CUTIE_WGT_HI_ADDR;
        cutie_cfg_wdata_dma = dma_read_hi_q;
      end
      DMA_CFG_WR: begin
        cutie_cfg_req_dma = 1'b1;
        unique case (dma_target_q)
          2'd0: cutie_cfg_addr_dma = CUTIE_ACT_WR_ADDR;
          2'd1: cutie_cfg_addr_dma = CUTIE_WGT_WR_ADDR;
          2'd2: cutie_cfg_addr_dma = CUTIE_LINEAR_ACT_WR_ADDR;
          default: cutie_cfg_addr_dma = CUTIE_LINEAR_WGT_WR_ADDR;
        endcase
        cutie_cfg_wdata_dma = 32'd1;
      end
      default: ;
    endcase
  end

  assign cutie_cfg_req_mux   = cutie_cfg_req_dma ? cutie_cfg_req_dma : cutie_cfg_req_cpu;
  assign cutie_cfg_wen_mux   = cutie_cfg_req_dma ? cutie_cfg_wen_dma : cutie_cfg_wen_cpu;
  assign cutie_cfg_addr_mux  = cutie_cfg_req_dma ? cutie_cfg_addr_dma : cutie_cfg_addr_cpu;
  assign cutie_cfg_wdata_mux = cutie_cfg_req_dma ? cutie_cfg_wdata_dma : cutie_cfg_wdata_cpu;

  always_comb begin
    unique case (mmio_word_addr)
      MMIO_SCRATCH0_OFFSET:      mmio_rdata = mmio_scratch0_q;
      MMIO_SCRATCH1_OFFSET:      mmio_rdata = mmio_scratch1_q;
      MMIO_GPIO_OFFSET:          mmio_rdata = mmio_gpio_q;
      MMIO_UART_TX_OFFSET:       mmio_rdata = uart_tx_reg_q;
      MMIO_UART_STATUS_OFFSET:   mmio_rdata = uart_status_q;
      MMIO_BAD_ACCESS_OFFSET:    mmio_rdata = bad_access_q;
      MMIO_CYCLE_COUNT_OFFSET:   mmio_rdata = cycle_counter_q;
      MMIO_CUTIE_DONE_COUNT_OFFSET: mmio_rdata = cutie_done_count_q;
      MMIO_CUTIE_TIMEOUT_COUNT_OFFSET: mmio_rdata = cutie_timeout_count_q;
      MMIO_CUTIE_STATUS_OFFSET:  mmio_rdata = cutie_status_live;
      MMIO_CUTIE_READBACK_OFFSET:mmio_rdata = cutie_readback_q;
      MMIO_ACCEL_IRQ_STATUS_OFFSET: mmio_rdata = accel_irq_status_q & accel_irq_mask_q;
      MMIO_ACCEL_IRQ_MASK_OFFSET: mmio_rdata = accel_irq_mask_q;
      MMIO_ACCEL_BUSY_OFFSET: mmio_rdata = accel_busy_live;
      MMIO_SNE_DONE_COUNT_OFFSET: mmio_rdata = sne_done_count_q;
      MMIO_SNE_ERROR_COUNT_OFFSET: mmio_rdata = sne_error_count_q;
      MMIO_DMA_DESC_PTR_OFFSET: mmio_rdata = dma_desc_ptr_q;
      MMIO_DMA_STATUS_OFFSET: mmio_rdata = dma_status_q;
      MMIO_DMA_REMAINING_OFFSET: mmio_rdata = dma_remaining_q;
      MMIO_DMA_CUR_SRC_OFFSET: mmio_rdata = dma_curr_src_q;
      MMIO_DMA_CUR_DST_OFFSET: mmio_rdata = dma_curr_dst_q;
      MMIO_DMA_DONE_COUNT_OFFSET: mmio_rdata = dma_done_count_q;
      MMIO_DMA_ERROR_COUNT_OFFSET: mmio_rdata = dma_error_count_q;
      default: mmio_rdata = 32'hDEAD_B33F;
    endcase
  end

  XBAR_PERIPH_BUS cutie_cfg_bus();

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      cutie_status_q   <= 32'd0;
      cutie_readback_q <= 32'd0;
      cutie_cfg_addr_q <= 32'd0;
    end else begin
      if (cutie_cfg_req_cpu && cutie_cfg_wen_cpu) begin
        cutie_cfg_addr_q <= cutie_cfg_addr_cpu;
      end

      if (cutie_cfg_bus.r_valid) begin
        if (cutie_cfg_addr_q == 32'h0000_0000) begin
          cutie_status_q[31:3] <= cutie_cfg_bus.r_rdata[31:3];
        end else begin
          cutie_readback_q <= cutie_cfg_bus.r_rdata;
        end
      end
    end
  end

  always_comb begin
    cutie_status_live = 32'd0;
    cutie_status_live[0]   = cutie_busy_o;
    cutie_status_live[1]   = cutie_done_seen_q | cutie_evt_o[0];
    cutie_status_live[2]   = cutie_timeout_seen_q | cutie_evt_o[1];
    cutie_status_live[31:3]= cutie_status_q[31:3];
    accel_busy_live = 32'd0;
    accel_busy_live[0] = cutie_busy_o;
    accel_busy_live[1] = sne_busy;
    accel_busy_live[2] = dma_busy_q;
    accel_busy_live[15:0] = accel_irq_status_q[15:0] & accel_irq_mask_q[15:0];
  end

  assign cutie_cfg_bus.req   = cutie_cfg_req_mux;
  assign cutie_cfg_bus.add   = cutie_cfg_addr_mux;
  assign cutie_cfg_bus.wen   = cutie_cfg_wen_mux;
  assign cutie_cfg_bus.wdata = cutie_cfg_wdata_mux;
  assign cutie_cfg_bus.be    = 4'hF;
  assign cutie_cfg_bus.id    = '0;

  cutie_hwpe_wrap i_cutie (
    .clk_i   ( clk_i         ),
    .rst_ni  ( rst_n_q       ),
    .cfg_bus ( cutie_cfg_bus ),
    .evt_o   ( cutie_evt_o   ),
    .busy_o  ( cutie_busy_o  )
  );

  // ── SNE integration ────────────────────────────────────────────────────────
  // Separate track from CUTIE; uses an independent 4 KB window at 0x1A12_0000.
  XBAR_PERIPH_BUS sne_cfg_bus();

  logic        sne_busy;
  logic [1:0]  sne_evt;

  assign sne_cfg_bus.req   = core_data_req[0] && (data_is_sne_cfg === 1'b1);
  assign sne_cfg_bus.add   = {20'd0, core_data_addr[0][11:0]};
  assign sne_cfg_bus.wen   = ~core_data_we[0];
  assign sne_cfg_bus.wdata = core_data_wdata[0];
  assign sne_cfg_bus.be    = 4'hF;
  assign sne_cfg_bus.id    = '0;

  sne_wrap i_sne (
    .clk_i   ( clk_i       ),
    .rst_ni  ( rst_n_q     ),
    .cfg_bus ( sne_cfg_bus ),
    .evt_o   ( sne_evt     ),
    .busy_o  ( sne_busy    )
  );

  assign core_0_addr_o = core_instr_addr[0];
  assign core_0_data_o = core_instr_rdata[0];
  assign core_0_req_o  = core_instr_req[0];
  assign mem_valid_o   = core_instr_rvalid[0] | core_data_rvalid[0];
  assign mem_data_o    = core_data_rvalid[0] ? core_data_rdata[0] : core_instr_rdata[0];

endmodule

module kraken_soc_func_unified_mem #(
  parameter int unsigned DATA_WIDTH = 32,
  parameter int unsigned NUM_WORDS  = 65536
) (
  input  logic                          clk_i,
  input  logic                          instr_req_i,
  input  logic [$clog2(NUM_WORDS)-1:0]  instr_addr_i,
  output logic [DATA_WIDTH-1:0]         instr_rdata_o,
  input  logic                          data_req_i,
  input  logic                          data_we_i,
  input  logic [$clog2(NUM_WORDS)-1:0]  data_addr_i,
  input  logic [DATA_WIDTH-1:0]         data_wdata_i,
  input  logic [(DATA_WIDTH/8)-1:0]     data_be_i,
  output logic [DATA_WIDTH-1:0]         data_rdata_o,
  input  logic                          dma_req_i,
  input  logic [$clog2(NUM_WORDS)-1:0]  dma_addr_i,
  output logic [DATA_WIDTH-1:0]         dma_rdata_o
);
  localparam int unsigned ADDR_WIDTH = $clog2(NUM_WORDS);

  (* ram_style = "block" *) logic [DATA_WIDTH-1:0] ram [NUM_WORDS-1:0];
  logic [ADDR_WIDTH-1:0] porta_addr_q;
  logic                  porta_valid_q;

`ifndef SYNTHESIS
  initial begin
    for (int i = 0; i < NUM_WORDS; i++) begin
      ram[i] = '0;
    end
  end
`endif

  always_ff @(posedge clk_i) begin
    porta_valid_q <= 1'b0;
    if (instr_req_i || dma_req_i) begin
      // Use one read port for instruction/DMA traffic (instruction has priority).
      porta_addr_q  <= instr_req_i ? instr_addr_i : dma_addr_i;
      porta_valid_q <= 1'b1;
    end

    if (porta_valid_q) begin
      instr_rdata_o <= ram[porta_addr_q];
      dma_rdata_o   <= ram[porta_addr_q];
    end

    if (data_req_i) begin
      if (data_we_i) begin
        for (int i = 0; i < (DATA_WIDTH/8); i++)
          if (data_be_i[i]) ram[data_addr_i][8*i +: 8] <= data_wdata_i[8*i +: 8];
      end

      data_rdata_o <= ram[data_addr_i];
    end
  end
endmodule
