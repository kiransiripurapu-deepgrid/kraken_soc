################################################################################
# Vivado Synthesis & Implementation Script for kraken_func_A7_8_slices_Sne
# Usage: vivado -mode batch -source run_synth_impl.tcl
################################################################################

puts "=========================================="
puts "Opening kraken_func_A7_8_slices_Sne project..."
puts "=========================================="

proc ensure_file_in_fileset {fileset_name file_path} {
    set normalized_path $file_path
    set existing_file [get_files -quiet $normalized_path]
    if {[llength $existing_file] == 0} {
        puts "Adding $normalized_path to $fileset_name"
        add_files -fileset $fileset_name $normalized_path
        set existing_file [get_files -quiet $normalized_path]
    }
    return $existing_file
}

set script_dir "C:/Users/kiran/fpga_project/mini_kraken/scripts/kraken_func_A7_8_slices_Sne"
set repo_root "C:/Users/kiran/fpga_project/mini_kraken"
set project_path "C:/Users/kiran/fpga_project/mini_kraken/scripts/kraken_func_A7_8_slices_Sne/kraken_func_A7_8_slices_Sne.xpr"
if {[llength [get_projects -quiet]] > 0} {
    puts "Closing already-open project before batch flow..."
    close_project
}
open_project $project_path

set latch_rf_path "C:/Users/kiran/fpga_project/mini_kraken/ips/cv32e40p/cv32e40p_register_file_latch.sv"
set ff_rf_path    "C:/Users/kiran/fpga_project/mini_kraken/ips/cv32e40p/cv32e40p_register_file_ff.sv"
set xdc_path      "C:/Users/kiran/fpga_project/mini_kraken/constraints/kraken_soc_func_synth.xdc"
set fpga_top_path "C:/Users/kiran/fpga_project/mini_kraken/rtl/kraken_soc_func_fpga.sv"
set actmem_latch_path "C:/Users/kiran/fpga_project/mini_kraken/ips/cutie/rtl/sram_actmem_latch.sv"
set weightmem_latch_path "C:/Users/kiran/fpga_project/mini_kraken/ips/cutie/rtl/sram_weightmem_latch.sv"
set weightbuf_latch_path "C:/Users/kiran/fpga_project/mini_kraken/ips/cutie/rtl/weightbufferblock_latch.sv"
set actmem_beh_path "C:/Users/kiran/fpga_project/mini_kraken/ips/cutie/rtl/sram_actmem_behavioural.sv"
set weightmem_beh_path "C:/Users/kiran/fpga_project/mini_kraken/ips/cutie/rtl/sram_weightmem_behavioural.sv"
set weightbuf_ff_path "C:/Users/kiran/fpga_project/mini_kraken/ips/cutie/rtl/weightbufferblock.sv"
set prim_subreg_path "C:/Users/kiran/fpga_project/mini_kraken/DeepGrid_D100.srcs/sources_1/new/prim_subreg.sv"
set sne_evt_fifo_path "C:/Users/kiran/fpga_project/mini_kraken/DeepGrid_D100.srcs/sources_1/new/sne_evt_fifo.sv"

set latch_rf_file [get_files -quiet $latch_rf_path]
set ff_rf_file    [get_files -quiet $ff_rf_path]
set xdc_file      [get_files -quiet $xdc_path]
set fpga_top_file [get_files -quiet $fpga_top_path]
set actmem_latch_file [get_files -quiet $actmem_latch_path]
set weightmem_latch_file [get_files -quiet $weightmem_latch_path]
set weightbuf_latch_file [get_files -quiet $weightbuf_latch_path]
set actmem_beh_file [get_files -quiet $actmem_beh_path]
set weightmem_beh_file [get_files -quiet $weightmem_beh_path]
set weightbuf_ff_file [get_files -quiet $weightbuf_ff_path]
set prim_subreg_file [ensure_file_in_fileset sources_1 $prim_subreg_path]
set sne_evt_fifo_file [ensure_file_in_fileset sources_1 $sne_evt_fifo_path]

