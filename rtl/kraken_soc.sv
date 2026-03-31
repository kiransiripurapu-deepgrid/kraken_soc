// Kraken SoC Top-Level
// Integration: CV32E40P Cluster + Simple Memory Interface + L2 SRAM

module kraken_soc import axi_pkg::*; #(
    parameter int unsigned AXI_ADDR_WIDTH = 32,
    parameter int unsigned AXI_DATA_WIDTH = 64,
    parameter int unsigned AXI_ID_WIDTH   = 4
) (
    input  logic         clk_i,
    input  logic         rst_ni,
    input  logic         test_en_i,
    
    // Debug outputs to FPGA I/O (prevents optimization)
    output logic [31:0]  core_0_addr_o,
    output logic [31:0]  core_0_data_o,
    output logic         core_0_req_o,
    output logic         mem_valid_o,
    output logic [31:0]  mem_data_o
);

    // Cluster instruction interface signals (1-core cluster)
    logic [0:0]        core_instr_req;
    logic [0:0]        core_instr_gnt;
    logic [0:0][31:0]  core_instr_addr;
    logic [0:0]        core_instr_rvalid;
    logic [0:0][31:0]  core_instr_rdata;

    // Instantiate the Cluster (2 cores with 64KB local TCDM, per architecture freeze)
    pulp_cluster #(
        .NR_CORES            ( 1                 ),
        .AXI_ADDR_WIDTH      ( AXI_ADDR_WIDTH    ),
        .AXI_DATA_WIDTH      ( AXI_DATA_WIDTH    ),
        .AXI_ID_WIDTH        ( AXI_ID_WIDTH      ),
        // 64KB L1/TCDM per core with 64-bit data → 2^13 words
        .TCDM_ADDR_WIDTH     ( 13                ),
        .TCDM_DATA_WIDTH     ( 64                )
    ) i_pulp_cluster (
        .clk_i               ( clk_i             ),
        .rst_ni              ( rst_ni            ),
        .core_instr_req_o    ( core_instr_req    ),
        .core_instr_gnt_i    ( core_instr_gnt    ),
        .core_instr_addr_o   ( core_instr_addr   ),
        .core_instr_rvalid_i ( core_instr_rvalid ),
        .core_instr_rdata_i  ( core_instr_rdata  )
    );

    // L2 Instruction Memory - SRAM (256KB at address 0x80000000, per architecture freeze)
    // Simple memory controller - grant all requests, return data from SRAM
    // 256KB L2 → 64K 32-bit words → 16 address bits
    logic [15:0] mem_addr;
    logic [31:0] mem_rdata;
    
    assign mem_addr           = core_instr_addr[0][17:2];  // 16-bit address for 64K 32-bit words
    assign core_instr_gnt[0]  = core_instr_req[0];
    
    // All cores get the same response from SRAM
    assign core_instr_rvalid[0] = 1'b1;  // Always valid
    
    assign core_instr_rdata[0]  = mem_rdata;

    // L2 Memory (256KB SRAM)
    sram #(
        .DATA_WIDTH ( 32  ),  // 32-bit words for instructions
        .NUM_WORDS  ( 65536 )  // 256KB total
    ) i_l2_mem (
        .clk_i   ( clk_i   ),
        .req_i   ( core_instr_req[0]  ),
        .we_i    ( 1'b0    ),  // Read-only for now
        .addr_i  ( mem_addr ),
        .wdata_i ( 32'h0   ),
        .be_i    ( 4'hf    ),
        .rdata_o ( mem_rdata )
    );

    // Connect internal signals to output ports (prevents optimization)
    assign core_0_addr_o   = core_instr_addr[0];
    assign core_0_data_o   = core_instr_rdata[0];
    assign core_0_req_o    = core_instr_req[0];
    assign mem_valid_o     = core_instr_rvalid[0];
    assign mem_data_o      = mem_rdata;

endmodule