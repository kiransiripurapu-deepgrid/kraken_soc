# add_sne_sources.tcl
#
# Run this in the Vivado Tcl console while kraken_func_a7 is open.
# Adds all SNE IP source files, defines, and include paths to the
# existing project WITHOUT recreating it.
#
# Usage (Vivado Tcl console):
#   source {C:/Users/kiran/fpga_project/mini_kraken/scripts/add_sne_sources.tcl}

set script_dir [file normalize [file dirname [info script]]]
set repo_root  [file normalize [file join $script_dir ".."]]

# ── 1. Add SNE include path ───────────────────────────────────────────────────
set sne_inc [file normalize [file join $repo_root "ips/sne/rtl/include"]]
set existing_incs [get_property include_dirs [current_fileset]]
if {[lsearch $existing_incs $sne_inc] < 0} {
    set_property include_dirs [concat $existing_incs $sne_inc] [current_fileset]
    puts "Added SNE include path: $sne_inc"
} else {
    puts "SNE include path already present."
}

# ── 2. Add SLICES / NGGROUPS defines ─────────────────────────────────────────
set existing_defs [get_property verilog_define [current_fileset]]
if {![string match "*SLICES*" $existing_defs]} {
    if {$existing_defs eq ""} {
        set_property verilog_define "SLICES=8 NGGROUPS=16" [current_fileset]
    } else {
        set_property verilog_define "$existing_defs SLICES=8 NGGROUPS=16" [current_fileset]
    }
    puts "Added verilog defines: SLICES=8 NGGROUPS=16"
} else {
    puts "SLICES define already present."
}

# ── 3. register_interface deprecated (apb_to_reg required by evt_reggen) ─────
set ri_dep_files [glob -nocomplain [file normalize \
    [file join $repo_root "ips/register_interface/deprecated/*.sv"]]]
if {[llength $ri_dep_files] > 0} {
    add_files -norecurse -fileset sources_1 $ri_dep_files
    puts "Added [llength $ri_dep_files] register_interface/deprecated file(s)."
} else {
    puts "WARNING: No files found in ips/register_interface/deprecated/"
}

