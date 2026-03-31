set this_dir [file normalize [file dirname [info script]]]
set proj_path [file normalize [file join $this_dir "kraken_func.xpr"]]

open_project $proj_path
source [file normalize [file join $this_dir "project_fixup_sources.tcl"]]

set_property top kraken_soc_func [get_filesets sources_1]
update_compile_order -fileset sources_1

reset_run synth_1

# Reduce peak memory: keep hierarchy and use runtime-optimised strategy
set_property strategy "Flow_RuntimeOptimized" [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]

launch_runs synth_1 -jobs 2
wait_on_run synth_1

close_project
