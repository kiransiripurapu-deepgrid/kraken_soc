//-----------------------------------------------------------------------------
// Title   : Mini Kraken FPGA Top
// Description: PULPissimo SoC + PULP Cluster on Nexys A7 FPGA
//-----------------------------------------------------------------------------
`include "pulp_soc_defines.sv"

module mini_kraken_top #(
  parameter int unsigned CORE_TYPE  = 0,
  parameter bit          USE_XPULP  = 1,
  parameter bit          USE_FPU    = 0,
  parameter bit          USE_ZFINX  = 1,
  parameter bit          USE_HWPE   = 0,
  parameter int unsigned NB_CORES   = 8  // Number of cores in the cluster
)(
  // FPGA board clock
  input  wire        sys_clk,
  // Active-low reset
  input  wire        pad_reset_n,

  // JTAG
  inout  wire        pad_jtag_tck,
  inout  wire        pad_jtag_tdi,
  input  wire        pad_jtag_tdo,
  inout  wire        pad_jtag_tms,

  // UART
  inout  wire        pad_uart_rx,
  inout  wire        pad_uart_tx,

  // SPI
  inout  wire        pad_spim_sdio0,
  inout  wire        pad_spim_sdio1,
  inout  wire        pad_spim_sdio2,
  inout  wire        pad_spim_sdio3,
  inout  wire        pad_spim_csn0,
  inout  wire        pad_spim_sck,

  // LEDs and switches for debug
  inout  wire        led0_o,
  inout  wire        led1_o,
  inout  wire        led2_o,
  inout  wire        led3_o,
  inout  wire        switch0_i,
  inout  wire        switch1_i,
  inout  wire        btnc_i,

  // SDIO
  inout  wire        sdio_reset_o,
  inout  wire        pad_sdio_clk,
  inout  wire        pad_sdio_cmd,
  inout  wire        pad_sdio_data0,
  inout  wire        pad_sdio_data1,
  inout  wire        pad_sdio_data2,
  inout  wire        pad_sdio_data3,

  // I2C
  inout  wire        pad_i2c0_sda,
  inout  wire        pad_i2c0_scl
);

  // ========================================================================
  // Parameters - kept for pulp_soc instantiation
  // ========================================================================
  localparam CDC_FIFOS_LOG_DEPTH = 3;
  localparam AXI_ADDR_WIDTH     = 32;
  localparam AXI_DATA_IN_WIDTH  = 64;
  localparam AXI_DATA_OUT_WIDTH = 32;
  localparam AXI_ID_IN_WIDTH    = 6;
  localparam AXI_USER_WIDTH     = 6;
  localparam EVNT_WIDTH         = 8;

  // ========================================================================
  // Clock and Reset Generation
  // ========================================================================
  logic soc_clk, per_clk, slow_clk, cluster_clk;
  logic soc_rstn, per_rstn, slow_clk_rstn, cluster_rstn;
  logic s_locked;
  logic rst_n;

  assign rst_n = pad_reset_n;

  xilinx_clk_mngr i_clk_manager (
    .resetn       ( rst_n       ),
    .clk_in1      ( sys_clk     ),
    .soc_clk_o    ( soc_clk     ),
    .per_clk_o    ( per_clk     ),
    .cluster_clk_o( cluster_clk ),
    .locked       ( s_locked    )
  );

  fpga_slow_clk_gen i_slow_clk_gen (
    .ref_clk_i  ( sys_clk  ),
    .rst_ni     ( rst_n     ),
    .slow_clk_o ( slow_clk  )
  );

  rstgen i_soc_rstgen (
    .clk_i       ( soc_clk         ),
    .rst_ni      ( s_locked & rst_n ),
    .test_mode_i ( 1'b0            ),
    .rst_no      ( soc_rstn        ),
    .init_no     (                 )
  );

  rstgen i_per_rstgen (
    .clk_i       ( per_clk         ),
    .rst_ni      ( s_locked & rst_n ),
    .test_mode_i ( 1'b0            ),
    .rst_no      ( per_rstn        ),
    .init_no     (                 )
  );

  rstgen i_slow_rstgen (
    .clk_i       ( slow_clk        ),
    .rst_ni      ( s_locked & rst_n ),
    .test_mode_i ( 1'b0            ),
    .rst_no      ( slow_clk_rstn   ),
    .init_no     (                 )
  );

  rstgen i_cluster_rstgen (
    .clk_i       ( cluster_clk     ),
    .rst_ni      ( s_locked & rst_n ),
    .test_mode_i ( 1'b0            ),
    .rst_no      ( cluster_rstn    ),
    .init_no     (                 )
  );

  // ========================================================================
  // Async CDC Wires - widths from pulp_cluster_wrap_package
  // ========================================================================
  // Shorthand for the CDC log depth from the cluster config
  localparam CdcLogDepth = pulp_cluster_wrap_package::Cfg.AxiCdcLogDepth;

  // ---- SoC "slave" port / Cluster "master" port ----
  // (Cluster AXI master ? SoC AXI slave)
  // SoC sees these as "slave" inputs; Cluster drives them as "master" outputs
  logic [CdcLogDepth:0]                                             async_soc_slave_aw_wptr;
  logic [pulp_cluster_wrap_package::AsyncOutAwDataWidth-1:0]        async_soc_slave_aw_data;
  logic [CdcLogDepth:0]                                             async_soc_slave_aw_rptr;

  logic [CdcLogDepth:0]                                             async_soc_slave_ar_wptr;
  logic [pulp_cluster_wrap_package::AsyncOutArDataWidth-1:0]        async_soc_slave_ar_data;
  logic [CdcLogDepth:0]                                             async_soc_slave_ar_rptr;

  logic [CdcLogDepth:0]                                             async_soc_slave_w_wptr;
  logic [pulp_cluster_wrap_package::AsyncOutWDataWidth-1:0]         async_soc_slave_w_data;
  logic [CdcLogDepth:0]                                             async_soc_slave_w_rptr;

  logic [CdcLogDepth:0]                                             async_soc_slave_r_wptr;
  logic [pulp_cluster_wrap_package::AsyncOutRDataWidth-1:0]         async_soc_slave_r_data;
  logic [CdcLogDepth:0]                                             async_soc_slave_r_rptr;

  logic [CdcLogDepth:0]                                             async_soc_slave_b_wptr;
  logic [pulp_cluster_wrap_package::AsyncOutBDataWidth-1:0]         async_soc_slave_b_data;
  logic [CdcLogDepth:0]                                             async_soc_slave_b_rptr;

  // ---- SoC "master" port / Cluster "slave" port ----
  // (SoC AXI master ? Cluster AXI slave)
  // SoC drives these as "master" outputs; Cluster sees them as "slave" inputs
  logic [CdcLogDepth:0]                                             async_soc_master_aw_wptr;
  logic [pulp_cluster_wrap_package::AsyncInAwDatawidth-1:0]         async_soc_master_aw_data;
  logic [CdcLogDepth:0]                                             async_soc_master_aw_rptr;

  logic [CdcLogDepth:0]                                             async_soc_master_ar_wptr;
  logic [pulp_cluster_wrap_package::AsyncInArDatawidth-1:0]         async_soc_master_ar_data;
  logic [CdcLogDepth:0]                                             async_soc_master_ar_rptr;

  logic [CdcLogDepth:0]                                             async_soc_master_w_wptr;
  logic [pulp_cluster_wrap_package::AsyncInWDatawidth-1:0]          async_soc_master_w_data;
  logic [CdcLogDepth:0]                                             async_soc_master_w_rptr;

  logic [CdcLogDepth:0]                                             async_soc_master_r_wptr;
  logic [pulp_cluster_wrap_package::AsyncInRDataWidth-1:0]          async_soc_master_r_data;
  logic [CdcLogDepth:0]                                             async_soc_master_r_rptr;

  logic [CdcLogDepth:0]                                             async_soc_master_b_wptr;
  logic [pulp_cluster_wrap_package::AsyncInBDataWidth-1:0]          async_soc_master_b_data;
  logic [CdcLogDepth:0]                                             async_soc_master_b_rptr;

  // ---- Cluster Events ----
  logic [pulp_cluster_wrap_package::AsyncEventDataWidth-1:0]        async_cluster_events_data;
  logic [CdcLogDepth:0]                                             async_cluster_events_wptr;
  logic [CdcLogDepth:0]                                             async_cluster_events_rptr;

  // ---- Cluster control signals ----
  logic        cluster_busy;
  logic        cluster_eoc;
  logic        cluster_rstn_req;
  logic        cluster_axi_isolated;
  logic [pulp_cluster_wrap_package::Cfg.NumCores-1:0] cluster_dbg_irq_valid;
  logic        dma_pe_evt_ack, dma_pe_evt_valid;
  logic        dma_pe_irq_ack, dma_pe_irq_valid;
  logic        pf_evt_ack, pf_evt_valid;

  // ========================================================================
  // Peripheral signal wires
  // ========================================================================
  logic [3:0] s_timer_ch0, s_timer_ch1, s_timer_ch2, s_timer_ch3;

  localparam NGPIO = gpio_reg_pkg::GPIOCount;
  logic [NGPIO-1:0] s_gpio_in, s_gpio_out, s_gpio_tx_en;

  uart_pkg::uart_to_pad_t [udma_cfg_pkg::N_UART-1:0] s_uart_to_pad;
  uart_pkg::pad_to_uart_t [udma_cfg_pkg::N_UART-1:0] s_pad_to_uart;
  i2c_pkg::i2c_to_pad_t   [udma_cfg_pkg::N_I2C-1:0]  s_i2c_to_pad;
  i2c_pkg::pad_to_i2c_t   [udma_cfg_pkg::N_I2C-1:0]  s_pad_to_i2c;
  sdio_pkg::sdio_to_pad_t  [udma_cfg_pkg::N_SDIO-1:0] s_sdio_to_pad;
  sdio_pkg::pad_to_sdio_t  [udma_cfg_pkg::N_SDIO-1:0] s_pad_to_sdio;
  i2s_pkg::i2s_to_pad_t   [udma_cfg_pkg::N_I2S-1:0]  s_i2s_to_pad;
  i2s_pkg::pad_to_i2s_t   [udma_cfg_pkg::N_I2S-1:0]  s_pad_to_i2s;
  qspi_pkg::qspi_to_pad_t [udma_cfg_pkg::N_QSPIM-1:0] s_qspi_to_pad;
  qspi_pkg::pad_to_qspi_t [udma_cfg_pkg::N_QSPIM-1:0] s_pad_to_qspi;
  cpi_pkg::pad_to_cpi_t   [udma_cfg_pkg::N_CPI-1:0]  s_pad_to_cpi;
  hyper_pkg::hyper_to_pad_t [udma_cfg_pkg::N_HYPER-1:0] s_hyper_to_pad;
  hyper_pkg::pad_to_hyper_t [udma_cfg_pkg::N_HYPER-1:0] s_pad_to_hyper;

  // APB chip control
  logic        s_apb_pready;
  logic [31:0] s_apb_prdata;
  logic        s_apb_pslverr;

  assign s_apb_pready  = 1'b1;
  assign s_apb_prdata  = 32'h0;
  assign s_apb_pslverr = 1'b0;

  // JTAG signals
  logic s_jtag_tck, s_jtag_tdi, s_jtag_tdo, s_jtag_tms, s_jtag_trstn;
  logic s_jtag_bypass_fll;

  // ========================================================================
  // PULP SoC Instance
  // ========================================================================
  //
  // CDC cross-connection mapping:
  //   SoC "slave"  ports ?? Cluster "master" ports  (Cluster?SoC data path)
  //   SoC "master" ports ?? Cluster "slave"  ports  (SoC?Cluster data path)
  //
  pulp_soc #(
    .CORE_TYPE           ( CORE_TYPE         ),
    .USE_XPULP           ( USE_XPULP         ),
    .USE_FPU             ( USE_FPU           ),
    .USE_HWPE            ( USE_HWPE          ),
    .SIM_STDOUT          ( 0                 ),
    .USE_ZFINX           ( USE_ZFINX         ),
    .AXI_ADDR_WIDTH      ( AXI_ADDR_WIDTH    ),
    .AXI_DATA_IN_WIDTH   ( AXI_DATA_IN_WIDTH ),
    .AXI_DATA_OUT_WIDTH  ( AXI_DATA_OUT_WIDTH),
    .AXI_ID_IN_WIDTH     ( AXI_ID_IN_WIDTH   ),
    .AXI_USER_WIDTH      ( AXI_USER_WIDTH    ),
    .CDC_FIFOS_LOG_DEPTH ( CDC_FIFOS_LOG_DEPTH ),
    .EVNT_WIDTH          ( EVNT_WIDTH        ),
    .NB_CORES            ( NB_CORES          )
  ) i_pulp_soc (
    // Clocks and resets
    .slow_clk_i                  ( slow_clk      ),
    .slow_clk_rstn_synced_i      ( slow_clk_rstn ),
    .soc_clk_i                   ( soc_clk       ),
    .soc_rstn_synced_i           ( soc_rstn      ),
    .per_clk_i                   ( per_clk       ),
    .per_rstn_synced_i           ( per_rstn      ),
    .soc_cluster_cdc_rst_ni      ( soc_rstn      ),
    .dft_test_mode_i             ( 1'b0          ),
    .dft_cg_enable_i             ( 1'b0          ),
    .bootsel_i                   ( 2'b00         ),
    .fc_fetch_en_valid_i         ( 1'b1          ),
    .fc_fetch_en_i               ( 1'b1          ),

    // SoC "slave" port - receives data FROM cluster's AXI master
    .async_data_slave_aw_wptr_i  ( async_soc_slave_aw_wptr ),
    .async_data_slave_aw_data_i  ( async_soc_slave_aw_data ),
    .async_data_slave_aw_rptr_o  ( async_soc_slave_aw_rptr ),
    .async_data_slave_ar_wptr_i  ( async_soc_slave_ar_wptr ),
    .async_data_slave_ar_data_i  ( async_soc_slave_ar_data ),
    .async_data_slave_ar_rptr_o  ( async_soc_slave_ar_rptr ),
    .async_data_slave_w_wptr_i   ( async_soc_slave_w_wptr  ),
    .async_data_slave_w_data_i   ( async_soc_slave_w_data  ),
    .async_data_slave_w_rptr_o   ( async_soc_slave_w_rptr  ),
    .async_data_slave_r_wptr_o   ( async_soc_slave_r_wptr  ),
    .async_data_slave_r_data_o   ( async_soc_slave_r_data  ),
    .async_data_slave_r_rptr_i   ( async_soc_slave_r_rptr  ),
    .async_data_slave_b_wptr_o   ( async_soc_slave_b_wptr  ),
    .async_data_slave_b_data_o   ( async_soc_slave_b_data  ),
    .async_data_slave_b_rptr_i   ( async_soc_slave_b_rptr  ),

    // SoC "master" port - sends data TO cluster's AXI slave
    .async_data_master_aw_wptr_o ( async_soc_master_aw_wptr ),
    .async_data_master_aw_data_o ( async_soc_master_aw_data ),
    .async_data_master_aw_rptr_i ( async_soc_master_aw_rptr ),
    .async_data_master_ar_wptr_o ( async_soc_master_ar_wptr ),
    .async_data_master_ar_data_o ( async_soc_master_ar_data ),
    .async_data_master_ar_rptr_i ( async_soc_master_ar_rptr ),
    .async_data_master_w_wptr_o  ( async_soc_master_w_wptr  ),
    .async_data_master_w_data_o  ( async_soc_master_w_data  ),
    .async_data_master_w_rptr_i  ( async_soc_master_w_rptr  ),
    .async_data_master_r_wptr_i  ( async_soc_master_r_wptr  ),
    .async_data_master_r_data_i  ( async_soc_master_r_data  ),
    .async_data_master_r_rptr_o  ( async_soc_master_r_rptr  ),
    .async_data_master_b_wptr_i  ( async_soc_master_b_wptr  ),
    .async_data_master_b_data_i  ( async_soc_master_b_data  ),
    .async_data_master_b_rptr_o  ( async_soc_master_b_rptr  ),

    // Cluster events and control
    .async_cluster_events_wptr_o ( async_cluster_events_wptr ),
    .async_cluster_events_rptr_i ( async_cluster_events_rptr ),
    .async_cluster_events_data_o ( async_cluster_events_data ),
    .cluster_busy_i              ( cluster_busy              ),
    .cluster_rstn_req_o          ( cluster_rstn_req          ),
    .cluster_dbg_irq_valid_o     ( cluster_dbg_irq_valid     ),
    .dma_pe_evt_ack_o            ( dma_pe_evt_ack            ),
    .dma_pe_evt_valid_i          ( dma_pe_evt_valid          ),
    .dma_pe_irq_ack_o            ( dma_pe_irq_ack            ),
    .dma_pe_irq_valid_i          ( dma_pe_irq_valid          ),
    .pf_evt_ack_o                ( pf_evt_ack                ),
    .pf_evt_valid_i              ( pf_evt_valid              ),

    // Peripherals
    .timer_ch0_o                 ( s_timer_ch0     ),
    .timer_ch1_o                 ( s_timer_ch1     ),
    .timer_ch2_o                 ( s_timer_ch2     ),
    .timer_ch3_o                 ( s_timer_ch3     ),
    .uart_to_pad_o               ( s_uart_to_pad   ),
    .pad_to_uart_i               ( s_pad_to_uart   ),
    .i2c_to_pad_o                ( s_i2c_to_pad    ),
    .pad_to_i2c_i                ( s_pad_to_i2c    ),
    .sdio_to_pad_o               ( s_sdio_to_pad   ),
    .pad_to_sdio_i               ( s_pad_to_sdio   ),
    .i2s_to_pad_o                ( s_i2s_to_pad    ),
    .pad_to_i2s_i                ( s_pad_to_i2s    ),
    .qspi_to_pad_o               ( s_qspi_to_pad   ),
    .pad_to_qspi_i               ( s_pad_to_qspi   ),
    .pad_to_cpi_i                ( s_pad_to_cpi    ),
    .hyper_to_pad_o              ( s_hyper_to_pad   ),
    .pad_to_hyper_i              ( s_pad_to_hyper   ),
    .gpio_i                      ( s_gpio_in       ),
    .gpio_o                      ( s_gpio_out      ),
    .gpio_tx_en_o                ( s_gpio_tx_en    ),

    // JTAG
    .jtag_tck_i                  ( s_jtag_tck      ),
    .jtag_trst_ni                ( s_jtag_trstn    ),
    .jtag_tms_i                  ( s_jtag_tms      ),
    .jtag_tdi_i                  ( s_jtag_tdi      ),
    .jtag_tdo_o                  ( s_jtag_tdo      ),
    .jtag_tap_bypass_fll_clk_o   ( s_jtag_bypass_fll ),

    // APB chip control
    .apb_chip_ctrl_master_paddr_o   (  ),
    .apb_chip_ctrl_master_pwdata_o  (  ),
    .apb_chip_ctrl_master_pwrite_o  (  ),
    .apb_chip_ctrl_master_psel_o    (  ),
    .apb_chip_ctrl_master_penable_o (  ),
    .apb_chip_ctrl_master_prdata_i  ( s_apb_prdata  ),
    .apb_chip_ctrl_master_pready_i  ( s_apb_pready  ),
    .apb_chip_ctrl_master_pslverr_i ( s_apb_pslverr ),
    .apb_chip_ctrl_master_pprot_o   (  ),
    .apb_chip_ctrl_master_pstrb_o   (  )
  );

  // ========================================================================
  // PULP Cluster Instance
  // ========================================================================
  //
  // Cross-connection:
  //   SoC "slave"  wires (async_soc_slave_*)  ?? Cluster "master" ports
  //   SoC "master" wires (async_soc_master_*) ?? Cluster "slave"  ports
  //
  pulp_cluster_wrap i_cluster (
    .clk_i                          ( cluster_clk          ),
    .rst_ni                         ( cluster_rstn         ),
    .ref_clk_i                      ( slow_clk             ),
    .pwr_on_rst_ni                  ( rst_n                ),
    .pmu_mem_pwdn_i                 ( 1'b0                 ),
    .base_addr_i                    ( 4'h1                 ),
    .test_mode_i                    ( 1'b0                 ),
    .en_sa_boot_i                   ( 1'b0                 ),
    .cluster_id_i                   ( 6'd0                 ),
    .fetch_en_i                     ( 1'b1                 ),
    .eoc_o                          ( cluster_eoc          ),
    .busy_o                         ( cluster_busy         ),
    .axi_isolate_i                  ( 1'b0                 ),
    .axi_isolated_o                 ( cluster_axi_isolated ),

    // DMA / event handshake
    .dma_pe_evt_ack_i               ( dma_pe_evt_ack       ),
    .dma_pe_evt_valid_o             ( dma_pe_evt_valid      ),
    .dma_pe_irq_ack_i               ( dma_pe_irq_ack       ),
    .dma_pe_irq_valid_o             ( dma_pe_irq_valid      ),
    .pf_evt_ack_i                   ( pf_evt_ack           ),
    .pf_evt_valid_o                 ( pf_evt_valid          ),

    // Debug & mailbox
    .dbg_irq_valid_i                ( cluster_dbg_irq_valid ),
    .mbox_irq_i                     ( 1'b0                 ),

    // Cluster events (SoC ? Cluster)
    .async_cluster_events_wptr_i    ( async_cluster_events_wptr ),
    .async_cluster_events_rptr_o    ( async_cluster_events_rptr ),
    .async_cluster_events_data_i    ( async_cluster_events_data ),

    // Cluster "slave" port ? SoC "master" wires (SoC?Cluster path)
    .async_data_slave_aw_wptr_i     ( async_soc_master_aw_wptr ),
    .async_data_slave_aw_data_i     ( async_soc_master_aw_data ),
    .async_data_slave_aw_rptr_o     ( async_soc_master_aw_rptr ),
    .async_data_slave_ar_wptr_i     ( async_soc_master_ar_wptr ),
    .async_data_slave_ar_data_i     ( async_soc_master_ar_data ),
    .async_data_slave_ar_rptr_o     ( async_soc_master_ar_rptr ),
    .async_data_slave_w_wptr_i      ( async_soc_master_w_wptr  ),
    .async_data_slave_w_data_i      ( async_soc_master_w_data  ),
    .async_data_slave_w_rptr_o      ( async_soc_master_w_rptr  ),
    .async_data_slave_r_wptr_o      ( async_soc_master_r_wptr  ),
    .async_data_slave_r_data_o      ( async_soc_master_r_data  ),
    .async_data_slave_r_rptr_i      ( async_soc_master_r_rptr  ),
    .async_data_slave_b_wptr_o      ( async_soc_master_b_wptr  ),
    .async_data_slave_b_data_o      ( async_soc_master_b_data  ),
    .async_data_slave_b_rptr_i      ( async_soc_master_b_rptr  ),

    // Cluster "master" port ? SoC "slave" wires (Cluster?SoC path)
    .async_data_master_aw_wptr_o    ( async_soc_slave_aw_wptr  ),
    .async_data_master_aw_data_o    ( async_soc_slave_aw_data  ),
    .async_data_master_aw_rptr_i    ( async_soc_slave_aw_rptr  ),
    .async_data_master_ar_wptr_o    ( async_soc_slave_ar_wptr  ),
    .async_data_master_ar_data_o    ( async_soc_slave_ar_data  ),
    .async_data_master_ar_rptr_i    ( async_soc_slave_ar_rptr  ),
    .async_data_master_w_wptr_o     ( async_soc_slave_w_wptr   ),
    .async_data_master_w_data_o     ( async_soc_slave_w_data   ),
    .async_data_master_w_rptr_i     ( async_soc_slave_w_rptr   ),
    .async_data_master_r_wptr_i     ( async_soc_slave_r_wptr   ),
    .async_data_master_r_data_i     ( async_soc_slave_r_data   ),
    .async_data_master_r_rptr_o     ( async_soc_slave_r_rptr   ),
    .async_data_master_b_wptr_i     ( async_soc_slave_b_wptr   ),
    .async_data_master_b_data_i     ( async_soc_slave_b_data   ),
    .async_data_master_b_rptr_o     ( async_soc_slave_b_rptr   )
  );

  // ========================================================================
  // FPGA Pad Connections
  // ========================================================================

  // JTAG pads
  assign s_jtag_tck   = pad_jtag_tck;
  assign s_jtag_tdi   = pad_jtag_tdi;
  assign s_jtag_tms   = pad_jtag_tms;
  assign s_jtag_trstn = rst_n;

  // UART
  assign s_pad_to_uart[0].rx_i = pad_uart_rx;
  assign pad_uart_tx = s_uart_to_pad[0].tx_o;

  // SPI
  assign s_pad_to_qspi[0].sd0_i = pad_spim_sdio0;
  assign s_pad_to_qspi[0].sd1_i = pad_spim_sdio1;
  assign s_pad_to_qspi[0].sd2_i = pad_spim_sdio2;
  assign s_pad_to_qspi[0].sd3_i = pad_spim_sdio3;

  // I2C
  assign s_pad_to_i2c[0].scl_i = pad_i2c0_scl;
  assign s_pad_to_i2c[0].sda_i = pad_i2c0_sda;

  // GPIO
  assign s_gpio_in = '0;
  assign led0_o = s_gpio_out[0];
  assign led1_o = s_gpio_out[1];
  assign led2_o = s_gpio_out[2];
  assign led3_o = s_gpio_out[3];

  // Tie unused peripheral inputs
  assign s_pad_to_cpi   = '0;
  assign s_pad_to_hyper = '0;
  assign s_pad_to_sdio  = '0;
  assign s_pad_to_i2s   = '0;

endmodule