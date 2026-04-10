`timescale 1ns/1ps

/**
 * Behavioral Testbench for kraken_soc_func
 * 
 * Tests clock, reset, PULP cluster, memory, and CUTIE accelerator
 * integration at the SoC level.
 */

module kraken_soc_func_tb;

  localparam string HEAVY_RULE = "================================================================";
  localparam string LIGHT_RULE = "----------------------------------------------------------------";

  // ═══════════════════════════════════════════════════════════════════════
  // Parameters
  // ═══════════════════════════════════════════════════════════════════════
  
  localparam CLK_PERIOD      = 10ns;   // 100 MHz clock
  localparam RESET_CYCLES    = 5;      // Assert reset for 5 cycles
  localparam time DEFAULT_SIM_TIME = 10us;
  localparam time SNE_SIM_TIME     = 50us;
  localparam time SNE_DMA_SIM_TIME = 80us;
  localparam time DRONET_SIM_TIME  = 50us;
  localparam time CUTIE_DMA_SIM_TIME = 300us;
  localparam time DRONET_STAGE0_SIM_TIME = 550us;
  localparam time DRONET_STAGE2_SIM_TIME = 40us;
  localparam time DRONET_STAGE3_SIM_TIME = 40us;
  localparam time DRONET_STAGE4_SIM_TIME = 40us;
  localparam time DRONET_STAGE5_SIM_TIME = 40us;
  localparam time DRONET_STAGE6_SIM_TIME = 40us;
  localparam time DRONET_STAGE7_SIM_TIME = 40us;
  localparam time DRONET_STAGE8_SIM_TIME = 40us;
  localparam time DRONET_STAGE9_SIM_TIME = 40us;
  localparam time DRONET_STAGE10_SIM_TIME = 40us;
  localparam time DRONET_STAGE11_SIM_TIME = 40us;
  localparam time DRONET_STAGE12_SIM_TIME = 40us;
  localparam time DRONET_STAGE13_SIM_TIME = 40us;
  localparam time DRONET_STAGE14_SIM_TIME = 300us;
  localparam bit STRICT_SINGLE_OUTSTANDING_MODE = 1'b1;
  localparam int DRONET_FULL_ACT_WORD_COUNT = 10000;
  localparam int DRONET_FULL_WEIGHT_WORD_COUNT = 41;
  localparam int DRONET_STAGE0_OUTPUT_WORD_COUNT = 10000;
  localparam string DRONET_FULL_ACT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_full_act_words.hex";
  localparam string DRONET_FULL_WEIGHT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_full_weight_words.hex";
  localparam int DRONET_STAGE2_ACT_WORD_COUNT = 2500;
  localparam int DRONET_STAGE2_WEIGHT_WORD_COUNT = 25;
  localparam int DRONET_STAGE2_OUTPUT_WORD_COUNT = 625;
  localparam int DRONET_STAGE3_ACT_WORD_COUNT = 625;
  localparam int DRONET_STAGE3_WEIGHT_WORD_COUNT = 20;
  localparam int DRONET_STAGE3_OUTPUT_WORD_COUNT = 625;
  localparam int DRONET_STAGE4_ACT_WORD_COUNT = 625;
  localparam int DRONET_STAGE4_WEIGHT_WORD_COUNT = 25;
  localparam int DRONET_STAGE4_OUTPUT_WORD_COUNT = 625;
  localparam int DRONET_STAGE5_ACT_WORD_COUNT = 625;
  localparam int DRONET_STAGE5_WEIGHT_WORD_COUNT = 20;
  localparam int DRONET_STAGE5_OUTPUT_WORD_COUNT = 625;
  localparam int DRONET_STAGE6_ACT_WORD_COUNT = 625;
  localparam int DRONET_STAGE6_WEIGHT_WORD_COUNT = 25;
  localparam int DRONET_STAGE6_OUTPUT_WORD_COUNT = 169;
  localparam int DRONET_STAGE7_ACT_WORD_COUNT = 169;
  localparam int DRONET_STAGE7_WEIGHT_WORD_COUNT = 40;
  localparam int DRONET_STAGE7_OUTPUT_WORD_COUNT = 338;
  localparam int DRONET_STAGE8_ACT_WORD_COUNT = 338;
  localparam int DRONET_STAGE8_WEIGHT_WORD_COUNT = 50;
  localparam int DRONET_STAGE8_OUTPUT_WORD_COUNT = 338;
  localparam int DRONET_STAGE9_ACT_WORD_COUNT = 338;
  localparam int DRONET_STAGE9_WEIGHT_WORD_COUNT = 48;
  localparam int DRONET_STAGE9_OUTPUT_WORD_COUNT = 338;
  localparam int DRONET_STAGE10_ACT_WORD_COUNT = 338;
  localparam int DRONET_STAGE10_WEIGHT_WORD_COUNT = 50;
  localparam int DRONET_STAGE10_OUTPUT_WORD_COUNT = 98;
  localparam int DRONET_STAGE11_ACT_WORD_COUNT = 98;
  localparam int DRONET_STAGE11_WEIGHT_WORD_COUNT = 96;
  localparam int DRONET_STAGE11_OUTPUT_WORD_COUNT = 196;
  localparam int DRONET_STAGE12_ACT_WORD_COUNT = 196;
  localparam int DRONET_STAGE12_WEIGHT_WORD_COUNT = 100;
  localparam int DRONET_STAGE12_OUTPUT_WORD_COUNT = 196;
  localparam int DRONET_STAGE13_ACT_WORD_COUNT = 196;
  localparam int DRONET_STAGE13_WEIGHT_WORD_COUNT = 128;
  localparam int DRONET_STAGE13_OUTPUT_WORD_COUNT = 196;
  localparam int DRONET_STAGE14_ACT_WORD_COUNT = 196;
  localparam int DRONET_STAGE14_WEIGHT_WORD_COUNT = 392;
  localparam string DRONET_STAGE2_ACT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage2_act_words.hex";
  localparam string DRONET_STAGE2_WEIGHT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage2_weight_words.hex";
  localparam string DRONET_STAGE3_ACT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage3_act_words.hex";
  localparam string DRONET_STAGE3_WEIGHT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage3_weight_words.hex";
  localparam string DRONET_STAGE4_ACT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage4_act_words.hex";
  localparam string DRONET_STAGE4_WEIGHT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage4_weight_words.hex";
  localparam string DRONET_STAGE5_ACT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage5_act_words.hex";
  localparam string DRONET_STAGE5_WEIGHT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage5_weight_words.hex";
  localparam string DRONET_STAGE6_ACT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage6_act_words.hex";
  localparam string DRONET_STAGE6_WEIGHT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage6_weight_words.hex";
  localparam string DRONET_STAGE7_ACT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage7_act_words.hex";
  localparam string DRONET_STAGE7_WEIGHT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage7_weight_words.hex";
  localparam string DRONET_STAGE8_ACT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage8_act_words.hex";
  localparam string DRONET_STAGE8_WEIGHT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage8_weight_words.hex";
  localparam string DRONET_STAGE9_ACT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage9_act_words.hex";
  localparam string DRONET_STAGE9_WEIGHT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage9_weight_words.hex";
  localparam string DRONET_STAGE10_ACT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage10_act_words.hex";
  localparam string DRONET_STAGE10_WEIGHT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage10_weight_words.hex";
  localparam string DRONET_STAGE11_ACT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage11_act_words.hex";
  localparam string DRONET_STAGE11_WEIGHT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage11_weight_words.hex";
  localparam string DRONET_STAGE12_ACT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage12_act_words.hex";
  localparam string DRONET_STAGE12_WEIGHT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage12_weight_words.hex";
  localparam string DRONET_STAGE13_ACT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage13_act_words.hex";
  localparam string DRONET_STAGE13_WEIGHT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage13_weight_words.hex";
  localparam string DRONET_STAGE14_ACT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage14_act_words.hex";
  localparam string DRONET_STAGE14_WEIGHT_HEX =
    "sw/dronet_v3/generated/cutie_dronet_stage14_weight_words.hex";
  localparam string DRONET_STAGE4_OUTPUT_BANK0_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage4_output_bank0_words.hex";
  localparam string DRONET_STAGE4_OUTPUT_BANK1_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage4_output_bank1_words.hex";
  localparam string DRONET_STAGE5_OUTPUT_BANK0_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage5_output_bank0_words.hex";
  localparam string DRONET_STAGE5_OUTPUT_BANK1_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage5_output_bank1_words.hex";
  localparam string DRONET_STAGE6_OUTPUT_BANK0_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage6_output_bank0_words.hex";
  localparam string DRONET_STAGE6_OUTPUT_BANK1_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage6_output_bank1_words.hex";
  localparam string DRONET_STAGE7_OUTPUT_BANK0_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage7_output_bank0_words.hex";
  localparam string DRONET_STAGE7_OUTPUT_BANK1_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage7_output_bank1_words.hex";
  localparam string DRONET_STAGE8_OUTPUT_BANK0_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage8_output_bank0_words.hex";
  localparam string DRONET_STAGE8_OUTPUT_BANK1_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage8_output_bank1_words.hex";
  localparam string DRONET_STAGE9_OUTPUT_BANK0_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage9_output_bank0_words.hex";
  localparam string DRONET_STAGE9_OUTPUT_BANK1_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage9_output_bank1_words.hex";
  localparam string DRONET_STAGE10_OUTPUT_BANK0_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage10_output_bank0_words.hex";
  localparam string DRONET_STAGE10_OUTPUT_BANK1_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage10_output_bank1_words.hex";
  localparam string DRONET_STAGE11_OUTPUT_BANK0_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage11_output_bank0_words.hex";
  localparam string DRONET_STAGE11_OUTPUT_BANK1_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage11_output_bank1_words.hex";
  localparam string DRONET_STAGE12_OUTPUT_BANK0_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage12_output_bank0_words.hex";
  localparam string DRONET_STAGE12_OUTPUT_BANK1_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage12_output_bank1_words.hex";
  localparam string DRONET_STAGE13_OUTPUT_BANK0_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage13_output_bank0_words.hex";
  localparam string DRONET_STAGE13_OUTPUT_BANK1_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage13_output_bank1_words.hex";
  localparam string DRONET_STAGE3_OUTPUT_BANK0_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage3_output_bank0_words.hex";
  localparam string DRONET_STAGE3_OUTPUT_BANK1_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage3_output_bank1_words.hex";
  localparam string DRONET_STAGE2_OUTPUT_BANK0_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage2_output_bank0_words.hex";
  localparam string DRONET_STAGE2_OUTPUT_BANK1_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage2_output_bank1_words.hex";
  localparam string DRONET_STAGE0_OUTPUT_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage0_output_words.hex";
  localparam string DRONET_STAGE0_OUTPUT_BANK0_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage0_output_bank0_words.hex";
  localparam string DRONET_STAGE0_OUTPUT_BANK1_HEX =
    "sw/dronet_v3/generated/layer_payloads/stage0_output_bank1_words.hex";

  // ═══════════════════════════════════════════════════════════════════════
  // Testbench Signals
  // ═══════════════════════════════════════════════════════════════════════
  
  logic          clk_i;
  logic          rst_ni;
  
  // PULP Cluster Outputs
  logic [31:0]   core_0_addr_o;
  logic [31:0]   core_0_data_o;
  logic          core_0_req_o;
  
  // Memory Interface
  logic          mem_valid_o;
  logic [31:0]   mem_data_o;
  
  // CUTIE Accelerator Outputs
  logic          cutie_busy_o;
  logic [1:0]    cutie_evt_o;
  logic [31:0]   demo_status_o;
  logic [31:0]   demo_result_o;
  logic          sne_activity_o;

  // Force dependency inclusion for Vivado sim compile-order pruning.
  logic          force_fifo_clk;
  logic          force_fifo_rst_n;
  logic          force_fifo_flush;
  logic          force_fifo_testmode;
  logic          force_fifo_full;
  logic          force_fifo_empty;
  logic [1:0]    force_fifo_usage;
  logic [7:0]    force_fifo_data_i;
  logic          force_fifo_push;
  logic [7:0]    force_fifo_data_o;
  logic          force_fifo_pop;

  fifo_v3 #(
    .FALL_THROUGH ( 1'b0 ),
    .DATA_WIDTH   ( 8    ),
    .DEPTH        ( 4    )
  ) i_force_fifo_dep (
    .clk_i      ( force_fifo_clk      ),
    .rst_ni     ( force_fifo_rst_n    ),
    .flush_i    ( force_fifo_flush    ),
    .testmode_i ( force_fifo_testmode ),
    .full_o     ( force_fifo_full     ),
    .empty_o    ( force_fifo_empty    ),
    .usage_o    ( force_fifo_usage    ),
    .data_i     ( force_fifo_data_i   ),
    .push_i     ( force_fifo_push     ),
    .data_o     ( force_fifo_data_o   ),
    .pop_i      ( force_fifo_pop      )
  );
  
  // Internal signal monitoring (optional)
  int            reset_cycle_count = 0;
  int            cycles_after_reset = 0;
  string         mem_init_file;
  string         project_root;
  logic          dronet_debug_mode = 1'b0;
  logic [31:0]   dronet_full_act_words [0:DRONET_FULL_ACT_WORD_COUNT-1];
  logic [31:0]   dronet_full_weight_words [0:DRONET_FULL_WEIGHT_WORD_COUNT-1];
  logic [31:0]   preload_act_addr_q;
  logic [31:0]   preload_act_lo_q;
  logic [31:0]   preload_act_hi_q;
  logic [31:0]   preload_wgt_addr_q;
  logic [31:0]   preload_wgt_lo_q;
  logic [31:0]   preload_wgt_hi_q;
  logic [31:0]   dronet_stage2_act_words [0:DRONET_STAGE2_ACT_WORD_COUNT-1];
  logic [31:0]   dronet_stage2_weight_words [0:DRONET_STAGE2_WEIGHT_WORD_COUNT-1];
  logic [31:0]   dronet_stage3_act_words [0:DRONET_STAGE3_ACT_WORD_COUNT-1];
  logic [31:0]   dronet_stage3_weight_words [0:DRONET_STAGE3_WEIGHT_WORD_COUNT-1];
  logic [31:0]   dronet_stage4_act_words [0:DRONET_STAGE4_ACT_WORD_COUNT-1];
  logic [31:0]   dronet_stage4_weight_words [0:DRONET_STAGE4_WEIGHT_WORD_COUNT-1];
  logic [31:0]   dronet_stage5_act_words [0:DRONET_STAGE5_ACT_WORD_COUNT-1];
  logic [31:0]   dronet_stage5_weight_words [0:DRONET_STAGE5_WEIGHT_WORD_COUNT-1];
  logic [31:0]   dronet_stage6_act_words [0:DRONET_STAGE6_ACT_WORD_COUNT-1];
  logic [31:0]   dronet_stage6_weight_words [0:DRONET_STAGE6_WEIGHT_WORD_COUNT-1];
  logic [31:0]   dronet_stage7_act_words [0:DRONET_STAGE7_ACT_WORD_COUNT-1];
  logic [31:0]   dronet_stage7_weight_words [0:DRONET_STAGE7_WEIGHT_WORD_COUNT-1];
  logic [31:0]   dronet_stage8_act_words [0:DRONET_STAGE8_ACT_WORD_COUNT-1];
  logic [31:0]   dronet_stage8_weight_words [0:DRONET_STAGE8_WEIGHT_WORD_COUNT-1];
  logic [31:0]   dronet_stage9_act_words [0:DRONET_STAGE9_ACT_WORD_COUNT-1];
  logic [31:0]   dronet_stage9_weight_words [0:DRONET_STAGE9_WEIGHT_WORD_COUNT-1];
  logic [31:0]   dronet_stage10_act_words [0:DRONET_STAGE10_ACT_WORD_COUNT-1];
  logic [31:0]   dronet_stage10_weight_words [0:DRONET_STAGE10_WEIGHT_WORD_COUNT-1];
  logic [31:0]   dronet_stage11_act_words [0:DRONET_STAGE11_ACT_WORD_COUNT-1];
  logic [31:0]   dronet_stage11_weight_words [0:DRONET_STAGE11_WEIGHT_WORD_COUNT-1];
  logic [31:0]   dronet_stage12_act_words [0:DRONET_STAGE12_ACT_WORD_COUNT-1];
  logic [31:0]   dronet_stage12_weight_words [0:DRONET_STAGE12_WEIGHT_WORD_COUNT-1];
  logic [31:0]   dronet_stage13_act_words [0:DRONET_STAGE13_ACT_WORD_COUNT-1];
  logic [31:0]   dronet_stage13_weight_words [0:DRONET_STAGE13_WEIGHT_WORD_COUNT-1];
  logic [31:0]   dronet_stage14_act_words [0:DRONET_STAGE14_ACT_WORD_COUNT-1];
  logic [31:0]   dronet_stage14_weight_words [0:DRONET_STAGE14_WEIGHT_WORD_COUNT-1];
  logic [31:0]   dump_act_addr_q;
  logic [31:0]   dump_act_bankset_q;
  logic [63:0]   dump_act_word_q;
  logic          stage0_output_dump_done_q = 1'b0;
  logic          stage2_output_dump_done_q = 1'b0;
  logic          stage3_output_dump_done_q = 1'b0;
  logic          stage4_output_dump_done_q = 1'b0;
  logic          stage5_output_dump_done_q = 1'b0;
  logic          stage6_output_dump_done_q = 1'b0;
  logic          stage7_output_dump_done_q = 1'b0;
  logic          stage8_output_dump_done_q = 1'b0;
  logic          stage9_output_dump_done_q = 1'b0;
  logic          stage10_output_dump_done_q = 1'b0;
  logic          stage11_output_dump_done_q = 1'b0;
  logic          stage12_output_dump_done_q = 1'b0;
  logic          stage13_output_dump_done_q = 1'b0;

  function automatic string normalize_path(input string path);
    string result;
    for (int i = 0; i < path.len(); i++) begin
      byte ch = path[i];
      if (ch == "\\")
        result = {result, "/"};
      else
        result = {result, ch};
    end
    return result;
  endfunction

  function automatic logic path_has_suffix(input string path, input string suffix);
    string norm_path;
    string norm_suffix;
    int path_len;
    int suffix_len;
    norm_path = normalize_path(path);
    norm_suffix = normalize_path(suffix);
    path_len = norm_path.len();
    suffix_len = norm_suffix.len();
    if (path_len < suffix_len)
      return 1'b0;
    return (norm_path.substr(path_len - suffix_len, path_len - 1) == norm_suffix);
  endfunction

  function automatic string derive_project_root(input string path);
    string norm_path;
    norm_path = normalize_path(path);
    for (int i = 0; i <= (norm_path.len() - 4); i++) begin
      if (norm_path.substr(i, i + 3) == "/sw/")
        return norm_path.substr(0, i - 1);
    end
    return ".";
  endfunction

  function automatic string repo_path(input string rel_path);
    string norm_rel;
    norm_rel = normalize_path(rel_path);
    if ((project_root == "") || (project_root == "."))
      return norm_rel;
    return {normalize_path(project_root), "/", norm_rel};
  endfunction

  function automatic logic is_dronet_stage0_preload_mem(input string path);
    return path_has_suffix(path, "/sw/dronet_v3/dronet_v3_stage0_preload.mem");
  endfunction

  function automatic logic is_dronet_full_preload_mem(input string path);
    return path_has_suffix(path, "/sw/dronet_v3/dronet_v3_full_preload.mem");
  endfunction

  function automatic logic is_dronet_stage2_preload_mem(input string path);
    return path_has_suffix(path, "/sw/dronet_v3/dronet_v3_stage2_preload.mem");
  endfunction

  function automatic logic is_dronet_stage3_preload_mem(input string path);
    return path_has_suffix(path, "/sw/dronet_v3/dronet_v3_stage3_preload.mem");
  endfunction

  function automatic logic is_dronet_stage4_preload_mem(input string path);
    return path_has_suffix(path, "/sw/dronet_v3/dronet_v3_stage4_preload.mem");
  endfunction

  function automatic logic is_dronet_stage5_preload_mem(input string path);
    return path_has_suffix(path, "/sw/dronet_v3/dronet_v3_stage5_preload.mem");
  endfunction

  function automatic logic is_dronet_stage6_preload_mem(input string path);
    return path_has_suffix(path, "/sw/dronet_v3/dronet_v3_stage6_preload.mem");
  endfunction

  function automatic logic is_dronet_stage7_preload_mem(input string path);
    return path_has_suffix(path, "/sw/dronet_v3/dronet_v3_stage7_preload.mem");
  endfunction

  function automatic logic is_dronet_stage8_preload_mem(input string path);
    return path_has_suffix(path, "/sw/dronet_v3/dronet_v3_stage8_preload.mem");
  endfunction

  function automatic logic is_dronet_stage9_preload_mem(input string path);
    return path_has_suffix(path, "/sw/dronet_v3/dronet_v3_stage9_preload.mem");
  endfunction

  function automatic logic is_dronet_stage10_preload_mem(input string path);
    return path_has_suffix(path, "/sw/dronet_v3/dronet_v3_stage10_preload.mem");
  endfunction

  function automatic logic is_dronet_stage11_preload_mem(input string path);
    return path_has_suffix(path, "/sw/dronet_v3/dronet_v3_stage11_preload.mem");
  endfunction

  function automatic logic is_dronet_stage12_preload_mem(input string path);
    return path_has_suffix(path, "/sw/dronet_v3/dronet_v3_stage12_preload.mem");
  endfunction

  function automatic logic is_dronet_stage13_preload_mem(input string path);
    return path_has_suffix(path, "/sw/dronet_v3/dronet_v3_stage13_preload.mem");
  endfunction

  function automatic logic is_dronet_stage14_software_mem(input string path);
    return path_has_suffix(path, "/sw/dronet_v3/dronet_v3_stage14_software.mem");
  endfunction

  function automatic logic is_dronet_stage14_hardware_preload_mem(input string path);
    return (path_has_suffix(path, "/sw/dronet_v3/dronet_v3_stage14_hardware_preload.mem") ||
            path_has_suffix(path, "/sw/dronet_v3/dronet_v3_full_hardware.mem"));
  endfunction

  function automatic logic is_dronet_stage0_like_mem(input string path);
    return (path_has_suffix(path, "/sw/dronet_v3/dronet_v3_stage0.mem") ||
            is_dronet_stage0_preload_mem(path));
  endfunction

  task automatic cutie_force_write_act_pair(
      input int unsigned addr,
      input logic [31:0] lo,
      input logic [31:0] hi
    );
      begin
        if ($bits(DUT.i_cutie.act_rdata_q) <= 32) begin
          preload_act_addr_q = addr << 1;
          preload_act_lo_q = lo;
          preload_act_hi_q = 32'd0;
          @(negedge clk_i);
          force DUT.i_cutie.reg_act_bankset = 32'd0;
          force DUT.i_cutie.reg_act_addr = preload_act_addr_q;
          force DUT.i_cutie.reg_act_wdata_lo = preload_act_lo_q;
          force DUT.i_cutie.reg_act_wdata_hi = preload_act_hi_q;
          force DUT.i_cutie.pulse_act_wr = 1'b1;
          @(posedge clk_i);
          release DUT.i_cutie.pulse_act_wr;
          release DUT.i_cutie.reg_act_wdata_hi;
          release DUT.i_cutie.reg_act_wdata_lo;
          release DUT.i_cutie.reg_act_addr;
          release DUT.i_cutie.reg_act_bankset;

          preload_act_addr_q = (addr << 1) + 1;
          preload_act_lo_q = hi;
          preload_act_hi_q = 32'd0;
          @(negedge clk_i);
          force DUT.i_cutie.reg_act_bankset = 32'd0;
          force DUT.i_cutie.reg_act_addr = preload_act_addr_q;
          force DUT.i_cutie.reg_act_wdata_lo = preload_act_lo_q;
          force DUT.i_cutie.reg_act_wdata_hi = preload_act_hi_q;
          force DUT.i_cutie.pulse_act_wr = 1'b1;
          @(posedge clk_i);
          release DUT.i_cutie.pulse_act_wr;
          release DUT.i_cutie.reg_act_wdata_hi;
          release DUT.i_cutie.reg_act_wdata_lo;
          release DUT.i_cutie.reg_act_addr;
          release DUT.i_cutie.reg_act_bankset;
        end else begin
          preload_act_addr_q = addr;
          preload_act_lo_q = lo;
          preload_act_hi_q = hi;
          @(negedge clk_i);
          force DUT.i_cutie.reg_act_bankset = 32'd0;
          force DUT.i_cutie.reg_act_addr = preload_act_addr_q;
          force DUT.i_cutie.reg_act_wdata_lo = preload_act_lo_q;
          force DUT.i_cutie.reg_act_wdata_hi = preload_act_hi_q;
          force DUT.i_cutie.pulse_act_wr = 1'b1;
          @(posedge clk_i);
          release DUT.i_cutie.pulse_act_wr;
          release DUT.i_cutie.reg_act_wdata_hi;
          release DUT.i_cutie.reg_act_wdata_lo;
          release DUT.i_cutie.reg_act_addr;
          release DUT.i_cutie.reg_act_bankset;
        end
      end
    endtask

  task automatic cutie_force_write_weight_pair(
      input int unsigned addr,
      input logic [31:0] lo,
      input logic [31:0] hi
    );
      begin
        if ($bits(DUT.i_cutie.wgt_rdata_q) <= 32) begin
          preload_wgt_addr_q = addr << 1;
          preload_wgt_lo_q = lo;
          preload_wgt_hi_q = 32'd0;
          @(negedge clk_i);
          force DUT.i_cutie.reg_wgt_bank = 32'd0;
          force DUT.i_cutie.reg_wgt_addr = preload_wgt_addr_q;
          force DUT.i_cutie.reg_wgt_wdata_lo = preload_wgt_lo_q;
          force DUT.i_cutie.reg_wgt_wdata_hi = preload_wgt_hi_q;
          force DUT.i_cutie.pulse_wgt_wr = 1'b1;
          @(posedge clk_i);
          release DUT.i_cutie.pulse_wgt_wr;
          release DUT.i_cutie.reg_wgt_wdata_hi;
          release DUT.i_cutie.reg_wgt_wdata_lo;
          release DUT.i_cutie.reg_wgt_addr;
          release DUT.i_cutie.reg_wgt_bank;

          preload_wgt_addr_q = (addr << 1) + 1;
          preload_wgt_lo_q = hi;
          preload_wgt_hi_q = 32'd0;
          @(negedge clk_i);
          force DUT.i_cutie.reg_wgt_bank = 32'd0;
          force DUT.i_cutie.reg_wgt_addr = preload_wgt_addr_q;
          force DUT.i_cutie.reg_wgt_wdata_lo = preload_wgt_lo_q;
          force DUT.i_cutie.reg_wgt_wdata_hi = preload_wgt_hi_q;
          force DUT.i_cutie.pulse_wgt_wr = 1'b1;
          @(posedge clk_i);
          release DUT.i_cutie.pulse_wgt_wr;
          release DUT.i_cutie.reg_wgt_wdata_hi;
          release DUT.i_cutie.reg_wgt_wdata_lo;
          release DUT.i_cutie.reg_wgt_addr;
          release DUT.i_cutie.reg_wgt_bank;
        end else begin
          preload_wgt_addr_q = addr;
          preload_wgt_lo_q = lo;
          preload_wgt_hi_q = hi;
          @(negedge clk_i);
          force DUT.i_cutie.reg_wgt_bank = 32'd0;
          force DUT.i_cutie.reg_wgt_addr = preload_wgt_addr_q;
          force DUT.i_cutie.reg_wgt_wdata_lo = preload_wgt_lo_q;
          force DUT.i_cutie.reg_wgt_wdata_hi = preload_wgt_hi_q;
          force DUT.i_cutie.pulse_wgt_wr = 1'b1;
          @(posedge clk_i);
          release DUT.i_cutie.pulse_wgt_wr;
          release DUT.i_cutie.reg_wgt_wdata_hi;
          release DUT.i_cutie.reg_wgt_wdata_lo;
          release DUT.i_cutie.reg_wgt_addr;
          release DUT.i_cutie.reg_wgt_bank;
        end
      end
    endtask

  task automatic preload_cutie_exported_stage0_payload;
    logic [31:0] hi_word;
    begin
      $display("@%0tns: Preloading CUTIE memories for exported stage0/full payload", $time);
      $readmemh(repo_path(DRONET_FULL_ACT_HEX), dronet_full_act_words);
      $readmemh(repo_path(DRONET_FULL_WEIGHT_HEX), dronet_full_weight_words);

      for (int i = 0; i < DRONET_FULL_ACT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_FULL_ACT_WORD_COUNT) ? dronet_full_act_words[i + 1] : 32'd0;
        cutie_force_write_act_pair(i >> 1, dronet_full_act_words[i], hi_word);
      end

      for (int i = 0; i < DRONET_FULL_WEIGHT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_FULL_WEIGHT_WORD_COUNT) ? dronet_full_weight_words[i + 1] : 32'd0;
        cutie_force_write_weight_pair(i >> 1, dronet_full_weight_words[i], hi_word);
      end

      $display("@%0tns: CUTIE preload complete", $time);
    end
  endtask

  task automatic preload_cutie_stage2_payload;
    logic [31:0] hi_word;
    begin
      $display("@%0tns: Preloading CUTIE memories for exported stage2 payload", $time);
      $readmemh(repo_path(DRONET_STAGE2_ACT_HEX), dronet_stage2_act_words);
      $readmemh(repo_path(DRONET_STAGE2_WEIGHT_HEX), dronet_stage2_weight_words);

      for (int i = 0; i < DRONET_STAGE2_ACT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE2_ACT_WORD_COUNT) ? dronet_stage2_act_words[i + 1] : 32'd0;
        cutie_force_write_act_pair(i >> 1, dronet_stage2_act_words[i], hi_word);
      end

      for (int i = 0; i < DRONET_STAGE2_WEIGHT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE2_WEIGHT_WORD_COUNT) ? dronet_stage2_weight_words[i + 1] : 32'd0;
        cutie_force_write_weight_pair(i >> 1, dronet_stage2_weight_words[i], hi_word);
      end

      $display("@%0tns: CUTIE stage2 preload complete", $time);
    end
  endtask

  task automatic preload_cutie_stage3_payload;
    logic [31:0] hi_word;
    begin
      $display("@%0tns: Preloading CUTIE memories for exported stage3 payload", $time);
      $readmemh(repo_path(DRONET_STAGE3_ACT_HEX), dronet_stage3_act_words);
      $readmemh(repo_path(DRONET_STAGE3_WEIGHT_HEX), dronet_stage3_weight_words);

      for (int i = 0; i < DRONET_STAGE3_ACT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE3_ACT_WORD_COUNT) ? dronet_stage3_act_words[i + 1] : 32'd0;
        cutie_force_write_act_pair(i >> 1, dronet_stage3_act_words[i], hi_word);
      end

      for (int i = 0; i < DRONET_STAGE3_WEIGHT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE3_WEIGHT_WORD_COUNT) ? dronet_stage3_weight_words[i + 1] : 32'd0;
        cutie_force_write_weight_pair(i >> 1, dronet_stage3_weight_words[i], hi_word);
      end

      $display("@%0tns: CUTIE stage3 preload complete", $time);
    end
  endtask

  task automatic preload_cutie_stage4_payload;
    logic [31:0] hi_word;
    begin
      $display("@%0tns: Preloading CUTIE memories for exported stage4 payload", $time);
      $readmemh(repo_path(DRONET_STAGE4_ACT_HEX), dronet_stage4_act_words);
      $readmemh(repo_path(DRONET_STAGE4_WEIGHT_HEX), dronet_stage4_weight_words);

      for (int i = 0; i < DRONET_STAGE4_ACT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE4_ACT_WORD_COUNT) ? dronet_stage4_act_words[i + 1] : 32'd0;
        cutie_force_write_act_pair(i >> 1, dronet_stage4_act_words[i], hi_word);
      end

      for (int i = 0; i < DRONET_STAGE4_WEIGHT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE4_WEIGHT_WORD_COUNT) ? dronet_stage4_weight_words[i + 1] : 32'd0;
        cutie_force_write_weight_pair(i >> 1, dronet_stage4_weight_words[i], hi_word);
      end

      $display("@%0tns: CUTIE stage4 preload complete", $time);
    end
  endtask

  task automatic preload_cutie_stage5_payload;
    logic [31:0] hi_word;
    begin
      $display("@%0tns: Preloading CUTIE memories for exported stage5 payload", $time);
      $readmemh(repo_path(DRONET_STAGE5_ACT_HEX), dronet_stage5_act_words);
      $readmemh(repo_path(DRONET_STAGE5_WEIGHT_HEX), dronet_stage5_weight_words);

      for (int i = 0; i < DRONET_STAGE5_ACT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE5_ACT_WORD_COUNT) ? dronet_stage5_act_words[i + 1] : 32'd0;
        cutie_force_write_act_pair(i >> 1, dronet_stage5_act_words[i], hi_word);
      end

      for (int i = 0; i < DRONET_STAGE5_WEIGHT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE5_WEIGHT_WORD_COUNT) ? dronet_stage5_weight_words[i + 1] : 32'd0;
        cutie_force_write_weight_pair(i >> 1, dronet_stage5_weight_words[i], hi_word);
      end

      $display("@%0tns: CUTIE stage5 preload complete", $time);
    end
  endtask

  task automatic preload_cutie_stage6_payload;
    logic [31:0] hi_word;
    begin
      $display("@%0tns: Preloading CUTIE memories for exported stage6 payload", $time);
      $readmemh(repo_path(DRONET_STAGE6_ACT_HEX), dronet_stage6_act_words);
      $readmemh(repo_path(DRONET_STAGE6_WEIGHT_HEX), dronet_stage6_weight_words);

      for (int i = 0; i < DRONET_STAGE6_ACT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE6_ACT_WORD_COUNT) ? dronet_stage6_act_words[i + 1] : 32'd0;
        cutie_force_write_act_pair(i >> 1, dronet_stage6_act_words[i], hi_word);
      end

      for (int i = 0; i < DRONET_STAGE6_WEIGHT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE6_WEIGHT_WORD_COUNT) ? dronet_stage6_weight_words[i + 1] : 32'd0;
        cutie_force_write_weight_pair(i >> 1, dronet_stage6_weight_words[i], hi_word);
      end

      $display("@%0tns: CUTIE stage6 preload complete", $time);
    end
  endtask

  task automatic preload_cutie_stage7_payload;
    logic [31:0] hi_word;
    begin
      $display("@%0tns: Preloading CUTIE memories for exported stage7 payload", $time);
      $readmemh(repo_path(DRONET_STAGE7_ACT_HEX), dronet_stage7_act_words);
      $readmemh(repo_path(DRONET_STAGE7_WEIGHT_HEX), dronet_stage7_weight_words);
      for (int i = 0; i < DRONET_STAGE7_ACT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE7_ACT_WORD_COUNT) ? dronet_stage7_act_words[i + 1] : 32'd0;
        cutie_force_write_act_pair(i >> 1, dronet_stage7_act_words[i], hi_word);
      end
      for (int i = 0; i < DRONET_STAGE7_WEIGHT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE7_WEIGHT_WORD_COUNT) ? dronet_stage7_weight_words[i + 1] : 32'd0;
        cutie_force_write_weight_pair(i >> 1, dronet_stage7_weight_words[i], hi_word);
      end
      $display("@%0tns: CUTIE stage7 preload complete", $time);
    end
  endtask

  task automatic preload_cutie_stage8_payload;
    logic [31:0] hi_word;
    begin
      $display("@%0tns: Preloading CUTIE memories for exported stage8 payload", $time);
      $readmemh(repo_path(DRONET_STAGE8_ACT_HEX), dronet_stage8_act_words);
      $readmemh(repo_path(DRONET_STAGE8_WEIGHT_HEX), dronet_stage8_weight_words);
      for (int i = 0; i < DRONET_STAGE8_ACT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE8_ACT_WORD_COUNT) ? dronet_stage8_act_words[i + 1] : 32'd0;
        cutie_force_write_act_pair(i >> 1, dronet_stage8_act_words[i], hi_word);
      end
      for (int i = 0; i < DRONET_STAGE8_WEIGHT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE8_WEIGHT_WORD_COUNT) ? dronet_stage8_weight_words[i + 1] : 32'd0;
        cutie_force_write_weight_pair(i >> 1, dronet_stage8_weight_words[i], hi_word);
      end
      $display("@%0tns: CUTIE stage8 preload complete", $time);
    end
  endtask

  task automatic preload_cutie_stage9_payload;
    logic [31:0] hi_word;
    begin
      $display("@%0tns: Preloading CUTIE memories for exported stage9 payload", $time);
      $readmemh(repo_path(DRONET_STAGE9_ACT_HEX), dronet_stage9_act_words);
      $readmemh(repo_path(DRONET_STAGE9_WEIGHT_HEX), dronet_stage9_weight_words);
      for (int i = 0; i < DRONET_STAGE9_ACT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE9_ACT_WORD_COUNT) ? dronet_stage9_act_words[i + 1] : 32'd0;
        cutie_force_write_act_pair(i >> 1, dronet_stage9_act_words[i], hi_word);
      end
      for (int i = 0; i < DRONET_STAGE9_WEIGHT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE9_WEIGHT_WORD_COUNT) ? dronet_stage9_weight_words[i + 1] : 32'd0;
        cutie_force_write_weight_pair(i >> 1, dronet_stage9_weight_words[i], hi_word);
      end
      $display("@%0tns: CUTIE stage9 preload complete", $time);
    end
  endtask

  task automatic preload_cutie_stage10_payload;
    logic [31:0] hi_word;
    begin
      $display("@%0tns: Preloading CUTIE memories for exported stage10 payload", $time);
      $readmemh(repo_path(DRONET_STAGE10_ACT_HEX), dronet_stage10_act_words);
      $readmemh(repo_path(DRONET_STAGE10_WEIGHT_HEX), dronet_stage10_weight_words);
      for (int i = 0; i < DRONET_STAGE10_ACT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE10_ACT_WORD_COUNT) ? dronet_stage10_act_words[i + 1] : 32'd0;
        cutie_force_write_act_pair(i >> 1, dronet_stage10_act_words[i], hi_word);
      end
      for (int i = 0; i < DRONET_STAGE10_WEIGHT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE10_WEIGHT_WORD_COUNT) ? dronet_stage10_weight_words[i + 1] : 32'd0;
        cutie_force_write_weight_pair(i >> 1, dronet_stage10_weight_words[i], hi_word);
      end
      $display("@%0tns: CUTIE stage10 preload complete", $time);
    end
  endtask

  task automatic preload_cutie_stage11_payload;
    logic [31:0] hi_word;
    begin
      $display("@%0tns: Preloading CUTIE memories for exported stage11 payload", $time);
      $readmemh(repo_path(DRONET_STAGE11_ACT_HEX), dronet_stage11_act_words);
      $readmemh(repo_path(DRONET_STAGE11_WEIGHT_HEX), dronet_stage11_weight_words);
      for (int i = 0; i < DRONET_STAGE11_ACT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE11_ACT_WORD_COUNT) ? dronet_stage11_act_words[i + 1] : 32'd0;
        cutie_force_write_act_pair(i >> 1, dronet_stage11_act_words[i], hi_word);
      end
      for (int i = 0; i < DRONET_STAGE11_WEIGHT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE11_WEIGHT_WORD_COUNT) ? dronet_stage11_weight_words[i + 1] : 32'd0;
        cutie_force_write_weight_pair(i >> 1, dronet_stage11_weight_words[i], hi_word);
      end
      $display("@%0tns: CUTIE stage11 preload complete", $time);
    end
  endtask

  task automatic preload_cutie_stage12_payload;
    logic [31:0] hi_word;
    begin
      $display("@%0tns: Preloading CUTIE memories for exported stage12 payload", $time);
      $readmemh(repo_path(DRONET_STAGE12_ACT_HEX), dronet_stage12_act_words);
      $readmemh(repo_path(DRONET_STAGE12_WEIGHT_HEX), dronet_stage12_weight_words);
      for (int i = 0; i < DRONET_STAGE12_ACT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE12_ACT_WORD_COUNT) ? dronet_stage12_act_words[i + 1] : 32'd0;
        cutie_force_write_act_pair(i >> 1, dronet_stage12_act_words[i], hi_word);
      end
      for (int i = 0; i < DRONET_STAGE12_WEIGHT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE12_WEIGHT_WORD_COUNT) ? dronet_stage12_weight_words[i + 1] : 32'd0;
        cutie_force_write_weight_pair(i >> 1, dronet_stage12_weight_words[i], hi_word);
      end
      $display("@%0tns: CUTIE stage12 preload complete", $time);
    end
  endtask

  task automatic preload_cutie_stage13_payload;
    logic [31:0] hi_word;
    begin
      $display("@%0tns: Preloading CUTIE memories for exported stage13 payload", $time);
      $readmemh(repo_path(DRONET_STAGE13_ACT_HEX), dronet_stage13_act_words);
      $readmemh(repo_path(DRONET_STAGE13_WEIGHT_HEX), dronet_stage13_weight_words);
      for (int i = 0; i < DRONET_STAGE13_ACT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE13_ACT_WORD_COUNT) ? dronet_stage13_act_words[i + 1] : 32'd0;
        cutie_force_write_act_pair(i >> 1, dronet_stage13_act_words[i], hi_word);
      end
      for (int i = 0; i < DRONET_STAGE13_WEIGHT_WORD_COUNT; i += 2) begin
        hi_word = (i + 1 < DRONET_STAGE13_WEIGHT_WORD_COUNT) ? dronet_stage13_weight_words[i + 1] : 32'd0;
        cutie_force_write_weight_pair(i >> 1, dronet_stage13_weight_words[i], hi_word);
      end
      $display("@%0tns: CUTIE stage13 preload complete", $time);
    end
  endtask

  task automatic preload_cutie_stage14_payload;
      begin
        $display("@%0tns: Preloading CUTIE memories for exported stage14 payload", $time);
        $readmemh(repo_path(DRONET_STAGE14_ACT_HEX), dronet_stage14_act_words);
        $readmemh(repo_path(DRONET_STAGE14_WEIGHT_HEX), dronet_stage14_weight_words);
        for (int i = 0; i < DRONET_STAGE14_ACT_WORD_COUNT; i++) begin
          DUT.i_cutie.linear_act_mem[i] = dronet_stage14_act_words[i];
        end
        for (int i = 0; i < DRONET_STAGE14_WEIGHT_WORD_COUNT; i++) begin
          DUT.i_cutie.linear_wgt_mem[i] = dronet_stage14_weight_words[i];
        end
        $display("@%0tns: CUTIE stage14 preload complete", $time);
      end
    endtask

  task automatic cutie_force_read_act_pair(
      input int unsigned bankset,
      input int unsigned addr,
      output logic [63:0] word_pair
  );
    logic [63:0] padded_word;
    int unsigned wait_cycles;
    begin
        if ($bits(DUT.i_cutie.act_rdata_q) <= 32) begin
          word_pair = 64'd0;

          dump_act_bankset_q = bankset;
          dump_act_addr_q = addr << 1;
          @(negedge clk_i);
          force DUT.i_cutie.reg_act_bankset = dump_act_bankset_q;
          force DUT.i_cutie.reg_act_addr = dump_act_addr_q;
          force DUT.i_cutie.pulse_act_rd = 1'b1;
          @(posedge clk_i);
          release DUT.i_cutie.pulse_act_rd;
          release DUT.i_cutie.reg_act_addr;
          release DUT.i_cutie.reg_act_bankset;
          wait_cycles = 0;
          while ((DUT.i_cutie.act_rvalid_q !== 1'b1) && (wait_cycles < 8)) begin
            @(posedge clk_i);
            wait_cycles++;
          end
          word_pair[31:0] = DUT.i_cutie.act_rdata_q[31:0];

          dump_act_bankset_q = bankset;
          dump_act_addr_q = (addr << 1) + 1;
          @(negedge clk_i);
          force DUT.i_cutie.reg_act_bankset = dump_act_bankset_q;
          force DUT.i_cutie.reg_act_addr = dump_act_addr_q;
          force DUT.i_cutie.pulse_act_rd = 1'b1;
          @(posedge clk_i);
          release DUT.i_cutie.pulse_act_rd;
          release DUT.i_cutie.reg_act_addr;
          release DUT.i_cutie.reg_act_bankset;
          wait_cycles = 0;
          while ((DUT.i_cutie.act_rvalid_q !== 1'b1) && (wait_cycles < 8)) begin
            @(posedge clk_i);
            wait_cycles++;
          end
          word_pair[63:32] = DUT.i_cutie.act_rdata_q[31:0];
        end else begin
          dump_act_bankset_q = bankset;
          dump_act_addr_q = addr;
          word_pair = 64'd0;
          @(negedge clk_i);
          force DUT.i_cutie.reg_act_bankset = dump_act_bankset_q;
          force DUT.i_cutie.reg_act_addr = dump_act_addr_q;
          force DUT.i_cutie.pulse_act_rd = 1'b1;
          @(posedge clk_i);
          release DUT.i_cutie.pulse_act_rd;
          release DUT.i_cutie.reg_act_addr;
          release DUT.i_cutie.reg_act_bankset;

          wait_cycles = 0;
          while ((DUT.i_cutie.act_rvalid_q !== 1'b1) && (wait_cycles < 8)) begin
            @(posedge clk_i);
            wait_cycles++;
          end

          padded_word = 64'd0;
          padded_word[$bits(DUT.i_cutie.act_rdata_q)-1:0] = DUT.i_cutie.act_rdata_q;
          word_pair = padded_word;
        end
      end
    endtask

  task automatic dump_cutie_stage0_output_payload;
    int fd;
    logic [63:0] word_pair;
    string dump_path;
    int unsigned bankset;
    begin
      for (bankset = 0; bankset < 2; bankset++) begin
        dump_path = (bankset == 0) ? DRONET_STAGE0_OUTPUT_BANK0_HEX : DRONET_STAGE0_OUTPUT_BANK1_HEX;
        $display("@%0tns: Dumping stage0 CUTIE output words from bankset %0d to %s", $time, bankset, dump_path);
        fd = $fopen(repo_path(dump_path), "w");
        if (fd == 0) begin
          $display("@%0tns: ERROR: failed to open %s for stage0 dump", $time, dump_path);
        end else begin
          for (int i = 0; i < DRONET_STAGE0_OUTPUT_WORD_COUNT; i += 2) begin
            cutie_force_read_act_pair(bankset, i >> 1, word_pair);
            $fdisplay(fd, "%08x", word_pair[31:0]);
            if ((i + 1) < DRONET_STAGE0_OUTPUT_WORD_COUNT)
              $fdisplay(fd, "%08x", word_pair[63:32]);
          end
          $fclose(fd);
        end
      end
      $display("@%0tns: Stage0 CUTIE output dump complete", $time);
    end
  endtask

  task automatic dump_cutie_stage2_output_payload;
    int fd;
    logic [63:0] word_pair;
    string dump_path;
    int unsigned bankset;
    begin
      for (bankset = 0; bankset < 2; bankset++) begin
        dump_path = (bankset == 0) ? DRONET_STAGE2_OUTPUT_BANK0_HEX : DRONET_STAGE2_OUTPUT_BANK1_HEX;
        $display("@%0tns: Dumping stage2 CUTIE output words from bankset %0d to %s", $time, bankset, dump_path);
        fd = $fopen(repo_path(dump_path), "w");
        if (fd == 0) begin
          $display("@%0tns: ERROR: failed to open %s for stage2 dump", $time, dump_path);
        end else begin
          for (int i = 0; i < DRONET_STAGE2_OUTPUT_WORD_COUNT; i += 2) begin
            cutie_force_read_act_pair(bankset, i >> 1, word_pair);
            $fdisplay(fd, "%08x", word_pair[31:0]);
            if ((i + 1) < DRONET_STAGE2_OUTPUT_WORD_COUNT)
              $fdisplay(fd, "%08x", word_pair[63:32]);
          end
          $fclose(fd);
        end
      end
      $display("@%0tns: Stage2 CUTIE output dump complete", $time);
    end
  endtask

  task automatic dump_cutie_stage3_output_payload;
    int fd;
    logic [63:0] word_pair;
    string dump_path;
    int unsigned bankset;
    begin
      for (bankset = 0; bankset < 2; bankset++) begin
        dump_path = (bankset == 0) ? DRONET_STAGE3_OUTPUT_BANK0_HEX : DRONET_STAGE3_OUTPUT_BANK1_HEX;
        $display("@%0tns: Dumping stage3 CUTIE output words from bankset %0d to %s", $time, bankset, dump_path);
        fd = $fopen(repo_path(dump_path), "w");
        if (fd == 0) begin
          $display("@%0tns: ERROR: failed to open %s for stage3 dump", $time, dump_path);
        end else begin
          for (int i = 0; i < DRONET_STAGE3_OUTPUT_WORD_COUNT; i += 2) begin
            cutie_force_read_act_pair(bankset, i >> 1, word_pair);
            $fdisplay(fd, "%08x", word_pair[31:0]);
            if ((i + 1) < DRONET_STAGE3_OUTPUT_WORD_COUNT)
              $fdisplay(fd, "%08x", word_pair[63:32]);
          end
          $fclose(fd);
        end
      end
      $display("@%0tns: Stage3 CUTIE output dump complete", $time);
    end
  endtask

  task automatic dump_cutie_stage4_output_payload;
    int fd;
    logic [63:0] word_pair;
    string dump_path;
    int unsigned bankset;
    begin
      for (bankset = 0; bankset < 2; bankset++) begin
        dump_path = (bankset == 0) ? DRONET_STAGE4_OUTPUT_BANK0_HEX : DRONET_STAGE4_OUTPUT_BANK1_HEX;
        $display("@%0tns: Dumping stage4 CUTIE output words from bankset %0d to %s", $time, bankset, dump_path);
        fd = $fopen(repo_path(dump_path), "w");
        if (fd == 0) begin
          $display("@%0tns: ERROR: failed to open %s for stage4 dump", $time, dump_path);
        end else begin
          for (int i = 0; i < DRONET_STAGE4_OUTPUT_WORD_COUNT; i += 2) begin
            cutie_force_read_act_pair(bankset, i >> 1, word_pair);
            $fdisplay(fd, "%08x", word_pair[31:0]);
            if ((i + 1) < DRONET_STAGE4_OUTPUT_WORD_COUNT)
              $fdisplay(fd, "%08x", word_pair[63:32]);
          end
          $fclose(fd);
        end
      end
      $display("@%0tns: Stage4 CUTIE output dump complete", $time);
    end
  endtask

  task automatic dump_cutie_stage5_output_payload;
    int fd;
    logic [63:0] word_pair;
    string dump_path;
    int unsigned bankset;
    begin
      for (bankset = 0; bankset < 2; bankset++) begin
        dump_path = (bankset == 0) ? DRONET_STAGE5_OUTPUT_BANK0_HEX : DRONET_STAGE5_OUTPUT_BANK1_HEX;
        $display("@%0tns: Dumping stage5 CUTIE output words from bankset %0d to %s", $time, bankset, dump_path);
        fd = $fopen(repo_path(dump_path), "w");
        if (fd == 0) begin
          $display("@%0tns: ERROR: failed to open %s for stage5 dump", $time, dump_path);
        end else begin
          for (int i = 0; i < DRONET_STAGE5_OUTPUT_WORD_COUNT; i += 2) begin
            cutie_force_read_act_pair(bankset, i >> 1, word_pair);
            $fdisplay(fd, "%08x", word_pair[31:0]);
            if ((i + 1) < DRONET_STAGE5_OUTPUT_WORD_COUNT)
              $fdisplay(fd, "%08x", word_pair[63:32]);
          end
          $fclose(fd);
        end
      end
      $display("@%0tns: Stage5 CUTIE output dump complete", $time);
    end
  endtask

  task automatic dump_cutie_stage6_output_payload;
    int fd;
    logic [63:0] word_pair;
    string dump_path;
    int unsigned bankset;
    begin
      for (bankset = 0; bankset < 2; bankset++) begin
        dump_path = (bankset == 0) ? DRONET_STAGE6_OUTPUT_BANK0_HEX : DRONET_STAGE6_OUTPUT_BANK1_HEX;
        $display("@%0tns: Dumping stage6 CUTIE output words from bankset %0d to %s", $time, bankset, dump_path);
        fd = $fopen(repo_path(dump_path), "w");
        if (fd == 0) begin
          $display("@%0tns: ERROR: failed to open %s for stage6 dump", $time, dump_path);
        end else begin
          for (int i = 0; i < DRONET_STAGE6_OUTPUT_WORD_COUNT; i += 2) begin
            cutie_force_read_act_pair(bankset, i >> 1, word_pair);
            $fdisplay(fd, "%08x", word_pair[31:0]);
            if ((i + 1) < DRONET_STAGE6_OUTPUT_WORD_COUNT)
              $fdisplay(fd, "%08x", word_pair[63:32]);
          end
          $fclose(fd);
        end
      end
      $display("@%0tns: Stage6 CUTIE output dump complete", $time);
    end
  endtask

  task automatic dump_cutie_stage7_output_payload;
    int fd;
    logic [63:0] word_pair;
    string dump_path;
    int unsigned bankset;
    begin
      for (bankset = 0; bankset < 2; bankset++) begin
        dump_path = (bankset == 0) ? DRONET_STAGE7_OUTPUT_BANK0_HEX : DRONET_STAGE7_OUTPUT_BANK1_HEX;
        $display("@%0tns: Dumping stage7 CUTIE output words from bankset %0d to %s", $time, bankset, dump_path);
        fd = $fopen(repo_path(dump_path), "w");
        if (fd != 0) begin
          for (int i = 0; i < DRONET_STAGE7_OUTPUT_WORD_COUNT; i += 2) begin
            cutie_force_read_act_pair(bankset, i >> 1, word_pair);
            $fdisplay(fd, "%08x", word_pair[31:0]);
            if ((i + 1) < DRONET_STAGE7_OUTPUT_WORD_COUNT)
              $fdisplay(fd, "%08x", word_pair[63:32]);
          end
          $fclose(fd);
        end
      end
      $display("@%0tns: Stage7 CUTIE output dump complete", $time);
    end
  endtask

  task automatic dump_cutie_stage8_output_payload;
    int fd;
    logic [63:0] word_pair;
    string dump_path;
    int unsigned bankset;
    begin
      for (bankset = 0; bankset < 2; bankset++) begin
        dump_path = (bankset == 0) ? DRONET_STAGE8_OUTPUT_BANK0_HEX : DRONET_STAGE8_OUTPUT_BANK1_HEX;
        $display("@%0tns: Dumping stage8 CUTIE output words from bankset %0d to %s", $time, bankset, dump_path);
        fd = $fopen(repo_path(dump_path), "w");
        if (fd != 0) begin
          for (int i = 0; i < DRONET_STAGE8_OUTPUT_WORD_COUNT; i += 2) begin
            cutie_force_read_act_pair(bankset, i >> 1, word_pair);
            $fdisplay(fd, "%08x", word_pair[31:0]);
            if ((i + 1) < DRONET_STAGE8_OUTPUT_WORD_COUNT)
              $fdisplay(fd, "%08x", word_pair[63:32]);
          end
          $fclose(fd);
        end
      end
      $display("@%0tns: Stage8 CUTIE output dump complete", $time);
    end
  endtask

  task automatic dump_cutie_stage9_output_payload;
    int fd;
    logic [63:0] word_pair;
    string dump_path;
    int unsigned bankset;
    begin
      for (bankset = 0; bankset < 2; bankset++) begin
        dump_path = (bankset == 0) ? DRONET_STAGE9_OUTPUT_BANK0_HEX : DRONET_STAGE9_OUTPUT_BANK1_HEX;
        $display("@%0tns: Dumping stage9 CUTIE output words from bankset %0d to %s", $time, bankset, dump_path);
        fd = $fopen(repo_path(dump_path), "w");
        if (fd != 0) begin
          for (int i = 0; i < DRONET_STAGE9_OUTPUT_WORD_COUNT; i += 2) begin
            cutie_force_read_act_pair(bankset, i >> 1, word_pair);
            $fdisplay(fd, "%08x", word_pair[31:0]);
            if ((i + 1) < DRONET_STAGE9_OUTPUT_WORD_COUNT)
              $fdisplay(fd, "%08x", word_pair[63:32]);
          end
          $fclose(fd);
        end
      end
      $display("@%0tns: Stage9 CUTIE output dump complete", $time);
    end
  endtask

  task automatic dump_cutie_stage10_output_payload;
    int fd;
    logic [63:0] word_pair;
    string dump_path;
    int unsigned bankset;
    begin
      for (bankset = 0; bankset < 2; bankset++) begin
        dump_path = (bankset == 0) ? DRONET_STAGE10_OUTPUT_BANK0_HEX : DRONET_STAGE10_OUTPUT_BANK1_HEX;
        $display("@%0tns: Dumping stage10 CUTIE output words from bankset %0d to %s", $time, bankset, dump_path);
        fd = $fopen(repo_path(dump_path), "w");
        if (fd != 0) begin
          for (int i = 0; i < DRONET_STAGE10_OUTPUT_WORD_COUNT; i += 2) begin
            cutie_force_read_act_pair(bankset, i >> 1, word_pair);
            $fdisplay(fd, "%08x", word_pair[31:0]);
            if ((i + 1) < DRONET_STAGE10_OUTPUT_WORD_COUNT)
              $fdisplay(fd, "%08x", word_pair[63:32]);
          end
          $fclose(fd);
        end
      end
      $display("@%0tns: Stage10 CUTIE output dump complete", $time);
    end
  endtask

  task automatic dump_cutie_stage11_output_payload;
    int fd;
    logic [63:0] word_pair;
    string dump_path;
    int unsigned bankset;
    begin
      for (bankset = 0; bankset < 2; bankset++) begin
        dump_path = (bankset == 0) ? DRONET_STAGE11_OUTPUT_BANK0_HEX : DRONET_STAGE11_OUTPUT_BANK1_HEX;
        $display("@%0tns: Dumping stage11 CUTIE output words from bankset %0d to %s", $time, bankset, dump_path);
        fd = $fopen(repo_path(dump_path), "w");
        if (fd != 0) begin
          for (int i = 0; i < DRONET_STAGE11_OUTPUT_WORD_COUNT; i += 2) begin
            cutie_force_read_act_pair(bankset, i >> 1, word_pair);
            $fdisplay(fd, "%08x", word_pair[31:0]);
            if ((i + 1) < DRONET_STAGE11_OUTPUT_WORD_COUNT)
              $fdisplay(fd, "%08x", word_pair[63:32]);
          end
          $fclose(fd);
        end
      end
      $display("@%0tns: Stage11 CUTIE output dump complete", $time);
    end
  endtask

  task automatic dump_cutie_stage12_output_payload;
    int fd;
    logic [63:0] word_pair;
    string dump_path;
    int unsigned bankset;
    begin
      for (bankset = 0; bankset < 2; bankset++) begin
        dump_path = (bankset == 0) ? DRONET_STAGE12_OUTPUT_BANK0_HEX : DRONET_STAGE12_OUTPUT_BANK1_HEX;
        $display("@%0tns: Dumping stage12 CUTIE output words from bankset %0d to %s", $time, bankset, dump_path);
        fd = $fopen(repo_path(dump_path), "w");
        if (fd != 0) begin
          for (int i = 0; i < DRONET_STAGE12_OUTPUT_WORD_COUNT; i += 2) begin
            cutie_force_read_act_pair(bankset, i >> 1, word_pair);
            $fdisplay(fd, "%08x", word_pair[31:0]);
            if ((i + 1) < DRONET_STAGE12_OUTPUT_WORD_COUNT)
              $fdisplay(fd, "%08x", word_pair[63:32]);
          end
          $fclose(fd);
        end
      end
      $display("@%0tns: Stage12 CUTIE output dump complete", $time);
    end
  endtask

  task automatic dump_cutie_stage13_output_payload;
    int fd;
    logic [63:0] word_pair;
    string dump_path;
    int unsigned bankset;
    begin
      for (bankset = 0; bankset < 2; bankset++) begin
        dump_path = (bankset == 0) ? DRONET_STAGE13_OUTPUT_BANK0_HEX : DRONET_STAGE13_OUTPUT_BANK1_HEX;
        $display("@%0tns: Dumping stage13 CUTIE output words from bankset %0d to %s", $time, bankset, dump_path);
        fd = $fopen(repo_path(dump_path), "w");
        if (fd != 0) begin
          for (int i = 0; i < DRONET_STAGE13_OUTPUT_WORD_COUNT; i += 2) begin
            cutie_force_read_act_pair(bankset, i >> 1, word_pair);
            $fdisplay(fd, "%08x", word_pair[31:0]);
            if ((i + 1) < DRONET_STAGE13_OUTPUT_WORD_COUNT)
              $fdisplay(fd, "%08x", word_pair[63:32]);
          end
          $fclose(fd);
        end
      end
      $display("@%0tns: Stage13 CUTIE output dump complete", $time);
    end
  endtask

  // ═══════════════════════════════════════════════════════════════════════
  // DUT Instantiation
  // ═══════════════════════════════════════════════════════════════════════
  
  kraken_soc_func #(
    .AXI_ADDR_WIDTH             ( 32                             ),
    .AXI_DATA_WIDTH             ( 64                             ),
    .AXI_ID_WIDTH               ( 4                              ),
    .STRICT_SINGLE_OUTSTANDING  ( STRICT_SINGLE_OUTSTANDING_MODE )
  ) DUT (
    .clk_i         ( clk_i         ),
    .rst_ni        ( rst_ni        ),
    .test_en_i     ( 1'b0          ),
    .core_0_addr_o ( core_0_addr_o ),
    .core_0_data_o ( core_0_data_o ),
    .core_0_req_o  ( core_0_req_o  ),
    .mem_valid_o   ( mem_valid_o   ),
    .mem_data_o    ( mem_data_o    ),
    .cutie_busy_o  ( cutie_busy_o  ),
    .cutie_evt_o   ( cutie_evt_o   ),
    .demo_status_o ( demo_status_o ),
    .demo_result_o ( demo_result_o ),
    .sne_activity_o( sne_activity_o )
  );

  // ═══════════════════════════════════════════════════════════════════════
  // Clock Generation (100 MHz)
  // ═══════════════════════════════════════════════════════════════════════
  
  initial begin
    clk_i = 1'b0;
    force_fifo_clk = 1'b0;
    force_fifo_rst_n = 1'b0;
    force_fifo_flush = 1'b0;
    force_fifo_testmode = 1'b0;
    force_fifo_data_i = 8'h00;
    force_fifo_push = 1'b0;
    force_fifo_pop = 1'b0;
    forever #(CLK_PERIOD/2) clk_i = ~clk_i;
  end

  initial begin
    if (!$value$plusargs("PROJECT_ROOT=%s", project_root)) begin
      project_root = "";
    end
    if (!$value$plusargs("MEM_INIT_FILE=%s", mem_init_file)) begin
      mem_init_file = repo_path("sw/basic/hello.mem");
    end
    if ((project_root == "") && (mem_init_file != "")) begin
      project_root = derive_project_root(mem_init_file);
    end
    dronet_debug_mode = ((path_has_suffix(mem_init_file, "/sw/multimodal_smoke/multimodal_smoke.mem")) ||
                         (path_has_suffix(mem_init_file, "/sw/dronet_v3/dronet_v3_driver.mem")) ||
                         (path_has_suffix(mem_init_file, "/sw/dronet_v3/dronet_v3_smoke.mem")) ||
                         (path_has_suffix(mem_init_file, "/sw/dronet_v3/dronet_v3_stage0.mem")) ||
                         is_dronet_stage0_preload_mem(mem_init_file) ||
                         is_dronet_stage2_preload_mem(mem_init_file) ||
                         is_dronet_stage3_preload_mem(mem_init_file) ||
                         is_dronet_stage4_preload_mem(mem_init_file) ||
                         is_dronet_stage5_preload_mem(mem_init_file) ||
                         is_dronet_stage6_preload_mem(mem_init_file) ||
                         is_dronet_stage7_preload_mem(mem_init_file) ||
                         is_dronet_stage8_preload_mem(mem_init_file) ||
                         is_dronet_stage9_preload_mem(mem_init_file) ||
                         is_dronet_stage10_preload_mem(mem_init_file) ||
                         is_dronet_stage11_preload_mem(mem_init_file) ||
                         is_dronet_stage12_preload_mem(mem_init_file) ||
                         is_dronet_stage13_preload_mem(mem_init_file) ||
                         is_dronet_stage14_hardware_preload_mem(mem_init_file) ||
                         is_dronet_stage14_software_mem(mem_init_file) ||
                         (path_has_suffix(mem_init_file, "/sw/dronet_v3/dronet_v3_partial.mem")) ||
                         (path_has_suffix(mem_init_file, "/sw/dronet_v3/dronet_v3_full.mem")) ||
                         is_dronet_full_preload_mem(mem_init_file));
    if (mem_init_file != "") begin
      $display("@%0tns: Preloading firmware image from %s", $time, mem_init_file);
      $readmemh(mem_init_file, DUT.i_l2_mem.ram);
      $display("@%0tns: L2[0]=%h L2[1]=%h L2[2]=%h L2[3]=%h",
               $time,
               DUT.i_l2_mem.ram[0],
               DUT.i_l2_mem.ram[1],
               DUT.i_l2_mem.ram[2],
               DUT.i_l2_mem.ram[3]);
    end else begin
      $display("@%0tns: No MEM_INIT_FILE plusarg provided; SRAM remains uninitialized", $time);
    end
  end

  // ═══════════════════════════════════════════════════════════════════════
  // Reset Generation (Active-Low)
  // ═══════════════════════════════════════════════════════════════════════
  
  initial begin
    // Assert reset at t=0
    rst_ni = 1'b0;

    if (is_dronet_stage0_preload_mem(mem_init_file) || is_dronet_full_preload_mem(mem_init_file))
      preload_cutie_exported_stage0_payload();
    else if (is_dronet_stage2_preload_mem(mem_init_file))
      preload_cutie_stage2_payload();
    else if (is_dronet_stage3_preload_mem(mem_init_file))
      preload_cutie_stage3_payload();
    else if (is_dronet_stage4_preload_mem(mem_init_file))
      preload_cutie_stage4_payload();
    else if (is_dronet_stage5_preload_mem(mem_init_file))
      preload_cutie_stage5_payload();
    else if (is_dronet_stage6_preload_mem(mem_init_file))
      preload_cutie_stage6_payload();
    else if (is_dronet_stage7_preload_mem(mem_init_file))
      preload_cutie_stage7_payload();
    else if (is_dronet_stage8_preload_mem(mem_init_file))
      preload_cutie_stage8_payload();
    else if (is_dronet_stage9_preload_mem(mem_init_file))
      preload_cutie_stage9_payload();
    else if (is_dronet_stage10_preload_mem(mem_init_file))
      preload_cutie_stage10_payload();
    else if (is_dronet_stage11_preload_mem(mem_init_file))
      preload_cutie_stage11_payload();
    else if (is_dronet_stage12_preload_mem(mem_init_file))
      preload_cutie_stage12_payload();
    else if (is_dronet_stage13_preload_mem(mem_init_file))
      preload_cutie_stage13_payload();
    else if (is_dronet_stage14_hardware_preload_mem(mem_init_file) ||
             path_has_suffix(mem_init_file, "/sw/multimodal_smoke/multimodal_smoke.mem"))
      preload_cutie_stage14_payload();

    // Wait for RESET_CYCLES clock edges
    repeat(RESET_CYCLES) @(posedge clk_i);
    
    // Release reset
    rst_ni = 1'b1;
    $display("@%0tns: Reset released", $time);
  end

  // ═══════════════════════════════════════════════════════════════════════
  // Reset Cycle Counter (for debugging)
  // ═══════════════════════════════════════════════════════════════════════
  
  always @(posedge clk_i) begin
    if (!rst_ni) begin
      reset_cycle_count <= reset_cycle_count + 1;
      cycles_after_reset <= 0;
    end else begin
      cycles_after_reset <= cycles_after_reset + 1;
    end
  end

  // ═══════════════════════════════════════════════════════════════════════
  // Monitoring and Assertions
  // ═══════════════════════════════════════════════════════════════════════
  
  // Monitor key signals
  initial begin
    @(posedge rst_ni);  // Wait for reset to be released
    $display("═══════════════════════════════════════════════════════════════");
    $display("kraken_soc_func Behavioral Simulation Started");
    $display("───────────────────────────────────────────────────────────────");
    $display("Clock Period: %0tns (100 MHz)", CLK_PERIOD);
    $display("Reset Cycles: %0d", RESET_CYCLES);
    $display("Strict Single-Outstanding Mode: %0d", STRICT_SINGLE_OUTSTANDING_MODE);
    $display("═══════════════════════════════════════════════════════════════");
  end
  
  // Display signals every 1000 cycles after reset
  always @(posedge clk_i) begin
    if (rst_ni && (cycles_after_reset % 1000 == 0)) begin
      $display("@%0tns | Cycle: %0d | addr_o=%h | data_o=%h | req_o=%b | mem_valid=%b | busy=%b | evt=%b",
        $time, cycles_after_reset, 
        core_0_addr_o, core_0_data_o, core_0_req_o, 
        mem_valid_o, cutie_busy_o, cutie_evt_o);
    end
  end

  // ═══════════════════════════════════════════════════════════════════════
  // Signal Validity Checks (Post-Reset)
  // ═══════════════════════════════════════════════════════════════════════
  
  logic has_addr_activity = 1'b0;
  logic has_req_activity = 1'b0;
  logic has_mem_activity = 1'b0;
  logic has_cutie_activity = 1'b0;
  logic has_firmware_fetch = 1'b0;
  logic has_mmio_activity = 1'b0;
  logic saw_scratch0_cafebabe = 1'b0;
  logic saw_scratch1_0badf00d = 1'b0;
  logic saw_uart_a_write = 1'b0;
  logic saw_uart_b_write = 1'b0;
  logic saw_uart_c_write = 1'b0;
  logic saw_uart_s_write = 1'b0;
  logic saw_dronet_scratch0 = 1'b0;
  logic saw_dronet_scratch1 = 1'b0;
  logic saw_dronet_stage0_scratch1 = 1'b0;
  logic saw_dronet_stage2_scratch1 = 1'b0;
  logic saw_dronet_stage3_scratch1 = 1'b0;
  logic saw_dronet_stage4_scratch1 = 1'b0;
  logic saw_dronet_stage5_scratch1 = 1'b0;
  logic saw_dronet_stage6_scratch1 = 1'b0;
  logic saw_dronet_stage7_scratch1 = 1'b0;
  logic saw_dronet_stage8_scratch1 = 1'b0;
  logic saw_dronet_stage9_scratch1 = 1'b0;
  logic saw_dronet_stage10_scratch1 = 1'b0;
  logic saw_dronet_stage11_scratch1 = 1'b0;
  logic saw_dronet_stage12_scratch1 = 1'b0;
  logic saw_dronet_stage13_scratch1 = 1'b0;
  logic saw_dronet_stage14_scratch1 = 1'b0;
  logic saw_dronet_stage0_signature = 1'b0;
  logic saw_dronet_stage14_signature = 1'b0;
  logic saw_dronet_partial_scratch1 = 1'b0;
  logic saw_dronet_full_scratch1 = 1'b0;
  logic saw_uart_d_write = 1'b0;
  logic saw_uart_p_write = 1'b0;
  logic saw_uart_t_write = 1'b0;
  logic saw_uart_f_write = 1'b0;
  logic saw_cutie_cfg_write = 1'b0;
  logic saw_cutie_start_write = 1'b0;
  logic saw_cutie_done_evt = 1'b0;
  logic saw_cutie_timeout_evt = 1'b0;
  logic saw_firmware_done_status = 1'b0;
  logic saw_sne_smoke_start = 1'b0;
  logic saw_sne_smoke_pass = 1'b0;
  logic saw_sne_smoke_readback_fail = 1'b0;
  logic saw_sne_smoke_fail = 1'b0;
  logic saw_sne_dma_start = 1'b0;
  logic saw_sne_dma_pass = 1'b0;
  logic saw_sne_dma_fail = 1'b0;
  logic saw_multimodal_boot = 1'b0;
  logic saw_multimodal_stage2 = 1'b0;
  logic saw_multimodal_pass = 1'b0;
  logic saw_uart_m_write = 1'b0;
  logic prev_cutie_busy_q = 1'b0;
  logic [31:0] last_addr_q = 32'h0;
  int data_trace_count = 0;
  int instr_req_no_gnt_streak = 0;
  int instr_req_no_gnt_max = 0;
  int data_req_no_gnt_streak = 0;
  int data_req_no_gnt_max = 0;
  int instr_outstanding = 0;
  int data_outstanding = 0;
  int instr_outstanding_max = 0;
  int data_outstanding_max = 0;
  int instr_resp_wo_req = 0;
  int data_resp_wo_req = 0;
  int instr_outstanding_overflow = 0;
  int data_outstanding_overflow = 0;
  int instr_trace_count = 0;
  logic saw_main_region_fetch = 1'b0;
  
  always @(posedge clk_i) begin
    if (rst_ni && cycles_after_reset > 10) begin  // After transient settling
      // Check for address activity (must be defined and non-zero)
      if (core_0_addr_o != 32'h0) 
        has_addr_activity = 1'b1;
      // Check for request activity
      if (core_0_req_o) 
        has_req_activity = 1'b1;
      // Check for memory activity
      if (mem_valid_o || mem_data_o != 32'h0) 
        has_mem_activity = 1'b1;
      // Check for CUTIE activity. Treat either busy or event pulses as valid
      // accelerator activity so the wrapper can prove liveness even if the
      // busy window is short.
      if (cutie_busy_o || (cutie_evt_o != 2'b00))
        has_cutie_activity = 1'b1;
      // Firmware fetch heuristic: request active and fetch address changes
      if (core_0_req_o && (core_0_addr_o != last_addr_q))
        has_firmware_fetch = 1'b1;
      if ((DUT.mmio_scratch0_q != 32'd0) || (DUT.mmio_scratch1_q != 32'd0) || (DUT.mmio_gpio_q != 32'd0))
        has_mmio_activity = 1'b1;
    end
  end

  always @(posedge clk_i) begin
    if (!rst_ni)
      last_addr_q <= 32'h0;
    else
      last_addr_q <= core_0_addr_o;
  end

  always @(posedge clk_i) begin
    if (rst_ni && DUT.core_data_req[0] && DUT.core_data_gnt[0] && DUT.core_data_we[0] &&
        (DUT.data_is_mmio === 1'b1) &&
        !$isunknown(DUT.core_data_addr[0][7:2]) &&
        !$isunknown(DUT.core_data_wdata[0])) begin
      if ((DUT.core_data_addr[0] == 32'h1A10_0000) && (DUT.core_data_wdata[0] == 32'hCAFE_BABE))
        saw_scratch0_cafebabe = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0000) && (DUT.core_data_wdata[0] == 32'h534E_4501))
        saw_sne_smoke_start = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0000) && (DUT.core_data_wdata[0] == 32'h534E_4502))
        saw_sne_smoke_pass = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0000) && (DUT.core_data_wdata[0] == 32'h534E_45F0))
        saw_sne_smoke_readback_fail = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0000) && (DUT.core_data_wdata[0] == 32'h534E_45F1))
        saw_sne_smoke_fail = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0000) && (DUT.core_data_wdata[0] == 32'h534E_D001))
        saw_sne_dma_start = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0000) && (DUT.core_data_wdata[0] == 32'h534E_D002))
        saw_sne_dma_pass = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0000) && ((DUT.core_data_wdata[0] & 32'hFFFF_FFF0) == 32'h534E_D0F0))
        saw_sne_dma_fail = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0000) && (DUT.core_data_wdata[0] == 32'h4D4D_0001))
        saw_multimodal_boot = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0000) && (DUT.core_data_wdata[0] == 32'h4D4D_0002))
        saw_multimodal_stage2 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0000) && (DUT.core_data_wdata[0] == 32'h0000_0103))
        saw_multimodal_pass = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0000) && ((DUT.core_data_wdata[0] & 32'hFFFF_FF00) == 32'hD203_A100))
        saw_dronet_scratch0 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h0BAD_F00D))
        saw_scratch1_0badf00d = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h0004_0004))
        saw_dronet_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h00C8_0504))
        saw_dronet_stage0_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h0032_0304))
        saw_dronet_stage2_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h0019_0104))
        saw_dronet_stage3_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h0019_0304))
        saw_dronet_stage4_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h0519_0104))
        saw_dronet_stage5_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h0619_0304))
        saw_dronet_stage6_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h0713_0108))
        saw_dronet_stage7_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h0813_0308))
        saw_dronet_stage8_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h0913_0108))
        saw_dronet_stage9_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h0A07_0308))
        saw_dronet_stage10_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h0B07_0110))
        saw_dronet_stage11_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h0C07_0310))
        saw_dronet_stage12_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h0D07_0110))
        saw_dronet_stage13_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h0E01_0102))
        saw_dronet_stage14_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h99B1_E9C1))
        saw_dronet_stage0_signature = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0000) && (DUT.core_data_wdata[0] == 32'h0000_14D6))
        saw_dronet_stage14_signature = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h0008_0004))
        saw_dronet_partial_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0004) && (DUT.core_data_wdata[0] == 32'h00C8_0004))
        saw_dronet_full_scratch1 = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_0000) && (DUT.core_data_wdata[0] & 32'h0000_0002))
        saw_firmware_done_status = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_000C) && (DUT.core_data_wdata[0][7:0] == 8'h41))
        saw_uart_a_write = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_000C) && (DUT.core_data_wdata[0][7:0] == 8'h42))
        saw_uart_b_write = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_000C) && (DUT.core_data_wdata[0][7:0] == 8'h43))
        saw_uart_c_write = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_000C) && (DUT.core_data_wdata[0][7:0] == 8'h53))
        saw_uart_s_write = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_000C) && (DUT.core_data_wdata[0][7:0] == 8'h4D))
        saw_uart_m_write = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_000C) && (DUT.core_data_wdata[0][7:0] == 8'h44))
        saw_uart_d_write = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_000C) && (DUT.core_data_wdata[0][7:0] == 8'h50))
        saw_uart_p_write = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_000C) && (DUT.core_data_wdata[0][7:0] == 8'h54))
        saw_uart_t_write = 1'b1;
      if ((DUT.core_data_addr[0] == 32'h1A10_000C) && (DUT.core_data_wdata[0][7:0] == 8'h46))
        saw_uart_f_write = 1'b1;

      case (DUT.core_data_addr[0][7:2])
        6'h00: $display("@%0tns MMIO scratch0 <= %h", $time, DUT.core_data_wdata[0]);
        6'h01: $display("@%0tns MMIO scratch1 <= %h", $time, DUT.core_data_wdata[0]);
        6'h02: $display("@%0tns MMIO gpio     <= %h", $time, DUT.core_data_wdata[0]);
        6'h03: $display("@%0tns UART TX      <= %02h", $time, DUT.core_data_wdata[0][7:0]);
        default: $display("@%0tns MMIO[%02h]    <= %h", $time, DUT.core_data_addr[0][7:2], DUT.core_data_wdata[0]);
      endcase
    end
  end

  always @(posedge clk_i) begin
    if (rst_ni && (data_trace_count < 8) && DUT.core_data_req[0] &&
        !$isunknown(DUT.core_data_addr[0])) begin
      $display("@%0tns DATA req=%b gnt=%b rvalid=%b we=%b be=%b addr=%h wdata=%h rdata=%h",
               $time,
               DUT.core_data_req[0],
               DUT.core_data_gnt[0],
               DUT.core_data_rvalid[0],
               DUT.core_data_we[0],
               DUT.core_data_be[0],
               DUT.core_data_addr[0],
               DUT.core_data_wdata[0],
               DUT.core_data_rdata[0]);
      data_trace_count <= data_trace_count + 1;
    end
  end

  always @(posedge clk_i) begin
    if (!rst_ni) begin
      instr_trace_count <= 0;
    end else begin
      if (DUT.core_instr_req[0] && DUT.core_instr_gnt[0] &&
          (DUT.core_instr_addr[0] >= 32'h0000_000C) &&
          (DUT.core_instr_addr[0] < 32'h0000_00AC)) begin
        saw_main_region_fetch <= 1'b1;
      end

      if (instr_trace_count < 24 &&
          (DUT.core_instr_req[0] || DUT.core_instr_rvalid[0]) &&
          !$isunknown(DUT.core_instr_addr[0])) begin
        $display("@%0tns INSTR req=%b gnt=%b rvalid=%b addr=%h rdata=%h",
                 $time,
                 DUT.core_instr_req[0],
                 DUT.core_instr_gnt[0],
                 DUT.core_instr_rvalid[0],
                 DUT.core_instr_addr[0],
                 DUT.core_instr_rdata[0]);
        instr_trace_count <= instr_trace_count + 1;
      end
    end
  end

  always @(posedge clk_i) begin
    if (!rst_ni) begin
      prev_cutie_busy_q <= 1'b0;
      stage0_output_dump_done_q <= 1'b0;
      stage2_output_dump_done_q <= 1'b0;
      stage3_output_dump_done_q <= 1'b0;
      stage4_output_dump_done_q <= 1'b0;
      stage5_output_dump_done_q <= 1'b0;
      stage6_output_dump_done_q <= 1'b0;
      stage7_output_dump_done_q <= 1'b0;
      stage8_output_dump_done_q <= 1'b0;
      stage9_output_dump_done_q <= 1'b0;
      stage10_output_dump_done_q <= 1'b0;
      stage11_output_dump_done_q <= 1'b0;
      stage12_output_dump_done_q <= 1'b0;
      stage13_output_dump_done_q <= 1'b0;
    end else begin
      if (cutie_evt_o == 2'b01)
        saw_cutie_done_evt = 1'b1;
      if (cutie_evt_o == 2'b10)
        saw_cutie_timeout_evt = 1'b1;

      if ((cutie_busy_o != prev_cutie_busy_q) || (cutie_evt_o != 2'b00)) begin
        $display("@%0tns CUTIE busy=%b evt=%b", $time, cutie_busy_o, cutie_evt_o);
      end

      prev_cutie_busy_q <= cutie_busy_o;

      if (!stage0_output_dump_done_q &&
          is_dronet_stage0_preload_mem(mem_init_file) &&
          (cutie_evt_o == 2'b01)) begin
        stage0_output_dump_done_q <= 1'b1;
        dump_cutie_stage0_output_payload();
      end

      if (!stage2_output_dump_done_q &&
          is_dronet_stage2_preload_mem(mem_init_file) &&
          (cutie_evt_o == 2'b01)) begin
        stage2_output_dump_done_q <= 1'b1;
        dump_cutie_stage2_output_payload();
      end

      if (!stage3_output_dump_done_q &&
          is_dronet_stage3_preload_mem(mem_init_file) &&
          (cutie_evt_o == 2'b01)) begin
        stage3_output_dump_done_q <= 1'b1;
        dump_cutie_stage3_output_payload();
      end

      if (!stage4_output_dump_done_q &&
          is_dronet_stage4_preload_mem(mem_init_file) &&
          (cutie_evt_o == 2'b01)) begin
        stage4_output_dump_done_q <= 1'b1;
        dump_cutie_stage4_output_payload();
      end

      if (!stage5_output_dump_done_q &&
          is_dronet_stage5_preload_mem(mem_init_file) &&
          (cutie_evt_o == 2'b01)) begin
        stage5_output_dump_done_q <= 1'b1;
        dump_cutie_stage5_output_payload();
      end

      if (!stage6_output_dump_done_q &&
          is_dronet_stage6_preload_mem(mem_init_file) &&
          (cutie_evt_o == 2'b01)) begin
        stage6_output_dump_done_q <= 1'b1;
        dump_cutie_stage6_output_payload();
      end

      if (!stage7_output_dump_done_q &&
          is_dronet_stage7_preload_mem(mem_init_file) &&
          (cutie_evt_o == 2'b01)) begin
        stage7_output_dump_done_q <= 1'b1;
        dump_cutie_stage7_output_payload();
      end

      if (!stage8_output_dump_done_q &&
          is_dronet_stage8_preload_mem(mem_init_file) &&
          (cutie_evt_o == 2'b01)) begin
        stage8_output_dump_done_q <= 1'b1;
        dump_cutie_stage8_output_payload();
      end

      if (!stage9_output_dump_done_q &&
          is_dronet_stage9_preload_mem(mem_init_file) &&
          (cutie_evt_o == 2'b01)) begin
        stage9_output_dump_done_q <= 1'b1;
        dump_cutie_stage9_output_payload();
      end

      if (!stage10_output_dump_done_q &&
          is_dronet_stage10_preload_mem(mem_init_file) &&
          (cutie_evt_o == 2'b01)) begin
        stage10_output_dump_done_q <= 1'b1;
        dump_cutie_stage10_output_payload();
      end

      if (!stage11_output_dump_done_q &&
          is_dronet_stage11_preload_mem(mem_init_file) &&
          (cutie_evt_o == 2'b01)) begin
        stage11_output_dump_done_q <= 1'b1;
        dump_cutie_stage11_output_payload();
      end

      if (!stage12_output_dump_done_q &&
          is_dronet_stage12_preload_mem(mem_init_file) &&
          (cutie_evt_o == 2'b01)) begin
        stage12_output_dump_done_q <= 1'b1;
        dump_cutie_stage12_output_payload();
      end

      if (!stage13_output_dump_done_q &&
          is_dronet_stage13_preload_mem(mem_init_file) &&
          (cutie_evt_o == 2'b01)) begin
        stage13_output_dump_done_q <= 1'b1;
        dump_cutie_stage13_output_payload();
      end
    end
  end

  always @(posedge clk_i) begin
    if (rst_ni && dronet_debug_mode &&
        !is_dronet_stage0_preload_mem(mem_init_file) &&
        !is_dronet_full_preload_mem(mem_init_file) &&
        cutie_busy_o &&
        (cycles_after_reset > 200) && ((cycles_after_reset % 1000) == 0)) begin
      $display("@%0tns CUTIE_INT compute_done=%b luca_done=%b lb_done=%b wload_done0=%b latch_new=%b",
               $time,
               DUT.i_cutie.cutie_i.compute_done_o,
               DUT.i_cutie.cutie_i.LUCA_compute_done_o,
               DUT.i_cutie.cutie_i.linebuffer_master_controller_done_o,
               DUT.i_cutie.cutie_i.LUCA_weightload_done_i[0],
               DUT.i_cutie.cutie_i.LUCA_compute_latch_new_layer_o);
      $display("@%0tns LUCA_INT num_layers=%0d compute_run=%0d weight_run=%0d cur_done=%b wready=%b iter_done=%b fifo_empty=%b fifo_pop=%b",
               $time,
               DUT.i_cutie.cutie_i.LUCA.num_layers_q,
               DUT.i_cutie.cutie_i.LUCA.compute_layer_running_q,
               DUT.i_cutie.cutie_i.LUCA.weight_layer_running_q,
               DUT.i_cutie.cutie_i.LUCA.current_layer_done_q,
               DUT.i_cutie.cutie_i.LUCA.weightload_ready_q,
               DUT.i_cutie.cutie_i.LUCA.iteration_done_q,
               DUT.i_cutie.cutie_i.LUCA.layer_fifo_empty,
               DUT.i_cutie.cutie_i.LUCA.fifo_pop_o);
      $display("@%0tns LB_INT ready_r=%b ready_w=%b read_col=%0d read_row=%0d write_col=%0d write_row=%0d state=%b",
         $time,
         DUT.i_cutie.cutie_i.linebuffer_master_controller_ready_read_o,
         DUT.i_cutie.cutie_i.linebuffer_master_controller_ready_write_o,
         DUT.i_cutie.cutie_i.linebuffer_master_controller_read_col_o,
         DUT.i_cutie.cutie_i.linebuffer_master_controller_read_row_o,
         DUT.i_cutie.cutie_i.linebuffer_master_controller_write_col_o,
         DUT.i_cutie.cutie_i.linebuffer_master_controller_write_row_o,
         DUT.i_cutie.cutie_i.linebuffer_master_controller.state_q);
      $display("@%0tns LB_HS ready_i=%b valid_i=%b linebuf_valid=%b actmem_ready_any=%b rw_collision_zero=%b ocu_ready=%b weight_valid00=%b",
         $time,
         DUT.i_cutie.cutie_i.linebuffer_master_controller_ready_i,
         DUT.i_cutie.cutie_i.linebuffer_master_controller_valid_i,
         DUT.i_cutie.cutie_i.linebuffer_valid_i,
         (DUT.i_cutie.cutie_i.actmem_ready_o > 0),
         (DUT.i_cutie.cutie_i.actmem_rw_collision_o == '0),
         DUT.i_cutie.cutie_i.ocu_controller_ready_o,
         DUT.i_cutie.cutie_i.weightmemory_controller_valid_out[0][0]);
      $display("@%0tns ACTMEM2LB ni=%0d pixelwidth=%0d bank_idx=%0d bank_depth=%0d ready_i=%b valid_i=%b",
         $time,
         DUT.i_cutie.cutie_i.LUCA_compute_ni_o,
         DUT.i_cutie.cutie_i.actmem2lb_controller.pixelwidth_q,
         DUT.i_cutie.cutie_i.actmem2lb_controller.bank_index_q,
         DUT.i_cutie.cutie_i.actmem2lb_controller.bank_depth_q,
         DUT.i_cutie.cutie_i.actmem2lb_controller_ready_i,
         DUT.i_cutie.cutie_i.actmem2lb_controller_valid_i);
    end
  end

  always @(posedge clk_i) begin
    integer instr_delta;
    integer data_delta;
    integer instr_next;
    integer data_next;

    if (!rst_ni) begin
      instr_req_no_gnt_streak <= 0;
      instr_req_no_gnt_max    <= 0;
      data_req_no_gnt_streak  <= 0;
      data_req_no_gnt_max     <= 0;
      instr_outstanding       <= 0;
      data_outstanding        <= 0;
      instr_outstanding_max   <= 0;
      data_outstanding_max    <= 0;
      instr_resp_wo_req       <= 0;
      data_resp_wo_req        <= 0;
      instr_outstanding_overflow <= 0;
      data_outstanding_overflow  <= 0;
    end else begin
      if (DUT.core_instr_req[0] && !DUT.core_instr_gnt[0]) begin
        instr_req_no_gnt_streak <= instr_req_no_gnt_streak + 1;
        if ((instr_req_no_gnt_streak + 1) > instr_req_no_gnt_max)
          instr_req_no_gnt_max <= instr_req_no_gnt_streak + 1;
      end else begin
        instr_req_no_gnt_streak <= 0;
      end

      if (DUT.core_data_req[0] && !DUT.core_data_gnt[0]) begin
        data_req_no_gnt_streak <= data_req_no_gnt_streak + 1;
        if ((data_req_no_gnt_streak + 1) > data_req_no_gnt_max)
          data_req_no_gnt_max <= data_req_no_gnt_streak + 1;
      end else begin
        data_req_no_gnt_streak <= 0;
      end

      instr_delta = 0;
      if (DUT.core_instr_req[0] && DUT.core_instr_gnt[0])
        instr_delta = instr_delta + 1;
      if (DUT.core_instr_rvalid[0]) begin
        if (instr_outstanding == 0 && instr_delta == 0)
          instr_resp_wo_req <= instr_resp_wo_req + 1;
        else
          instr_delta = instr_delta - 1;
      end
      instr_next = instr_outstanding + instr_delta;
      if (instr_next < 0)
        instr_next = 0;
      instr_outstanding <= instr_next;
      if (instr_next > instr_outstanding_max)
        instr_outstanding_max <= instr_next;
      if (instr_next > 2)
        instr_outstanding_overflow <= instr_outstanding_overflow + 1;

      if (DUT.core_data_req[0] && DUT.core_data_gnt[0]) begin
        if ((DUT.core_data_addr[0][31:12] == 20'h1A110) && DUT.core_data_we[0]) begin
          saw_cutie_cfg_write = 1'b1;
          if ((DUT.core_data_addr[0][11:0] == 12'h000) && DUT.core_data_wdata[0][0])
            saw_cutie_start_write = 1'b1;
        end
      end

      data_delta = 0;
      if (DUT.core_data_req[0] && DUT.core_data_gnt[0])
        data_delta = data_delta + 1;
      if (DUT.core_data_rvalid[0]) begin
        if (data_outstanding == 0 && data_delta == 0)
          data_resp_wo_req <= data_resp_wo_req + 1;
        else
          data_delta = data_delta - 1;
      end
      data_next = data_outstanding + data_delta;
      if (data_next < 0)
        data_next = 0;
      data_outstanding <= data_next;
      if (data_next > data_outstanding_max)
        data_outstanding_max <= data_next;
      if (data_next > 2)
        data_outstanding_overflow <= data_outstanding_overflow + 1;
    end
  end

  // ═══════════════════════════════════════════════════════════════════════
  // Simulation Control
  // ═══════════════════════════════════════════════════════════════════════
  
  initial begin
    logic is_hello_firmware;
    logic is_demo_mode_firmware;
    logic is_sne_smoke_firmware;
    logic is_sne_dma_smoke_firmware;
    logic is_cutie_dma_smoke_firmware;
    logic is_multimodal_smoke_firmware;
    logic is_hw_opt_smoke_firmware;
    logic is_dronet_firmware;
    logic is_dronet_smoke_firmware;
    logic is_dronet_stage0_firmware;
    logic is_dronet_stage0_preload_firmware;
    logic is_dronet_stage2_preload_firmware;
    logic is_dronet_stage3_preload_firmware;
    logic is_dronet_stage4_preload_firmware;
    logic is_dronet_stage5_preload_firmware;
    logic is_dronet_stage6_preload_firmware;
    logic is_dronet_stage7_preload_firmware;
    logic is_dronet_stage8_preload_firmware;
    logic is_dronet_stage9_preload_firmware;
    logic is_dronet_stage10_preload_firmware;
    logic is_dronet_stage11_preload_firmware;
    logic is_dronet_stage12_preload_firmware;
      logic is_dronet_stage13_preload_firmware;
      logic is_dronet_stage14_hardware_preload_firmware;
      logic is_dronet_stage14_software_firmware;
      logic is_dronet_full_hardware_firmware;
      logic is_dronet_partial_firmware;
      logic is_dronet_full_firmware;
      logic is_dronet_full_preload_firmware;

    is_hello_firmware = path_has_suffix(mem_init_file, "/sw/basic/hello.mem");
    is_demo_mode_firmware = path_has_suffix(mem_init_file, "/sw/demo_mode/demo_mode.mem");
    is_sne_smoke_firmware = path_has_suffix(mem_init_file, "/sw/sne_smoke/sne_smoke.mem");
    is_sne_dma_smoke_firmware = path_has_suffix(mem_init_file, "/sw/sne_dma_smoke/sne_dma_smoke.mem");
    is_cutie_dma_smoke_firmware = path_has_suffix(mem_init_file, "/sw/cutie_dma_smoke/cutie_dma_smoke.mem");
    is_multimodal_smoke_firmware = path_has_suffix(mem_init_file, "/sw/multimodal_smoke/multimodal_smoke.mem");
    is_hw_opt_smoke_firmware = path_has_suffix(mem_init_file, "/sw/hw_opt_smoke/hw_opt_smoke.mem");
    is_dronet_firmware = path_has_suffix(mem_init_file, "/sw/dronet_v3/dronet_v3_driver.mem");
    is_dronet_smoke_firmware = path_has_suffix(mem_init_file, "/sw/dronet_v3/dronet_v3_smoke.mem");
    is_dronet_stage0_firmware = path_has_suffix(mem_init_file, "/sw/dronet_v3/dronet_v3_stage0.mem");
    is_dronet_stage0_preload_firmware = is_dronet_stage0_preload_mem(mem_init_file);
    is_dronet_stage2_preload_firmware = is_dronet_stage2_preload_mem(mem_init_file);
    is_dronet_stage3_preload_firmware = is_dronet_stage3_preload_mem(mem_init_file);
    is_dronet_stage4_preload_firmware = is_dronet_stage4_preload_mem(mem_init_file);
    is_dronet_stage5_preload_firmware = is_dronet_stage5_preload_mem(mem_init_file);
    is_dronet_stage6_preload_firmware = is_dronet_stage6_preload_mem(mem_init_file);
    is_dronet_stage7_preload_firmware = is_dronet_stage7_preload_mem(mem_init_file);
    is_dronet_stage8_preload_firmware = is_dronet_stage8_preload_mem(mem_init_file);
    is_dronet_stage9_preload_firmware = is_dronet_stage9_preload_mem(mem_init_file);
    is_dronet_stage10_preload_firmware = is_dronet_stage10_preload_mem(mem_init_file);
    is_dronet_stage11_preload_firmware = is_dronet_stage11_preload_mem(mem_init_file);
    is_dronet_stage12_preload_firmware = is_dronet_stage12_preload_mem(mem_init_file);
      is_dronet_stage13_preload_firmware = is_dronet_stage13_preload_mem(mem_init_file);
      is_dronet_stage14_hardware_preload_firmware = is_dronet_stage14_hardware_preload_mem(mem_init_file);
      is_dronet_stage14_software_firmware = is_dronet_stage14_software_mem(mem_init_file);
      is_dronet_full_hardware_firmware = path_has_suffix(mem_init_file, "/sw/dronet_v3/dronet_v3_full_hardware.mem");
      is_dronet_partial_firmware = path_has_suffix(mem_init_file, "/sw/dronet_v3/dronet_v3_partial.mem");
      is_dronet_full_firmware = path_has_suffix(mem_init_file, "/sw/dronet_v3/dronet_v3_full.mem");
      is_dronet_full_preload_firmware = is_dronet_full_preload_mem(mem_init_file);

    if (is_sne_smoke_firmware)
      #(SNE_SIM_TIME);
    else if (is_demo_mode_firmware)
      #(CUTIE_DMA_SIM_TIME + SNE_SIM_TIME + 50us);
    else if (is_sne_dma_smoke_firmware)
      #(SNE_DMA_SIM_TIME);
    else if (is_cutie_dma_smoke_firmware)
      #(CUTIE_DMA_SIM_TIME);
    else if (is_hw_opt_smoke_firmware)
      #(SNE_SIM_TIME);
    else if (is_multimodal_smoke_firmware)
      #(DRONET_STAGE14_SIM_TIME);
    else if (is_dronet_stage0_firmware || is_dronet_stage0_preload_firmware || is_dronet_full_preload_firmware)
      #(DRONET_STAGE0_SIM_TIME);
    else if (is_dronet_stage2_preload_firmware)
      #(DRONET_STAGE2_SIM_TIME);
    else if (is_dronet_stage3_preload_firmware)
      #(DRONET_STAGE3_SIM_TIME);
    else if (is_dronet_stage4_preload_firmware)
      #(DRONET_STAGE4_SIM_TIME);
    else if (is_dronet_stage5_preload_firmware)
      #(DRONET_STAGE5_SIM_TIME);
    else if (is_dronet_stage6_preload_firmware)
      #(DRONET_STAGE6_SIM_TIME);
    else if (is_dronet_stage7_preload_firmware)
      #(DRONET_STAGE7_SIM_TIME);
    else if (is_dronet_stage8_preload_firmware)
      #(DRONET_STAGE8_SIM_TIME);
    else if (is_dronet_stage9_preload_firmware)
      #(DRONET_STAGE9_SIM_TIME);
    else if (is_dronet_stage10_preload_firmware)
      #(DRONET_STAGE10_SIM_TIME);
    else if (is_dronet_stage11_preload_firmware)
      #(DRONET_STAGE11_SIM_TIME);
    else if (is_dronet_stage12_preload_firmware)
      #(DRONET_STAGE12_SIM_TIME);
    else if (is_dronet_stage13_preload_firmware)
      #(DRONET_STAGE13_SIM_TIME);
    else if (is_dronet_stage14_hardware_preload_firmware)
      #(DRONET_STAGE14_SIM_TIME);
    else if (is_dronet_stage14_software_firmware)
      #(DRONET_STAGE14_SIM_TIME);
    else if (is_dronet_firmware || is_dronet_smoke_firmware || is_dronet_partial_firmware || is_dronet_full_firmware)
      #(DRONET_SIM_TIME);
    else
      #(DEFAULT_SIM_TIME);
    
    $display("═══════════════════════════════════════════════════════════════");
    $display("Simulation Complete");
    $display("───────────────────────────────────────────────────────────────");
    $display("Total cycles after reset: %0d", cycles_after_reset);
    $display("Signal Activity Summary:");
    $display("  ✓ PULP Address Activity: %s", has_addr_activity ? "YES" : "NO");
    $display("  ✓ PULP Request Activity: %s", has_req_activity ? "YES" : "NO");
    $display("  ✓ Memory Activity:       %s", has_mem_activity ? "YES" : "NO");
    $display("  ✓ CUTIE Activity:        %s", has_cutie_activity ? "YES" : "NO");
    $display("  ✓ Firmware Fetch Seen:   %s", has_firmware_fetch ? "YES" : "NO");
    $display("  ✓ Main Region Fetch:     %s", saw_main_region_fetch ? "YES" : "NO");
    $display("  ✓ MMIO Activity Seen:    %s", has_mmio_activity ? "YES" : "NO");
    $display("DUT MMIO state:");
    $display("  scratch0=%h scratch1=%h gpio=%h uart_tx=%h uart_status=%h",
         DUT.mmio_scratch0_q,
         DUT.mmio_scratch1_q,
         DUT.mmio_gpio_q,
         DUT.uart_tx_reg_q,
         DUT.uart_status_q);
    $display("DUT CUTIE state:");
    $display("  cutie_busy=%b cutie_evt=%b cutie_status=%h cutie_readback=%h",
         cutie_busy_o,
         cutie_evt_o,
         DUT.cutie_status_q,
         DUT.cutie_readback_q);
        $display("REQ/CHECK scoreboard:");
        $display("  instr_req_no_gnt_max=%0d data_req_no_gnt_max=%0d", instr_req_no_gnt_max, data_req_no_gnt_max);
        $display("  instr_outstanding_max=%0d data_outstanding_max=%0d", instr_outstanding_max, data_outstanding_max);
        $display("  instr_resp_wo_req=%0d data_resp_wo_req=%0d", instr_resp_wo_req, data_resp_wo_req);
        $display("  instr_outstanding_overflow=%0d data_outstanding_overflow=%0d",
           instr_outstanding_overflow, data_outstanding_overflow);
        if (is_hello_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  scratch0_cafebabe=%s scratch1_0badf00d=%s uart_A=%s",
             saw_scratch0_cafebabe ? "YES" : "NO",
             saw_scratch1_0badf00d ? "YES" : "NO",
             saw_uart_a_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("Firmware profile: hello");
          $display("  profile_checkpoint=%s",
             (saw_scratch0_cafebabe && saw_scratch1_0badf00d && saw_uart_a_write) ? "PASS" : "FAIL");
        end else if (is_demo_mode_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  demo_status=%08x demo_result=%08x uart_B=%s uart_M=%s uart_C=%s uart_S=%s uart_P=%s uart_F=%s",
             demo_status_o,
             demo_result_o,
             saw_uart_b_write ? "YES" : "NO",
             saw_uart_m_write ? "YES" : "NO",
             saw_uart_c_write ? "YES" : "NO",
             saw_uart_s_write ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("  cutie_sig=%08x out0=%08x out1=%08x",
             DUT.mmio_demo_cutie_sig_q,
             DUT.mmio_demo_cutie_out0_q,
             DUT.mmio_demo_cutie_out1_q);
          $display("  cycle0=%0d cycle1=%0d cycle2=%0d dma_done=%0d dma_error=%0d sne_activity=%0d",
             DUT.mmio_demo_cycle0_q,
             DUT.mmio_demo_cycle1_q,
             DUT.mmio_demo_cycle2_q,
             DUT.dma_done_count_q,
             DUT.dma_error_count_q,
             sne_activity_o);
          $display("Firmware profile: demo_mode");
          $display("  profile_checkpoint=%s",
             ((demo_status_o & 32'h0000_001F) == 32'h0000_001F &&
              demo_result_o[31] == 1'b0 &&
              demo_result_o[0] == 1'b1 &&
              saw_uart_b_write && saw_uart_m_write && saw_uart_c_write &&
              saw_uart_s_write && saw_uart_p_write && !saw_uart_f_write &&
              DUT.mmio_demo_cutie_sig_q == 32'h0000_14D6 &&
              DUT.mmio_demo_cutie_out0_q == 32'h0000_0094 &&
              DUT.mmio_demo_cutie_out1_q == 32'h0000_0A21 &&
              DUT.dma_done_count_q >= 2 &&
              DUT.dma_error_count_q == 0) ? "PASS" : "FAIL");
        end else if (is_sne_smoke_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  sne_start=%s sne_pass=%s sne_readback_fail=%s sne_fail=%s",
             saw_sne_smoke_start ? "YES" : "NO",
             saw_sne_smoke_pass ? "YES" : "NO",
             saw_sne_smoke_readback_fail ? "YES" : "NO",
             saw_sne_smoke_fail ? "YES" : "NO");
          $display("  uart_S=%s uart_P=%s uart_F=%s",
             saw_uart_s_write ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: sne_smoke");
          $display("  profile_checkpoint=%s",
             (saw_sne_smoke_start && saw_sne_smoke_pass && saw_uart_s_write &&
              saw_uart_p_write && !saw_sne_smoke_readback_fail &&
              !saw_sne_smoke_fail && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_sne_dma_smoke_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  sne_dma_start=%s sne_dma_pass=%s sne_dma_fail=%s",
             saw_sne_dma_start ? "YES" : "NO",
             saw_sne_dma_pass ? "YES" : "NO",
             saw_sne_dma_fail ? "YES" : "NO");
          $display("  uart_D=%s uart_P=%s uart_F=%s",
             saw_uart_d_write ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("  fifo_watermark=%0d batch_done=%0d error_flags=%03b",
             DUT.i_sne.i_evt_fifo.watermark_q,
             DUT.i_sne.evt_batch_done_count_q,
             DUT.i_sne.evt_error_flags_q);
          $display("Firmware profile: sne_dma_smoke");
          $display("  profile_checkpoint=%s",
             (saw_sne_dma_start && saw_sne_dma_pass && saw_uart_d_write &&
              saw_uart_p_write && !saw_sne_dma_fail &&
              !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_hw_opt_smoke_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  hw_opt_boot=%s hw_opt_pass=%s uart_H=%s uart_P=%s uart_F=%s",
             (DUT.mmio_scratch0_q == 32'h484F_0001 || saw_multimodal_boot) ? "YES" : "NO",
             (DUT.mmio_scratch0_q == 32'h484F_0002) ? "YES" : "NO",
             (DUT.uart_tx_reg_q == 32'h0000_0048) ? "YES" : "NO",
             (DUT.uart_tx_reg_q == 32'h0000_0050) ? "YES" : "NO",
             (DUT.uart_tx_reg_q == 32'h0000_0046) ? "YES" : "NO");
          $display("  desc_ok=%0d burst_ok=%0d sne_ok=%0d sne_done_count=%0d irq_status=%08x",
             DUT.mmio_scratch1_q[16],
             DUT.mmio_scratch1_q[8],
             DUT.mmio_scratch1_q[0],
             DUT.sne_done_count_q,
             DUT.accel_irq_status_q);
          $display("  sne_pop_count=%0d gpio=%08x accel_busy=%08x",
             DUT.i_sne.i_evt_fifo.pop_count_q,
             DUT.mmio_gpio_q,
             DUT.accel_busy_live);
          $display("Firmware profile: hw_opt_smoke");
          $display("  profile_checkpoint=%s",
             ((DUT.mmio_scratch0_q == 32'h484F_0002) &&
              (DUT.mmio_scratch1_q[16] == 1'b1) &&
              (DUT.mmio_scratch1_q[8] == 1'b1) &&
              (DUT.mmio_scratch1_q[0] == 1'b1) &&
              (DUT.sne_done_count_q != 32'd0) &&
              (DUT.sne_error_count_q == 32'd0) &&
              (DUT.accel_irq_status_q[3:0] == 4'b0000) &&
              (DUT.i_sne.i_evt_fifo.pop_count_q == 32'd2) &&
              (DUT.uart_tx_reg_q == 32'h0000_0050)) ? "PASS" : "FAIL");
        end else if (is_cutie_dma_smoke_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  cutie_dma_boot=%s cutie_dma_pass=%s uart_C=%s uart_P=%s uart_F=%s",
             (DUT.mmio_scratch0_q == 32'h4344_0001) ? "YES" : "NO",
             (DUT.mmio_scratch1_q == 32'hCD14_0102) ? "YES" : "NO",
             (DUT.uart_tx_reg_q == 32'h0000_0043) ? "YES" : "NO",
             (DUT.uart_tx_reg_q == 32'h0000_0050) ? "YES" : "NO",
             (DUT.uart_tx_reg_q == 32'h0000_0046) ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  dma_done_count=%0d dma_error_count=%0d dma_status=%08x remaining=%0d",
             DUT.dma_done_count_q,
             DUT.dma_error_count_q,
             DUT.dma_status_q,
             DUT.dma_remaining_q);
          $display("  dma_state=%0d desc_ptr=%08x src=%08x dst=%08x bank=%08x words=%08x ctrl=%08x next=%08x",
             DUT.dma_state_q,
             DUT.dma_desc_ptr_q,
             DUT.dma_src_addr_q,
             DUT.dma_dst_addr_q,
             DUT.dma_bank_q,
             DUT.dma_word_count_q,
             DUT.dma_control_q,
             DUT.dma_next_desc_q);
          $display("  dma_curr_src=%08x dma_curr_dst=%08x read_lo=%08x read_hi=%08x target=%0d",
             DUT.dma_curr_src_q,
             DUT.dma_curr_dst_q,
             DUT.dma_read_lo_q,
             DUT.dma_read_hi_q,
             DUT.dma_target_q);
          if ((DUT.dma_desc_ptr_q[17:2] + 6) < 65536) begin
            $display("  desc_words=%08x %08x %08x %08x %08x %08x",
               DUT.i_l2_mem.ram[DUT.dma_desc_ptr_q[17:2] + 0],
               DUT.i_l2_mem.ram[DUT.dma_desc_ptr_q[17:2] + 1],
               DUT.i_l2_mem.ram[DUT.dma_desc_ptr_q[17:2] + 2],
               DUT.i_l2_mem.ram[DUT.dma_desc_ptr_q[17:2] + 3],
               DUT.i_l2_mem.ram[DUT.dma_desc_ptr_q[17:2] + 4],
               DUT.i_l2_mem.ram[DUT.dma_desc_ptr_q[17:2] + 5]);
          end
          $display("  gpio=%08x scratch0=%08x scratch1=%08x sig=%08x out0=%08x out1=%08x",
             DUT.mmio_gpio_q,
             DUT.mmio_scratch0_q,
             DUT.mmio_scratch1_q,
             DUT.i_cutie.linear_signature_q,
             DUT.i_cutie.linear_out0_q,
             DUT.i_cutie.linear_out1_q);
          $display("Firmware profile: cutie_dma_smoke");
          $display("  profile_checkpoint=%s",
             ((DUT.mmio_scratch1_q == 32'hCD14_0102) &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              (DUT.dma_done_count_q >= 32'd2) &&
              (DUT.dma_error_count_q == 32'd0) &&
              (DUT.uart_tx_reg_q == 32'h0000_0050)) ? "PASS" : "FAIL");
        end else if (is_multimodal_smoke_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  multimodal_boot=%s multimodal_stage2=%s multimodal_pass=%s uart_M=%s",
             saw_multimodal_boot ? "YES" : "NO",
             saw_multimodal_stage2 ? "YES" : "NO",
             saw_multimodal_pass ? "YES" : "NO",
             saw_uart_m_write ? "YES" : "NO");
          $display("  dronet_scratch0=%s dronet_stage14_scratch1=%s stage14_sig=%s firmware_done_status=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_stage14_scratch1 ? "YES" : "NO",
             saw_dronet_stage14_signature ? "YES" : "NO",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s uart_P=%s uart_F=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: multimodal_smoke");
          $display("  profile_checkpoint=%s",
             (saw_multimodal_boot && saw_multimodal_stage2 &&
              saw_uart_m_write && saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_dronet_scratch0 && saw_dronet_stage14_scratch1 &&
              saw_dronet_stage14_signature &&
              saw_firmware_done_status && saw_uart_d_write &&
              saw_uart_p_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_firmware || is_dronet_smoke_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_scratch1=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_scratch1 ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: dronet_v3");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_scratch1 && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_stage0_firmware || is_dronet_stage0_preload_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_stage0_scratch1=%s stage0_sig=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_stage0_scratch1 ? "YES" : "NO",
             saw_dronet_stage0_signature ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: %s",
             is_dronet_stage0_preload_firmware ? "dronet_v3_stage0_preload" : "dronet_v3_stage0");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_stage0_scratch1 && saw_dronet_stage0_signature && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_stage2_preload_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_stage2_scratch1=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_stage2_scratch1 ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: dronet_v3_stage2_preload");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_stage2_scratch1 && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_stage3_preload_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_stage3_scratch1=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_stage3_scratch1 ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: dronet_v3_stage3_preload");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_stage3_scratch1 && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_stage4_preload_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_stage4_scratch1=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_stage4_scratch1 ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: dronet_v3_stage4_preload");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_stage4_scratch1 && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_stage5_preload_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_stage5_scratch1=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_stage5_scratch1 ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: dronet_v3_stage5_preload");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_stage5_scratch1 && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_stage6_preload_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_stage6_scratch1=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_stage6_scratch1 ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: dronet_v3_stage6_preload");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_stage6_scratch1 && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_stage7_preload_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_stage7_scratch1=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_stage7_scratch1 ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: dronet_v3_stage7_preload");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_stage7_scratch1 && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_stage8_preload_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_stage8_scratch1=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_stage8_scratch1 ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: dronet_v3_stage8_preload");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_stage8_scratch1 && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_stage9_preload_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_stage9_scratch1=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_stage9_scratch1 ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: dronet_v3_stage9_preload");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_stage9_scratch1 && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_stage10_preload_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_stage10_scratch1=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_stage10_scratch1 ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: dronet_v3_stage10_preload");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_stage10_scratch1 && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_stage11_preload_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_stage11_scratch1=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_stage11_scratch1 ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: dronet_v3_stage11_preload");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_stage11_scratch1 && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_stage12_preload_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_stage12_scratch1=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_stage12_scratch1 ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: dronet_v3_stage12_preload");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_stage12_scratch1 && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_stage13_preload_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_stage13_scratch1=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_stage13_scratch1 ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: dronet_v3_stage13_preload");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_stage13_scratch1 && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_stage14_hardware_preload_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_stage14_scratch1=%s stage14_sig=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_stage14_scratch1 ? "YES" : "NO",
             saw_dronet_stage14_signature ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("  linear_mode=%0d linear_words=%0d out0=%08x out1=%08x sig=%08x",
             DUT.i_cutie.reg_linear_mode,
             DUT.i_cutie.reg_linear_word_count,
             DUT.i_cutie.linear_out0_q,
             DUT.i_cutie.linear_out1_q,
             DUT.i_cutie.linear_signature_q);
          $display("Firmware profile: %s",
             is_dronet_full_hardware_firmware ? "dronet_v3_full_hardware" : "dronet_v3_stage14_hardware_preload");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_stage14_scratch1 &&
              saw_dronet_stage14_signature && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_stage14_software_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_stage14_scratch1=%s stage14_sig=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_stage14_scratch1 ? "YES" : "NO",
             saw_dronet_stage14_signature ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: dronet_v3_stage14_software");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_stage14_scratch1 &&
              saw_uart_d_write &&
              saw_uart_p_write && !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_partial_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_partial_scratch1=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_partial_scratch1 ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: dronet_v3_partial");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_partial_scratch1 && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else if (is_dronet_full_firmware || is_dronet_full_preload_firmware) begin
          $display("FIRMWARE checkpoint writes:");
          $display("  dronet_scratch0=%s dronet_full_scratch1=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_full_scratch1 ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("  cutie_done_evt=%s cutie_timeout_evt=%s",
             saw_cutie_done_evt ? "YES" : "NO",
             saw_cutie_timeout_evt ? "YES" : "NO");
          $display("  firmware_done_status=%s uart_P=%s uart_T=%s uart_F=%s",
             saw_firmware_done_status ? "YES" : "NO",
             saw_uart_p_write ? "YES" : "NO",
             saw_uart_t_write ? "YES" : "NO",
             saw_uart_f_write ? "YES" : "NO");
          $display("Firmware profile: %s",
             is_dronet_full_preload_firmware ? "dronet_v3_full_preload" : "dronet_v3_full");
          $display("  profile_checkpoint=%s",
             (saw_dronet_scratch0 && saw_dronet_full_scratch1 && saw_uart_d_write &&
              saw_cutie_cfg_write && saw_cutie_start_write &&
              saw_cutie_done_evt && !saw_cutie_timeout_evt &&
              saw_firmware_done_status && saw_uart_p_write &&
              !saw_uart_t_write && !saw_uart_f_write) ? "PASS" : "FAIL");
        end else begin
          $display("FIRMWARE checkpoint writes:");
          $display("  scratch0_cafebabe=%s scratch1_0badf00d=%s uart_A=%s",
             saw_scratch0_cafebabe ? "YES" : "NO",
             saw_scratch1_0badf00d ? "YES" : "NO",
             saw_uart_a_write ? "YES" : "NO");
          $display("  dronet_scratch0=%s dronet_scratch1=%s uart_D=%s",
             saw_dronet_scratch0 ? "YES" : "NO",
             saw_dronet_scratch1 ? "YES" : "NO",
             saw_uart_d_write ? "YES" : "NO");
          $display("  cutie_cfg_write=%s cutie_start_write=%s",
             saw_cutie_cfg_write ? "YES" : "NO",
             saw_cutie_start_write ? "YES" : "NO");
          $display("Firmware profile: custom");
          $display("  profile_checkpoint=SKIP");
        end
    $display("═══════════════════════════════════════════════════════════════");

    if (mem_init_file != "") begin
      if (has_firmware_fetch && has_mmio_activity) begin
        $display("FIRMWARE_BOOT_CHECK: PASS");
      end else begin
        $display("FIRMWARE_BOOT_CHECK: FAIL");
      end
    end
    
    $finish;
  end

  // ═══════════════════════════════════════════════════════════════════════
  // VCD Dump (for waveform viewing)
  // ═══════════════════════════════════════════════════════════════════════
  
  initial begin
    $dumpfile("kraken_soc_func.vcd");
    $dumpvars(0, kraken_soc_func_tb);
  end

endmodule
