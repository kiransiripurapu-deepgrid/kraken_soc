// Stub for riscv_core - never actually instantiated (CORE_TYPE_CL=0 selects CV32)
module riscv_core #(
  parameter int unsigned INSTR_RDATA_WIDTH = 32,
  parameter int unsigned PULP_CLUSTER      = 1,
  parameter int unsigned FPU               = 0,
  parameter int unsigned FP_DIVSQRT        = 0,
  parameter int unsigned SHARED_FP         = 0,
  parameter int unsigned SHARED_FP_DIVSQRT = 0,
  parameter int unsigned N_EXT_PERF_COUNTERS = 1,
  parameter int unsigned Zfinx             = 0,
  parameter int unsigned WAPUTYPE          = 3,
  parameter              DM_HaltAddress    = 32'h1A110800
)(
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        setback_i,
  input  logic        clock_en_i,
  input  logic        test_en_i,
  input  logic        fregfile_disable_i,
  input  logic [31:0] boot_addr_i,
  input  logic [31:0] core_id_i,
  input  logic [5:0]  cluster_id_i,
  output logic        instr_req_o,
  input  logic        instr_gnt_i,
  input  logic        instr_rvalid_i,
  output logic [31:0] instr_addr_o,
  input  logic [INSTR_RDATA_WIDTH-1:0] instr_rdata_i,
  output logic        data_req_o,
  input  logic        data_gnt_i,
  input  logic        data_rvalid_i,
  output logic        data_we_o,
  output logic [3:0]  data_be_o,
  output logic [31:0] data_addr_o,
  output logic [31:0] data_wdata_o,
  input  logic [31:0] data_rdata_i,
  output logic        data_unaligned_o,
  output logic        apu_master_req_o,
  output logic        apu_master_ready_o,
  input  logic        apu_master_gnt_i,
  output logic [WAPUTYPE-1:0]  apu_master_type_o,
  output logic [1:0][31:0]     apu_master_operands_o,
  output logic [0:0]           apu_master_op_o,
  output logic [2:0]           apu_master_flags_o,
  input  logic                 apu_master_valid_i,
  input  logic [31:0]          apu_master_result_i,
  input  logic [4:0]           apu_master_flags_i,
  input  logic        irq_i,
  input  logic [4:0]  irq_id_i,
  output logic        irq_ack_o,
  output logic [4:0]  irq_id_o,
  input  logic        irq_sec_i,
  output logic        sec_lvl_o,
  input  logic        debug_req_i,
  input  logic        debug_resume_i,
  output logic        debug_mode_o,
  input  logic        fetch_enable_i,
  output logic        core_busy_o,
  input  logic [N_EXT_PERF_COUNTERS-1:0] ext_perf_counters_i,
  input  logic        recover_i,
  input  logic [4:0]  regfile_waddr_a_i,
  input  logic [31:0] regfile_wdata_a_i,
  input  logic        regfile_we_a_i,
  input  logic [4:0]  regfile_waddr_b_i,
  input  logic [31:0] regfile_wdata_b_i,
  input  logic        regfile_we_b_i,
  output logic        regfile_we_a_o,
  output logic [4:0]  regfile_waddr_a_o,
  output logic [31:0] regfile_wdata_a_o,
  output logic        regfile_we_b_o,
  output logic [4:0]  regfile_waddr_b_o,
  output logic [31:0] regfile_wdata_b_o,
  output logic [31:0] backup_program_counter_o,
  output logic [31:0] backup_program_counter_if_o,
  output logic        backup_branch_o,
  output logic [31:0] backup_branch_addr_o,
  input  logic        pc_recover_i,
  input  logic [31:0] recovery_program_counter_i,
  input  logic        recovery_branch_i,
  input  logic [31:0] recovery_branch_addr_i,
  output logic [31:0] backup_mstatus_o,
  output logic [31:0] backup_mtvec_o,
  output logic [31:0] backup_mscratch_o,
  output logic [31:0] backup_mepc_o,
  output logic [31:0] backup_mcause_o,
  input  logic [31:0] recovery_mstatus_i,
  input  logic [31:0] recovery_mtvec_i,
  input  logic [31:0] recovery_mscratch_i,
  input  logic [31:0] recovery_mepc_i,
  input  logic [31:0] recovery_mcause_i
);
  // Stub - all outputs tied to zero
  assign instr_req_o    = '0;
  assign instr_addr_o   = '0;
  assign data_req_o     = '0;
  assign data_we_o      = '0;
  assign data_be_o      = '0;
  assign data_addr_o    = '0;
  assign data_wdata_o   = '0;
  assign data_unaligned_o = '0;
  assign apu_master_req_o   = '0;
  assign apu_master_ready_o = '0;
  assign apu_master_type_o  = '0;
  assign apu_master_operands_o = '0;
  assign apu_master_op_o    = '0;
  assign apu_master_flags_o = '0;
  assign irq_ack_o      = '0;
  assign irq_id_o       = '0;
  assign sec_lvl_o      = '0;
  assign debug_mode_o   = '0;
  assign core_busy_o    = '0;
  assign regfile_we_a_o    = '0;
  assign regfile_waddr_a_o = '0;
  assign regfile_wdata_a_o = '0;
  assign regfile_we_b_o    = '0;
  assign regfile_waddr_b_o = '0;
  assign regfile_wdata_b_o = '0;
  assign backup_program_counter_o    = '0;
  assign backup_program_counter_if_o = '0;
  assign backup_branch_o             = '0;
  assign backup_branch_addr_o        = '0;
  assign backup_mstatus_o  = '0;
  assign backup_mtvec_o    = '0;
  assign backup_mscratch_o = '0;
  assign backup_mepc_o     = '0;
  assign backup_mcause_o   = '0;
endmodule
