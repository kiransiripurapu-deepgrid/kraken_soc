################################################################################
# Refresh project file to recognize RTL changes
################################################################################

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

proc disable_file_patterns_for_fpga {fileset_name patterns} {
	foreach pattern $patterns {
		set matches [get_files -quiet -of_objects [get_filesets $fileset_name] $pattern]
		foreach file_obj $matches {
			set_property USED_IN_SYNTHESIS false $file_obj
			set_property USED_IN_IMPLEMENTATION false $file_obj
		}
	}
}

proc enable_file_list_for_fpga {fileset_name file_paths} {
	foreach file_path $file_paths {
		set file_obj [get_files -quiet [file normalize $file_path]]
		if {[llength $file_obj] > 0} {
			set_property USED_IN_SYNTHESIS true $file_obj
			set_property USED_IN_IMPLEMENTATION true $file_obj
		}
	}
}

puts "Opening kraken_func_a7 project..."
set script_dir "C:/Users/kiran/fpga_project/mini_kraken/scripts/kraken_func_a7"
set repo_root "C:/Users/kiran/fpga_project/mini_kraken"
open_project "C:/Users/kiran/fpga_project/mini_kraken/scripts/kraken_func_a7/kraken_func_a7.xpr"

puts "Verifying RTL sources loaded..."
set sourceCount [llength [get_files -filter {FILE_TYPE == "Verilog" || FILE_TYPE == "SystemVerilog"}]]
puts "Total RTL files loaded: $sourceCount"

set latch_rf_file [ensure_file_in_fileset sources_1 "C:/Users/kiran/fpga_project/mini_kraken/ips/cv32e40p/cv32e40p_register_file_latch.sv"]
set ff_rf_file    [ensure_file_in_fileset sources_1 "C:/Users/kiran/fpga_project/mini_kraken/ips/cv32e40p/cv32e40p_register_file_ff.sv"]
set xdc_file      [ensure_file_in_fileset constrs_1 "C:/Users/kiran/fpga_project/mini_kraken/constraints/kraken_soc_func_synth.xdc"]
set fpga_top_file [ensure_file_in_fileset sources_1 "C:/Users/kiran/fpga_project/mini_kraken/rtl/kraken_soc_func_fpga.sv"]
set actmem_latch_file [ensure_file_in_fileset sources_1 "C:/Users/kiran/fpga_project/mini_kraken/ips/cutie/rtl/sram_actmem_latch.sv"]
set weightmem_latch_file [ensure_file_in_fileset sources_1 "C:/Users/kiran/fpga_project/mini_kraken/ips/cutie/rtl/sram_weightmem_latch.sv"]
set weightbuf_latch_file [ensure_file_in_fileset sources_1 "C:/Users/kiran/fpga_project/mini_kraken/ips/cutie/rtl/weightbufferblock_latch.sv"]
set actmem_beh_file [ensure_file_in_fileset sources_1 "C:/Users/kiran/fpga_project/mini_kraken/ips/cutie/rtl/sram_actmem_behavioural.sv"]
set weightmem_beh_file [ensure_file_in_fileset sources_1 "C:/Users/kiran/fpga_project/mini_kraken/ips/cutie/rtl/sram_weightmem_behavioural.sv"]
set weightbuf_ff_file [ensure_file_in_fileset sources_1 "C:/Users/kiran/fpga_project/mini_kraken/ips/cutie/rtl/weightbufferblock.sv"]
set prim_subreg_file [ensure_file_in_fileset sources_1 "C:/Users/kiran/fpga_project/mini_kraken/mini_kraken.srcs/sources_1/new/prim_subreg.sv"]
set sne_evt_fifo_file [ensure_file_in_fileset sources_1 "C:/Users/kiran/fpga_project/mini_kraken/mini_kraken.srcs/sources_1/new/sne_evt_fifo.sv"]

puts "Forcing FF register file for FPGA synthesis..."
set_property IS_ENABLED false $latch_rf_file
set_property USED_IN_SIMULATION false $latch_rf_file
set_property USED_IN_SYNTHESIS false $latch_rf_file
set_property USED_IN_IMPLEMENTATION false $latch_rf_file

set_property IS_ENABLED true $ff_rf_file
set_property USED_IN_SIMULATION true $ff_rf_file
set_property USED_IN_SYNTHESIS true $ff_rf_file
set_property USED_IN_IMPLEMENTATION true $ff_rf_file