# ── 4. SNE IP source files (Bender.yml order) ────────────────────────────────
set sne_files [list \
  "ips/sne/rtl/evt_conf_reg/evt_reggen/generated/bus_clock_reg_pkg.sv" \
  "ips/sne/rtl/evt_conf_reg/evt_reggen/generated/engine_clock_reg_pkg.sv" \
  "ips/sne/rtl/evt_conf_reg/evt_reggen/generated/system_clock_reg_pkg.sv" \
  "ips/sne/rtl/evt_misc_components/sne_pkg.sv" \
  "ips/sne/rtl/evt_misc_components/sne_evt_stream_pkg.sv" \
  "ips/sne/rtl/evt_misc_components/evt_cdc_fifo.sv" \
  "ips/sne/rtl/evt_misc_components/evt_data_arbiter.sv" \
  "ips/sne/rtl/evt_misc_components/evt_fifo.sv" \
  "ips/sne/rtl/evt_misc_components/evt_refresh_insert.sv" \
  "ips/sne/rtl/evt_misc_components/evt_spike_filter.sv" \
  "ips/sne/rtl/evt_misc_components/evt_stream_dynamic_fork.sv" \
  "ips/sne/rtl/evt_misc_components/evt_stream_selector.sv" \
  "ips/sne/rtl/evt_misc_components/evt_synchronizer.sv" \
  "ips/sne/rtl/evt_misc_components/evt_time_inserter.sv" \
  "ips/sne/rtl/evt_misc_components/memory_wrapped_fifo.sv" \
  "ips/sne/rtl/evt_misc_components/sne_interface.sv" \
  "ips/sne/rtl/evt_crossbar/evt_arbiter.sv" \
  "ips/sne/rtl/evt_crossbar/evt_crossbar.sv" \
  "ips/sne/rtl/evt_crossbar/evt_crossbar_dst_dev.sv" \
  "ips/sne/rtl/evt_crossbar/evt_crossbar_src_dev.sv" \
  "ips/sne/rtl/evt_crossbar/evt_fork.sv" \
  "ips/sne/rtl/evt_crossbar/evt_synaptic_crossbar.sv" \
  "ips/sne/rtl/evt_decoder/evt_decoder.sv" \
  "ips/sne/rtl/evt_decoder/evt_engine_router.sv" \
  "ips/sne/rtl/evt_decoder/evt_global_router.sv" \
  "ips/sne/rtl/evt_dp/evt_dp_group.sv" \
  "ips/sne/rtl/evt_dp/evt_engine.sv" \
  "ips/sne/rtl/evt_dp/evt_filter.sv" \
  "ips/sne/rtl/evt_dp/evt_mapper.sv" \
  "ips/sne/rtl/evt_dp/evt_time_unit.sv" \
  "ips/sne/rtl/evt_memory_sequencer/evt_counter.sv" \
  "ips/sne/rtl/evt_memory_sequencer/evt_floating_kernel.sv" \
  "ips/sne/rtl/evt_memory_sequencer/evt_mapper_src.sv" \
  "ips/sne/rtl/evt_memory_sequencer/evt_memory_sequencer.sv" \
  "ips/sne/rtl/evt_memory_sequencer/evt_memory_subsystem.sv" \
  "ips/sne/rtl/evt_memory_sequencer/evt_opt_sequencer.sv" \
  "ips/sne/rtl/evt_memory_sequencer/evt_sequencer.sv" \
  "ips/sne/rtl/evt_memory_sequencer/evt_status_memory.sv" \
  "ips/sne/rtl/evt_memory_sequencer/evt_weight_fifo.sv" \
  "ips/sne/rtl/evt_memory_sequencer/evt_kernel_memory.sv" \
  "ips/sne/rtl/evt_memory_sequencer/evt_kernel_memory_wrapper.sv" \
  "ips/sne/rtl/evt_streamer/evt_streamer.sv" \
  "ips/sne/rtl/evt_streamer/evt_streamer_ctrl.sv" \
  "ips/sne/rtl/neurons/alif_neuron.sv" \
  "ips/sne/rtl/neurons/evt_neuron_dp.sv" \
  "ips/sne/rtl/evt_misc_components/sne_sram.sv" \
  "ips/sne/rtl/evt_misc_components/evt_sram_wrap.sv" \
  "ips/sne/rtl/evt_conf_reg/evt_reggen/evt_reggen_bus_cdc.sv" \
  "ips/sne/rtl/evt_conf_reg/evt_reggen/evt_reggen_engine_cdc.sv" \
  "ips/sne/rtl/evt_conf_reg/evt_reggen/evt_reggen_system_cdc.sv" \
  "ips/sne/rtl/evt_conf_reg/evt_reggen/evt_reggen.sv" \
  "ips/sne/rtl/evt_conf_reg/evt_reggen/generated/bus_clock_reg_top.sv" \
  "ips/sne/rtl/evt_conf_reg/evt_reggen/generated/engine_clock_reg_top.sv" \
  "ips/sne/rtl/evt_conf_reg/evt_reggen/generated/system_clock_reg_top.sv" \
  "ips/sne/rtl/sne_complex.sv" \
]

set added 0
foreach rel $sne_files {
    set f [file normalize [file join $repo_root $rel]]
    if {[file exists $f]} {
        add_files -norecurse -fileset sources_1 $f
        incr added
    } else {
        puts "WARNING: missing $f"
    }
}
puts "Added $added SNE IP source files."

# ── 5. sne_wrap.sv (explicit, in case VerilogDir glob missed it) ──────────────
set sne_wrap [file normalize \
    [file join $repo_root "mini_kraken.srcs/sources_1/new/sne_wrap.sv"]]
add_files -norecurse -fileset sources_1 $sne_wrap

# ── 6. Refresh compile order ──────────────────────────────────────────────────
update_compile_order -fileset sources_1

puts ""
puts "========================================"
puts "SNE sources added to kraken_func_a7."
puts "Run synth_design or press the Run       "
puts "Synthesis button to rebuild."
puts "========================================"