if {[llength $latch_rf_file] == 0 || [llength $ff_rf_file] == 0 || [llength $xdc_file] == 0 || [llength $fpga_top_file] == 0 ||
    [llength $actmem_latch_file] == 0 || [llength $weightmem_latch_file] == 0 || [llength $weightbuf_latch_file] == 0 ||
    [llength $actmem_beh_file] == 0 || [llength $weightmem_beh_file] == 0 || [llength $weightbuf_ff_file] == 0 ||
    [llength $prim_subreg_file] == 0 || [llength $sne_evt_fifo_file] == 0} {
    puts "ERROR: expected key project files are missing"
    puts "  latch rf: $latch_rf_path"
    puts "  ff rf   : $ff_rf_path"
    puts "  xdc     : $xdc_path"
    puts "  fpga top: $fpga_top_path"
    puts "  actmem latch : $actmem_latch_path"
    puts "  weightmem latch : $weightmem_latch_path"
    puts "  weightbuf latch : $weightbuf_latch_path"
    puts "  actmem beh : $actmem_beh_path"
    puts "  weightmem beh : $weightmem_beh_path"
    puts "  weightbuf ff : $weightbuf_ff_path"
    puts "  prim_subreg : $prim_subreg_path"
    puts "  sne_evt_fifo : $sne_evt_fifo_path"
    error "Missing required project files"
}

proc disable_file_patterns_for_fpga {fileset_name patterns} {
    foreach pattern $patterns {
        set matches [get_files -quiet -of_objects [get_filesets $fileset_name] $pattern]
        foreach file_obj $matches {
            set_property USED_IN_SYNTHESIS false $file_obj
            set_property USED_IN_IMPLEMENTATION false $file_obj
        }
    }
}

proc disable_file_list_for_fpga {file_paths} {
    foreach file_path $file_paths {
        set file_obj [get_files -quiet [file normalize $file_path]]
        if {[llength $file_obj] > 0} {
            set_property USED_IN_SYNTHESIS false $file_obj
            set_property USED_IN_IMPLEMENTATION false $file_obj
        }
    }
}

proc enable_file_list_for_fpga {file_paths} {
    foreach file_path $file_paths {
        set file_obj [get_files -quiet [file normalize $file_path]]
        if {[llength $file_obj] > 0} {
            set_property USED_IN_SYNTHESIS true $file_obj
            set_property USED_IN_IMPLEMENTATION true $file_obj
        }
    }
}

puts "Re-applying FPGA-safe project settings..."
set_property IS_ENABLED false $latch_rf_file
set_property USED_IN_SIMULATION false $latch_rf_file
set_property USED_IN_SYNTHESIS false $latch_rf_file
set_property USED_IN_IMPLEMENTATION false $latch_rf_file
set_property IS_ENABLED true $ff_rf_file
set_property USED_IN_SIMULATION true $ff_rf_file
set_property USED_IN_SYNTHESIS true $ff_rf_file
set_property USED_IN_IMPLEMENTATION true $ff_rf_file

set_property IS_ENABLED false $actmem_latch_file
set_property USED_IN_SIMULATION false $actmem_latch_file
set_property USED_IN_SYNTHESIS false $actmem_latch_file
set_property USED_IN_IMPLEMENTATION false $actmem_latch_file

set_property IS_ENABLED false $weightmem_latch_file
set_property USED_IN_SIMULATION false $weightmem_latch_file
set_property USED_IN_SYNTHESIS false $weightmem_latch_file
set_property USED_IN_IMPLEMENTATION false $weightmem_latch_file

set_property IS_ENABLED false $weightbuf_latch_file
set_property USED_IN_SIMULATION false $weightbuf_latch_file
set_property USED_IN_SYNTHESIS false $weightbuf_latch_file
set_property USED_IN_IMPLEMENTATION false $weightbuf_latch_file

set_property IS_ENABLED true $actmem_beh_file
set_property USED_IN_SIMULATION true $actmem_beh_file
set_property USED_IN_SYNTHESIS true $actmem_beh_file
set_property USED_IN_IMPLEMENTATION true $actmem_beh_file

set_property IS_ENABLED true $weightmem_beh_file
set_property USED_IN_SIMULATION true $weightmem_beh_file
set_property USED_IN_SYNTHESIS true $weightmem_beh_file
set_property USED_IN_IMPLEMENTATION true $weightmem_beh_file

