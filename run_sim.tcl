#!/usr/bin/env tclsh

# ============================================================================
# Vivado Behavioral Simulation Script for kraken_soc_func
# 
# Usage: vivado -mode batch -source run_sim.tcl
# ============================================================================

# Open the project
open_project mini_kraken.xpr

# Create simulation fileset if it doesn't exist
if {![get_filesets -quiet sim_1]} {
    create_fileset -simset sim_1
}

# Add testbench to simulation fileset
add_files -fileset sim_1 sim/kraken_soc_func_tb.sv

# Set simulation properties
set_property -name {top} -value {kraken_soc_func_tb} -objects [get_filesets sim_1]
set_property -name {top_lib} -value {xil_defaultlib} -objects [get_filesets sim_1]

# Compile simulation
puts "Compiling simulation..."
get_filesets sim_1
ipx_export_simulation_files -ipx_def_repo_path . -package_inst_def_repo_path . -design $(get_property top [get_filesets sim_1]) -fileset sim_1

# Launch simulation
puts "Launching simulation..."
launch_simulation -simset sim_1 -mode behavioral

# Run simulation
puts "Running simulation for 10 microseconds..."
run 10us

# Close simulation
close_sim

# Generate report
puts "Simulation complete. Check kraken_soc_func.vcd for waveforms"

# Exit
quit
