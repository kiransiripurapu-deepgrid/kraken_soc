// PULP Cluster Top Module - Simplified for Synthesis
// Multi-core Processing Element with Local TCDM

module pulp_cluster import axi_pkg::*; #(
    parameter int unsigned NR_CORES            = 4,
    parameter int unsigned AXI_ADDR_WIDTH      = 32,
    parameter int unsigned AXI_DATA_WIDTH      = 64,
    parameter int unsigned AXI_ID_WIDTH        = 4,
    parameter int unsigned TCDM_ADDR_WIDTH     = 14,
    parameter int unsigned TCDM_DATA_WIDTH     = 64
) (
    input  logic clk_i,
    input  logic rst_ni,
    input  logic test_en_i,
    
    // Instruction Fetch Interface - Direct from cores
    output logic [NR_CORES-1:0]              core_instr_req_o,
    input  logic [NR_CORES-1:0]              core_instr_gnt_i,
    output logic [NR_CORES-1:0] [31:0]       core_instr_addr_o,
    input  logic [NR_CORES-1:0]              core_instr_rvalid_i,
    input  logic [NR_CORES-1:0] [31:0]       core_instr_rdata_i,

    // Data Interface - Direct from cores
    output logic [NR_CORES-1:0]              core_data_req_o,
    input  logic [NR_CORES-1:0]              core_data_gnt_i,
    output logic [NR_CORES-1:0]              core_data_we_o,
    output logic [NR_CORES-1:0] [3:0]        core_data_be_o,
    output logic [NR_CORES-1:0] [31:0]       core_data_addr_o,
    output logic [NR_CORES-1:0] [31:0]       core_data_wdata_o,
    input  logic [NR_CORES-1:0]              core_data_rvalid_i,
    input  logic [NR_CORES-1:0] [31:0]       core_data_rdata_i
);

    // ==================== Core Instantiation ====================
    for (genvar i = 0; i < NR_CORES; i++) begin : gen_cores
        
        // Each core in the cluster
        cv32e40p_core #(
            // Keep the CPU closer to a plain RV32 embedded core for FPGA timing.
            .PULP_XPULP       ( 1'b0 ),
            .PULP_CLUSTER     ( 1'b0 ),
            .FPU              ( 1'b0 ),
            .NUM_MHPMCOUNTERS ( 0    )
        ) i_core (
            .clk_i           ( clk_i   ),
            .rst_ni          ( rst_ni  ),
            .pulp_clock_en_i ( 1'b1   ),
            // Keep fabric clock gates transparently enabled on FPGA. The
            // top-level test port is preserved for Kraken compatibility, but
            // the simplified cluster wrapper should not depend on it for
            // functional execution.
            .scan_cg_en_i    ( 1'b1   ),
            
            // Boot addresses
            .boot_addr_i     ( 32'h00000000  ),
            .mtvec_addr_i    ( 32'h0         ),
            .dm_halt_addr_i  ( 32'h0         ),
            .hart_id_i       ( i            ),
            .dm_exception_addr_i ( 32'h0    ),
            
            // Instruction Fetch Interface (OBI)
            .instr_req_o     ( core_instr_req_o[i]     ),
            .instr_gnt_i     ( core_instr_gnt_i[i]     ),
            .instr_addr_o    ( core_instr_addr_o[i]    ),
            .instr_rvalid_i  ( core_instr_rvalid_i[i]  ),
            .instr_rdata_i   ( core_instr_rdata_i[i]   ),

            // Data Interface
            .data_req_o      ( core_data_req_o[i]    ),
            .data_gnt_i      ( core_data_gnt_i[i]    ),
            .data_we_o       ( core_data_we_o[i]     ),
            .data_be_o       ( core_data_be_o[i]     ),
            .data_addr_o     ( core_data_addr_o[i]   ),
            .data_wdata_o    ( core_data_wdata_o[i]  ),
            .data_rvalid_i   ( core_data_rvalid_i[i] ),
            .data_rdata_i    ( core_data_rdata_i[i]  ),

            // APU interface (unused in this simplified cluster build)
            .apu_req_o       (                 ),
            .apu_gnt_i       ( 1'b0            ),
            .apu_operands_o  (                 ),
            .apu_op_o        (                 ),
            .apu_flags_o     (                 ),
            .apu_rvalid_i    ( 1'b0            ),
            .apu_result_i    ( 32'h0           ),
            .apu_flags_i     ( '0              ),

            // Interrupt Interface
            .irq_i           ( 32'h0  ),
            .irq_ack_o       (   ),
            .irq_id_o        (   ),

            // Debug interface (disabled)
            .debug_req_i       ( 1'b0 ),
            .debug_havereset_o (      ),
            .debug_running_o   (      ),
            .debug_halted_o    (      ),

            // Fetch Enable / Sleep
            .fetch_enable_i  ( 1'b1   ),
            .core_sleep_o    (   )
        );
    end

endmodule
