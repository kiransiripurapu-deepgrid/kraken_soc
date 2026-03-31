// Kraken SoC Top-Level
// Integration: CV32E40P Cluster + AXI Backbone + L2 Memory

module kraken_soc import axi_pkg::*; #(
    parameter int unsigned AXI_ADDR_WIDTH = 32,
    parameter int unsigned AXI_DATA_WIDTH = 64,
    parameter int unsigned AXI_ID_WIDTH   = 4
) (
    input  logic clk_i,
    input  logic rst_ni,
    
    // Test mode
    input  logic test_en_i
);

    // 1. Create the AXI Main Highway
    // All high-speed traffic flows through this interface
    AXI_BUS #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH   ),
        .AXI_USER_WIDTH ( 1              )
    ) main_axi_bus();

    // 2. Cluster AXI Interface (connects cluster master to main bus)
    AXI_BUS #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH   ),
        .AXI_USER_WIDTH ( 1              )
    ) cluster_axi_bus();

    // 3. Instantiate the Cluster (Multi-core Processing Element)
    pulp_cluster #(
        .NR_CORES            ( 4                 ),
        .AXI_ADDR_WIDTH      ( AXI_ADDR_WIDTH    ),
        .AXI_DATA_WIDTH      ( AXI_DATA_WIDTH    ),
        .AXI_ID_WIDTH        ( AXI_ID_WIDTH      ),
        .TCDM_ADDR_WIDTH     ( 14                ),
        .TCDM_DATA_WIDTH     ( 64                )
    ) i_pulp_cluster (
        .clk_i   ( clk_i           ),
        .rst_ni  ( rst_ni          ),
        .m_axi   ( cluster_axi_bus ),
        .s_axi   (                 )  // Tie off slave for now
    );

    // 4. AXI Crossbar - Route cluster traffic to memory endpoints
    // For now, simple configuration: cluster master -> L2 SRAM
    axi_xbar #(
        .AXI_USER_WIDTH ( 1           ),
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH ),
        .Cfg            (  '0          )  // Will configure address map
    ) i_axi_xbar (
        .clk_i      ( clk_i          ),
        .rst_ni     ( rst_ni         ),
        .test_en_i  ( test_en_i      ),
        .slv_ports  ( cluster_axi_bus ),
        .mst_ports  ( main_axi_bus   )
    );

    // 5. The L2 Memory (SRAM) - 4KB for instruction/data
    // This is where the cluster fetches initial code
    sram #(
        .ADDR_WIDTH ( 12 ), // 4KB for initial tests
        .DATA_WIDTH ( 64 )
    ) i_l2_mem (
        .clk_i   ( clk_i   ),
        .rst_ni  ( rst_ni  ),
        .req_i   ( 1'b0    ), // AXI crossbar will handle memory access
        .we_i    ( 1'b0    ),
        .addr_i  ( '0      ),
        .wdata_i ( '0      ),
        .rdata_o (         )
    );

endmodule