set_property IS_ENABLED true $weightbuf_ff_file
set_property USED_IN_SIMULATION true $weightbuf_ff_file
set_property USED_IN_SYNTHESIS true $weightbuf_ff_file
set_property USED_IN_IMPLEMENTATION true $weightbuf_ff_file
set_property USED_IN_SYNTHESIS true $xdc_file
set_property USED_IN_IMPLEMENTATION true $xdc_file
set_property verilog_define {KRAKEN_FPGA_SYNTH_PROFILE SLICES=8 NGGROUPS=16} [get_filesets sources_1]
set_property top kraken_soc_func_fpga [get_filesets sources_1]
disable_file_patterns_for_fpga sources_1 {
    *../../ips/axi/*.sv
    *../../ips/register_interface/axi_*.sv
    *../../ips/register_interface/reg_to_axi.sv
    *../../ips/register_interface/reg_cdc.sv
    *../../ips/common_cells/stream_xbar.sv
    *../../ips/common_cells/deprecated/rrarbiter.sv
    *../../ips/common_cells/deprecated/prioarbiter.sv
}
disable_file_list_for_fpga [glob -nocomplain [file normalize "../../ips/axi/*.sv"]]
disable_file_list_for_fpga [list \
    "C:/Users/kiran/fpga_project/mini_kraken/ips/register_interface/axi_lite_to_reg.sv" \
    "C:/Users/kiran/fpga_project/mini_kraken/ips/register_interface/axi_to_reg_v2.sv" \
    "C:/Users/kiran/fpga_project/mini_kraken/ips/register_interface/reg_cdc.sv" \
    "C:/Users/kiran/fpga_project/mini_kraken/ips/register_interface/reg_to_axi.sv" \
    "C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/stream_xbar.sv" \
    "C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/deprecated/rrarbiter.sv" \
    "C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/deprecated/prioarbiter.sv" \
]
enable_file_list_for_fpga [list \
    "C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/cdc_2phase.sv" \
    "C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/cdc_fifo_2phase.sv" \
    "C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/cdc_fifo_gray.sv" \
    "C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/rr_arb_tree.sv" \
    "C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/stream_arbiter.sv" \
    "C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/stream_arbiter_flushable.sv" \
    "C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/sync.sv" \
]
if {[llength [get_filesets sim_1 -quiet]] > 0} {
    set_property top kraken_soc_func_tb [get_filesets sim_1]
    set_property source_set sources_1 [get_filesets sim_1]
}
catch {set_property AUTO_INCREMENTAL_CHECKPOINT false [get_runs synth_1]}
catch {set_property INCREMENTAL_CHECKPOINT {} [get_runs synth_1]}
catch {set_property strategy Flow_RuntimeOptimized [get_runs synth_1]}
catch {set_property STEPS.SYNTH_DESIGN.ARGS.DIRECTIVE RuntimeOptimized [get_runs synth_1]}
catch {set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY rebuilt [get_runs synth_1]}
catch {set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]}
catch {set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]}
catch {set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]}
catch {set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]}
catch {set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]}
catch {set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]}
catch {set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]}
catch {set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]}
update_compile_order -fileset sources_1
puts "Skipping explicit save_project due to Vivado Tcl save quirk in this setup..."

puts "Register file selection before launch:"
puts "  latch enabled: [get_property IS_ENABLED $latch_rf_file]"
puts "  ff enabled   : [get_property IS_ENABLED $ff_rf_file]"
puts "  actmem latch enabled : [get_property IS_ENABLED $actmem_latch_file]"
puts "  actmem beh enabled   : [get_property IS_ENABLED $actmem_beh_file]"
puts "  weightmem latch enabled: [get_property IS_ENABLED $weightmem_latch_file]"
puts "  weightmem beh enabled  : [get_property IS_ENABLED $weightmem_beh_file]"
puts "  weightbuf latch enabled: [get_property IS_ENABLED $weightbuf_latch_file]"
puts "  weightbuf ff enabled   : [get_property IS_ENABLED $weightbuf_ff_file]"
puts "  prim_subreg file       : [get_property NAME $prim_subreg_file]"
puts "  sne_evt_fifo file      : [get_property NAME $sne_evt_fifo_file]"
puts "  synth defines: [get_property verilog_define [get_filesets sources_1]]"
puts "  design top   : [get_property top [get_filesets sources_1]]"
puts "  fpga top file: [get_property NAME $fpga_top_file]"

puts "\n=========================================="
puts "Verifying RTL sources..."
puts "=========================================="
set sourceCount [llength [get_files -filter {FILE_TYPE == "Verilog" || FILE_TYPE == "SystemVerilog"}]]
puts "Total RTL files: $sourceCount"

if {$sourceCount < 200} {
    puts "WARNING: Expected about 250 RTL files, found $sourceCount"
    puts "Check file paths and relative references"
}

puts "\n=========================================="
puts "Cleaning previous synthesis run..."
puts "=========================================="
reset_run synth_1
reset_run impl_1

puts "\n=========================================="
puts "Starting SYNTHESIS..."
puts "=========================================="
puts "Device: [get_property PART [current_project]]"
puts "Top Module: [get_property top [get_filesets sources_1]]"
puts "Constraints: [get_files -filter {FILE_TYPE == "XDC" || FILE_TYPE == "XDC Constraints"}]"
puts "=========================================="

launch_runs synth_1 -jobs 1

puts "\nWaiting for synthesis to finish (this may take 30-45 minutes)..."
wait_on_run synth_1

set synthState [get_property STATE [get_runs synth_1]]
if {$synthState eq ""} {
    set synthState [get_property STATUS [get_runs synth_1]]
}
puts "\nSynthesis State: $synthState"

if {[string match "*complete*" [string tolower $synthState]]} {
    puts "SYNTHESIS SUCCESSFUL"
} else {
    puts "SYNTHESIS FAILED: $synthState"
    error "Synthesis failed: $synthState"
}

puts "\n=========================================="
puts "Generating synthesis reports..."
puts "=========================================="

open_run synth_1
report_utilization -file synth_utilization.rpt
report_timing_summary -file synth_timing.rpt
report_power -file synth_power.rpt

puts "Reports generated:"
puts "  - synth_utilization.rpt"
puts "  - synth_timing.rpt"
puts "  - synth_power.rpt"

puts "\n=========================================="
puts "Starting IMPLEMENTATION..."
puts "=========================================="

launch_runs impl_1 -jobs 1

puts "\nWaiting for implementation to finish (this may take 30-45 minutes)..."
wait_on_run impl_1

set implState [get_property STATE [get_runs impl_1]]
puts "\nImplementation State: $implState"

if {$implState eq "implement_design complete!"} {
    puts "IMPLEMENTATION SUCCESSFUL"
} else {
    puts "Implementation completed with state: $implState"
}

puts "\n=========================================="
puts "Generating implementation reports..."
puts "=========================================="

open_run impl_1
report_utilization -file impl_utilization.rpt
report_timing_summary -file impl_timing.rpt
report_timing -max_paths 50 -sort_by group -file impl_timing_top50.rpt
report_power -file impl_power.rpt
report_route_status -file route_status.rpt
report_drc -file impl_drc.rpt
report_methodology -file impl_methodology.rpt

puts "Reports generated:"
puts "  - impl_utilization.rpt"
puts "  - impl_timing.rpt"
puts "  - impl_timing_top50.rpt"
puts "  - impl_power.rpt"
puts "  - route_status.rpt"
puts "  - impl_drc.rpt"
puts "  - impl_methodology.rpt"

puts "\n=========================================="
puts "Generating bitstream..."
puts "=========================================="

set timing_summary [report_timing_summary -return_string]
set wns_value 0.0
if {[regexp {WNS\(ns\):\s*(-?[0-9]+\.[0-9]+)} $timing_summary -> wns_match]} {
    set wns_value $wns_match
}

if {$wns_value < 0.0} {
    puts "Skipping bitstream generation because timing is not met."
    puts "  WNS = $wns_value ns"
    puts "Fix timing first, then rerun for bitstream."
    return
}

launch_runs impl_1 -to_step write_bitstream -jobs 1
wait_on_run impl_1

set finalState [get_property STATE [get_runs impl_1]]

if {[string match "*write_bitstream*" $finalState] || [string match "*complete*" $finalState]} {
    puts "BITSTREAM GENERATION SUCCESSFUL"
} else {
    puts "Bitstream may not have been generated"
}

set bitstream_path [file normalize "./kraken_func_A7_8_slices_Sne.runs/impl_1/kraken_soc_func_fpga.bit"]
if {[file exists $bitstream_path]} {
    set bitSize [file size $bitstream_path]
    puts "\nBitstream file verified:"
    puts "   Size: [expr {$bitSize / 1024}] KB"
    puts "   Location: $bitstream_path"
} else {
    puts "\nWARNING: Bitstream file not found at $bitstream_path"
}

puts "\n=========================================="
puts "SYNTHESIS & IMPLEMENTATION COMPLETE"
puts "=========================================="
puts "All reports and artifacts generated"
puts "Ready for bitstream download"
puts "=========================================="
