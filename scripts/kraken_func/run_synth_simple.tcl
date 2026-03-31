#!/usr/bin/env tclsh
# Simple synthesis script for kraken_func
# Opens the project and runs synth_design with minimal overhead

set project_dir [file normalize [file dirname [info script]]]
cd $project_dir

# Open existing project
open_project kraken_func.xpr

# Get synthesis run
set synth_run [get_runs synth_1 -quiet]
if {$synth_run eq ""} {
    puts "ERROR: No synth_1 run found"
    exit 1
}

puts "Starting synthesis for kraken_soc_func..."
puts "Part: xc7a100tcsg324-1"

# Launch synthesis
reset_run $synth_run
set result [launch_runs $synth_run -jobs 4]
puts "Launch result: $result"

# Wait for completion
wait_on_run $synth_run
set status [get_property RUNSTATUS $synth_run]
puts "Final Status: $status"

# Report utilization if available
if {[file exists [file normalize [file join $synth_run kraken_soc_func_utilization_synth.rpt]]]} {
    puts "Utilization report generated successfully"
} else {
    puts "WARNING: Utilization report not found"
}

# Summary
puts ""
puts "======================================="
if {[string match "*successfully*" $status]} {
    puts "SUCCESS: Synthesis completed"
} else {
    puts "NOTE: Synthesis status=$status"
}
puts "======================================="

exit 0