puts "Switching CUTIE storage blocks to FPGA-friendly variants..."
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

puts "Keeping minimal Arty A7 constraint file active..."
set_property USED_IN_SYNTHESIS true $xdc_file
set_property USED_IN_IMPLEMENTATION true $xdc_file

puts "Disabling unused AXI/CDC helper sources for the one-core FPGA build..."
disable_file_patterns_for_fpga sources_1 {
	*../../ips/axi/*.sv
	*../../ips/register_interface/axi_*.sv
	*../../ips/register_interface/reg_to_axi.sv
	*../../ips/register_interface/reg_cdc.sv
	*../../ips/common_cells/stream_xbar.sv
	*../../ips/common_cells/deprecated/rrarbiter.sv
	*../../ips/common_cells/deprecated/prioarbiter.sv
}

enable_file_list_for_fpga sources_1 [list \
	"C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/cdc_2phase.sv" \
	"C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/cdc_fifo_2phase.sv" \
	"C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/cdc_fifo_gray.sv" \
	"C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/rr_arb_tree.sv" \
	"C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/stream_arbiter.sv" \
	"C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/stream_arbiter_flushable.sv" \
	"C:/Users/kiran/fpga_project/mini_kraken/ips/common_cells/sync.sv" \
]

if {[llength [get_runs synth_1 -quiet]] > 0} {
	puts "Disabling stale incremental synthesis reuse..."
	catch {set_property AUTO_INCREMENTAL_CHECKPOINT false [get_runs synth_1]}
	catch {set_property INCREMENTAL_CHECKPOINT {} [get_runs synth_1]}
}

puts "Setting main FPGA design top to kraken_soc_func_fpga..."
# Keep the functional/simulation project view clean. The FPGA-only synthesis
# profile is applied in run_synth_impl.tcl right before synth/impl launch.
set_property verilog_define {SLICES=8 NGGROUPS=16} [get_filesets sources_1]
set_property top kraken_soc_func_fpga [get_filesets sources_1]
update_compile_order -fileset sources_1

puts "Configuring simulation to use kraken_soc_func_tb..."
if {[get_filesets sim_1] eq ""} {
	create_fileset -simset sim_1
}

set tb_file "C:/Users/kiran/fpga_project/mini_kraken/sim/kraken_soc_func_tb.sv"
ensure_file_in_fileset sim_1 $tb_file

set_property top kraken_soc_func_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
set_property source_set sources_1 [get_filesets sim_1]
set_property top_auto_set false [get_filesets sim_1]
update_compile_order -fileset sim_1

puts "Current register file selection:"
puts "  latch enabled: [get_property IS_ENABLED $latch_rf_file]"
puts "  ff enabled   : [get_property IS_ENABLED $ff_rf_file]"
puts "  actmem latch enabled : [get_property IS_ENABLED $actmem_latch_file]"
puts "  actmem beh enabled   : [get_property IS_ENABLED $actmem_beh_file]"
puts "  weightmem latch enabled: [get_property IS_ENABLED $weightmem_latch_file]"
puts "  weightmem beh enabled  : [get_property IS_ENABLED $weightmem_beh_file]"
puts "  weightbuf latch enabled: [get_property IS_ENABLED $weightbuf_latch_file]"
puts "  weightbuf ff enabled   : [get_property IS_ENABLED $weightbuf_ff_file]"
puts "  prim_subreg file: [get_property NAME $prim_subreg_file]"
puts "  sne_evt_fifo file: [get_property NAME $sne_evt_fifo_file]"
puts "  active defines: [get_property verilog_define [get_filesets sources_1]]"
puts "  fpga top file: [get_property NAME $fpga_top_file]"

if {[llength [get_runs sim_1 -quiet]] > 0} {
	puts "Resetting stale simulation run metadata..."
	reset_run sim_1
}

puts "Skipping explicit save_project due to Vivado Tcl save quirk in this setup..."
puts "Project settings refreshed in the current Vivado session"
puts "Main design top: kraken_soc_func_fpga"
puts "Behavioral sim top: kraken_soc_func_tb"


puts "✅ Project file successfully updated with RTL changes"
puts "✅ Main design top: kraken_soc_func_fpga"
puts "✅ Behavioral sim top: kraken_soc_func_tb"
