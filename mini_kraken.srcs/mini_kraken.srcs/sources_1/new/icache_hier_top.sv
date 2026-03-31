module icache_hier_top #(
    parameter int unsigned FETCH_ADDR_WIDTH     = 32,
    parameter int unsigned PRI_FETCH_DATA_WIDTH = 128,
    parameter int unsigned SH_FETCH_DATA_WIDTH  = 128,
    parameter int unsigned NB_CORES             = 2,
    parameter int unsigned SH_NB_BANKS          = 1,
    parameter int unsigned SH_NB_WAYS           = 4,
    parameter int unsigned SH_CACHE_SIZE        = 4096,
    parameter int unsigned SH_CACHE_LINE        = 1,
    parameter int unsigned PRI_NB_WAYS          = 4,
    parameter int unsigned PRI_CACHE_SIZE       = 512,
    parameter int unsigned PRI_CACHE_LINE       = 1,
    parameter int unsigned AXI_ID               = 6,
    parameter int unsigned AXI_ADDR             = 32,
    parameter int unsigned AXI_USER             = 6,
    parameter int unsigned AXI_DATA             = 64,
    parameter              USE_REDUCED_TAG      = "TRUE",
    parameter int unsigned L2_SIZE              = 524288
) (
    input  logic clk,
    input  logic rst_n,
    input  logic test_en_i,

    // Core Instruction Fetch Interface
    input  logic [NB_CORES-1:0]                      fetch_req_i,
    input  logic [NB_CORES-1:0][FETCH_ADDR_WIDTH-1:0] fetch_addr_i,
    output logic [NB_CORES-1:0]                      fetch_gnt_o,
    output logic [NB_CORES-1:0]                      fetch_rvalid_o,
    output logic [NB_CORES-1:0][PRI_FETCH_DATA_WIDTH-1:0] fetch_rdata_o,
    input  logic [NB_CORES-1:0] enable_l1_l15_prefetch_i,

    // AXI Read Address Channel
    output logic [AXI_ID-1:0]   axi_master_arid_o,
    output logic [AXI_ADDR-1:0] axi_master_araddr_o,
    output logic [7:0]          axi_master_arlen_o,
    output logic [2:0]          axi_master_arsize_o,
    output logic [1:0]          axi_master_arburst_o,
    output logic                axi_master_arlock_o,
    output logic [3:0]          axi_master_arcache_o,
    output logic [2:0]          axi_master_arprot_o,
    output logic [3:0]          axi_master_arregion_o,
    output logic [AXI_USER-1:0] axi_master_aruser_o,
    output logic [3:0]          axi_master_arqos_o,
    output logic                axi_master_arvalid_o,
    input  logic                axi_master_arready_i,

    // AXI Read Data Channel
    input  logic [AXI_ID-1:0]   axi_master_rid_i,
    input  logic [AXI_DATA-1:0] axi_master_rdata_i,
    input  logic [1:0]          axi_master_rresp_i,
    input  logic                axi_master_rlast_i,
    input  logic [AXI_USER-1:0] axi_master_ruser_i,
    input  logic                axi_master_rvalid_i,
    output logic                axi_master_rready_o,

    // AXI Write Channels (Tied to 0 as I-Cache is Read-Only)
    output logic [AXI_ID-1:0]   axi_master_awid_o,
    output logic [AXI_ADDR-1:0] axi_master_awaddr_o,
    output logic [7:0]          axi_master_awlen_o,
    output logic [2:0]          axi_master_awsize_o,
    output logic [1:0]          axi_master_awburst_o,
    output logic                axi_master_awlock_o,
    output logic [3:0]          axi_master_awcache_o,
    output logic [2:0]          axi_master_awprot_o,
    output logic [3:0]          axi_master_awregion_o,
    output logic [AXI_USER-1:0] axi_master_awuser_o,
    output logic [3:0]          axi_master_awqos_o,
    output logic                axi_master_awvalid_o,
    input  logic                axi_master_awready_i,

    output logic [AXI_DATA-1:0] axi_master_wdata_o,
    output logic [AXI_DATA/8-1:0] axi_master_wstrb_o,
    output logic                axi_master_wlast_o,
    output logic [AXI_USER-1:0] axi_master_wuser_o,
    output logic                axi_master_wvalid_o,
    input  logic                axi_master_wready_i,

    input  logic [AXI_ID-1:0]   axi_master_bid_i,
    input  logic [1:0]          axi_master_bresp_i,
    input  logic [AXI_USER-1:0] axi_master_buser_i,
    input  logic                axi_master_bvalid_i,
    output logic                axi_master_bready_o,

    // Control Unit Interfaces (unused in this lightweight stub)
    PRI_ICACHE_CTRL_UNIT_BUS IC_ctrl_unit_bus_pri [NB_CORES-1:0],
    SP_ICACHE_CTRL_UNIT_BUS  IC_ctrl_unit_bus_main [SH_NB_BANKS-1:0]
);

    // --- BYPASS LOGIC ---
    assign fetch_gnt_o    = fetch_req_i & {NB_CORES{axi_master_arready_i}};
    assign fetch_rvalid_o = {NB_CORES{axi_master_rvalid_i}};
    assign fetch_rdata_o  = {NB_CORES{axi_master_rdata_i[PRI_FETCH_DATA_WIDTH-1:0]}};

    assign axi_master_araddr_o  = fetch_addr_i[0]; // Simple single-core bypass
    assign axi_master_arvalid_o = fetch_req_i[0];
    assign axi_master_rready_o  = 1'b1;

    // Tie off all other outputs
    assign axi_master_awvalid_o = '0;
    assign axi_master_wvalid_o  = '0;
    assign axi_master_bready_o  = '0;
    assign axi_master_arid_o    = '0;
    assign axi_master_arlen_o   = '0;
    assign axi_master_arsize_o  = '0;
    assign axi_master_arburst_o = '0;
    assign axi_master_arlock_o  = '0;
    assign axi_master_arcache_o = '0;
    assign axi_master_arprot_o  = '0;
    assign axi_master_arregion_o= '0;
    assign axi_master_aruser_o  = '0;
    assign axi_master_arqos_o   = '0;

endmodule
