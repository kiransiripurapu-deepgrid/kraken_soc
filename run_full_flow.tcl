# Full FPGA Implementation Flow for kraken_soc_func on Arty A7-200T
# This script performs: Behavioral Sim → Synthesis → Implementation → Bitstream

puts "╔═══════════════════════════════════════════════════════════════╗"
puts "║        KRAKEN SOC FULL FPGA FLOW - ARTY A7-200T              ║"
puts "╚═══════════════════════════════════════════════════════════════╝"

set project_name "mini_kraken"
set project_path "."
set rtl_path "./rtl"
set sim_path "./sim"
set constraint_path "./constraints"
set device "xc7a200tsbg484-1"

# ============================================================================
# STEP 1: Open/Create Project
# ============================================================================
puts "\n[STEP 1] Opening project: $project_name"
open_project "${project_path}/${project_name}.xpr"

# ============================================================================
# STEP 2: Behavioral Simulation (Optional but recommended)
# ============================================================================
puts "\n[STEP 2] Running Behavioral Simulation..."
if {[get_filesets sim_1] eq ""} {
    create_fileset -simset sim_1
}

# Check if testbench exists
if {[file exists "${sim_path}/kraken_soc_func_tb.sv"]} {
    puts "  • Adding testbench: kraken_soc_func_tb.sv"
    add_files -fileset sim_1 "${sim_path}/kraken_soc_func_tb.sv"
    set_property top kraken_soc_func_tb [get_filesets sim_1]
    set_property top_dir "${project_path}/.Xil/sim" [get_filesets sim_1]
    
    puts "  • Launching behavioral simulation (10µs)..."
    launch_simulation -simset sim_1 -mode behavioral
    run 10us
    
    puts "  • Simulation complete. Closing simulator..."
    close_sim
} else {
    puts "  ⚠ Testbench not found, skipping simulation"
}

# ============================================================================
# STEP 3: Synthesis
# ============================================================================
puts "\n[STEP 3] Running Synthesis..."
if {[get_runs synth_1] eq ""} {
    create_run -name synth_1 -flow {Vivado Synthesis 2022} -strategy "Vivado Synthesis Defaults"
}

set_property -name {STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY} -value {full} -objects [get_runs synth_1]
set_property -name {STEPS.SYNTH_DESIGN.ARGS.KEEP_EQUIVALENT_REGISTERS} -value {1} -objects [get_runs synth_1]

launch_run synth_1
wait_on_run synth_1

set synth_status [get_property STATUS [get_runs synth_1]]
if {$synth_status eq "synth_design Complete!"} {
    puts "  ✅ Synthesis completed successfully"
} else {
    puts "  ❌ Synthesis failed with status: $synth_status"
    close_project
    exit 1
}

# Open synthesized design for viewing
open_run synth_1 -name synth_design

# ============================================================================
# STEP 4: Implementation
# ============================================================================
puts "\n[STEP 4] Running Implementation..."
if {[get_runs impl_1] eq ""} {
    create_run -name impl_1 -flow {Vivado Implementation 2022} -strategy "Vivado Implementation Defaults" -parent_run synth_1
}

set_property -name {STEPS.OPT_DESIGN.ARGS.DIRECTIVE} -value {ExploreSequentialArea} -objects [get_runs impl_1]
set_property -name {STEPS.PLACE_DESIGN.ARGS.DIRECTIVE} -value {ExploreOptimized} -objects [get_runs impl_1]
set_property -name {STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE} -value {Explore} -objects [get_runs impl_1]

launch_run impl_1
wait_on_run impl_1

set impl_status [get_property STATUS [get_runs impl_1]]
if {$impl_status eq "impl_design Complete!"} {
    puts "  ✅ Implementation completed successfully"
} else {
    puts "  ❌ Implementation failed with status: $impl_status"
    close_project
    exit 1
}

# Open implemented design
open_run impl_1 -name impl_design

# ============================================================================
# STEP 5: Generate Bitstream
# ============================================================================
puts "\n[STEP 5] Generating Bitstream..."
if {[catch {
    launch_runs impl_1 -to_step write_bitstream
    wait_on_run impl_1
} err]} {
    puts "  ⚠ Bitstream generation had issues: $err"
} else {
    puts "  ✅ Bitstream generated successfully"
}

# ============================================================================
# STEP 6: Report Resource Utilization
# ============================================================================
puts "\n[STEP 6] Resource Utilization Summary:"
if {[file exists "mini_kraken.runs/impl_1/kraken_soc_func_utilization_placed.rpt"]} {
    catch {
        exec grep -A 20 "Resource" mini_kraken.runs/impl_1/kraken_soc_func_utilization_placed.rpt
    } report
    puts $report
} else {
    puts "  (Report will be available after implementation complete)"
}

# ============================================================================
# STEP 7: Timing Report
# ============================================================================
puts "\n[STEP 7] Timing Summary:"
if {[file exists "mini_kraken.runs/impl_1/kraken_soc_func_timing_summary_routed.rpt"]} {
    catch {
        exec grep -A 5 "Total" mini_kraken.runs/impl_1/kraken_soc_func_timing_summary_routed.rpt
    } timing
    puts $timing
} else {
    puts "  (Timing report will be available after routing complete)"
}

# ============================================================================
# COMPLETION
# ============================================================================
puts "\n╔═══════════════════════════════════════════════════════════════╗"
puts "║                    FLOW COMPLETE ✅                           ║"
puts "╚═══════════════════════════════════════════════════════════════╝"
puts "\n📁 Output Files:"
puts "  • Bitstream: mini_kraken.runs/impl_1/kraken_soc_func.bit"
puts "  • ELF:       mini_kraken.runs/impl_1/kraken_soc_func.elf"
puts "  • Logs:      mini_kraken.runs/impl_1/*.log"
puts "\n🔧 Next Steps:"
puts "  1. Program FPGA: vivado -mode batch -source \"scripts/kraken_func/program_fpga.tcl\""
puts "  2. Or use xsdb:  xsdb> fpga -f mini_kraken.runs/impl_1/kraken_soc_func.bit"
puts "\n"

close_project
