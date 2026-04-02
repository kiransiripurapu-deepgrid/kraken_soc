# Functional Kraken build script (separate project)
#
# Creates a focused Vivado project for `kraken_soc_func` using the simpler
# `ips/pulp_cluster/pulp_cluster_top.sv` cluster plus the CUTIE wrapper.
# The goal is to preserve intended functionality on Artix-7 without dragging in
# unrelated full-cluster RTL that makes synthesis much heavier.

set project_name "kraken_func_a7"
set part "xc7a200tsbg484-1"

# Resolve paths relative to this script, not Vivado CWD
set script_dir [file normalize [file dirname [info script]]]
set repo_root  [file normalize [file join $script_dir ".."]]
set proj_dir   [file normalize [file join $script_dir $project_name]]

create_project -force $project_name $proj_dir -part $part

# Include paths (match existing)
set inc_dirs [list \
  [file normalize [file join $repo_root "include"]] \
  [file normalize [file join $repo_root "ips/common_cells/include"]] \
  [file normalize [file join $repo_root "ips/cv32e40p/include"]] \
  [file normalize [file join $repo_root "mini_kraken.srcs/sources_1/imports"]] \
  [file normalize [file join $repo_root "ips/register_interface"]] \
  [file normalize [file join $repo_root "mini_kraken.srcs/sources_1/new"]] \
]

set_property include_dirs $inc_dirs [current_fileset]
set_property target_language Verilog [current_project]
set_property default_lib xil_defaultlib [current_project]

# SNE preprocessor macros (must be set before SNE source files are elaborated)
set_property verilog_define "SLICES=2 NGGROUPS=4" [current_fileset]

# Base packages
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "include/axi_pkg.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "include/dm_pkg.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "include/cv32e40p_pkg.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "include/cv32e40p_fpu_pkg.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "include/cv32e40p_apu_core_pkg.sv"]]

add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "mini_kraken.srcs/sources_1/new/pulp_soc_defines.sv"]]

# Minimal peripheral interface needed by cutie_hwpe_wrap.
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "mini_kraken.srcs/sources_1/imports/cluster_rtl/pulp_interfaces.sv"]]

# Common cell packages (needed by various imports)
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/common_cells/cf_math_pkg.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/common_cells/cb_filter_pkg.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/common_cells/cdc_reset_ctrlr_pkg.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/common_cells/ecc_pkg.sv"]]

# Common cells
add_files -fileset sources_1 [glob [file normalize [file join $repo_root "ips/common_cells/*.sv"]]]

# Deprecated common_cells modules required by cluster RTL (e.g. pulp_sync)
add_files -fileset sources_1 [glob [file normalize [file join $repo_root "ips/common_cells/deprecated/*.sv"]]]

# CV32E40P core
add_files -fileset sources_1 [glob [file normalize [file join $repo_root "ips/cv32e40p/*.sv"]]]

# AXI + register interface
set axi_files [glob [file normalize [file join $repo_root "ips/axi/*.sv"]]]
set axi_files_filtered [list]
foreach f $axi_files {
    set tail [file tail $f]
    if {![string match "*test*" $tail] && $tail ne "axi_pkg.sv"} {
        lappend axi_files_filtered $f
    }
}
add_files -fileset sources_1 $axi_files_filtered
add_files -fileset sources_1 [glob [file normalize [file join $repo_root "ips/register_interface/*.sv"]]]
# Deprecated register_interface modules required by SNE (apb_to_reg)
add_files -fileset sources_1 [glob [file normalize [file join $repo_root "ips/register_interface/deprecated/*.sv"]]]

# Use the simpler proven cluster top as the SoC processing element.
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/pulp_cluster/pulp_cluster_top.sv"]]

# CUTIE support
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "include/cutie_conf.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/cutie/conf/cutie_enums.sv"]]
add_files -fileset sources_1 [glob [file normalize [file join $repo_root "ips/cutie/rtl/*.sv"]]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "mini_kraken.srcs/sources_1/new/cutie_hwpe_wrap.sv"]]

# SNE support (separate track from CUTIE)
# Include path for SNE internal headers (evt_stream_macros.svh, archi_sne.svh, etc.)
set_property include_dirs [concat [get_property include_dirs [current_fileset]] \
  [file normalize [file join $repo_root "ips/sne/rtl/include"]]] [current_fileset]

# SNE IP source files (order matches Bender.yml)
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_conf_reg/evt_reggen/generated/bus_clock_reg_pkg.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_conf_reg/evt_reggen/generated/engine_clock_reg_pkg.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_conf_reg/evt_reggen/generated/system_clock_reg_pkg.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_misc_components/sne_pkg.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_misc_components/sne_evt_stream_pkg.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_misc_components/evt_cdc_fifo.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_misc_components/evt_data_arbiter.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_misc_components/evt_fifo.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_misc_components/evt_refresh_insert.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_misc_components/evt_spike_filter.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_misc_components/evt_stream_dynamic_fork.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_misc_components/evt_stream_selector.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_misc_components/evt_synchronizer.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_misc_components/evt_time_inserter.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_misc_components/memory_wrapped_fifo.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_misc_components/sne_interface.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_crossbar/evt_arbiter.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_crossbar/evt_crossbar.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_crossbar/evt_crossbar_dst_dev.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_crossbar/evt_crossbar_src_dev.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_crossbar/evt_fork.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_crossbar/evt_synaptic_crossbar.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_decoder/evt_decoder.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_decoder/evt_engine_router.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_decoder/evt_global_router.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_dp/evt_dp_group.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_dp/evt_engine.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_dp/evt_filter.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_dp/evt_mapper.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_dp/evt_time_unit.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_memory_sequencer/evt_counter.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_memory_sequencer/evt_floating_kernel.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_memory_sequencer/evt_mapper_src.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_memory_sequencer/evt_memory_sequencer.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_memory_sequencer/evt_memory_subsystem.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_memory_sequencer/evt_opt_sequencer.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_memory_sequencer/evt_sequencer.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_memory_sequencer/evt_status_memory.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_memory_sequencer/evt_weight_fifo.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_memory_sequencer/evt_kernel_memory.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_memory_sequencer/evt_kernel_memory_wrapper.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_streamer/evt_streamer.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_streamer/evt_streamer_ctrl.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/neurons/alif_neuron.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/neurons/evt_neuron_dp.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_misc_components/sne_sram.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_misc_components/evt_sram_wrap.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_conf_reg/evt_reggen/evt_reggen_bus_cdc.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_conf_reg/evt_reggen/evt_reggen_engine_cdc.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_conf_reg/evt_reggen/evt_reggen_system_cdc.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_conf_reg/evt_reggen/evt_reggen.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_conf_reg/evt_reggen/generated/bus_clock_reg_top.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_conf_reg/evt_reggen/generated/engine_clock_reg_top.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/evt_conf_reg/evt_reggen/generated/system_clock_reg_top.sv"]]
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "ips/sne/rtl/sne_complex.sv"]]

# SNE wrapper (bridges XBAR_PERIPH_BUS → APB + TCDM stub)
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "mini_kraken.srcs/sources_1/new/sne_wrap.sv"]]

# Top
add_files -norecurse -fileset sources_1 [file normalize [file join $repo_root "rtl/kraken_soc_func.sv"]]

# Constraints for the reduced functional top
add_files -fileset constrs_1 [file normalize [file join $repo_root "constraints/kraken_soc_func_synth.xdc"]]

set_property top kraken_soc_func [current_fileset]

update_compile_order -fileset sources_1

synth_design -top kraken_soc_func -part $part

report_utilization -file [file normalize [file join $proj_dir "kraken_soc_func_utilization_synth.rpt"]]
report_timing_summary -file [file normalize [file join $proj_dir "kraken_soc_func_timing_synth.rpt"]] -delay_type max -max_paths 10
write_checkpoint -force [file normalize [file join $proj_dir "kraken_soc_func_synth.dcp"]]

puts "========================================"
puts "Functional Kraken (scaffold) synthesis done"
puts "Project: $project_name"
puts "Top: kraken_soc_func"
puts "========================================"
