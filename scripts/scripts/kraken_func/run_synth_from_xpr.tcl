set this_dir [file normalize [file dirname [info script]]]
set proj_path [file normalize [file join $this_dir "kraken_func.xpr"]]

open_project $proj_path
source [file normalize [file join $this_dir "project_fixup_sources.tcl"]]

set_property top kraken_soc_func [get_filesets sources_1]
update_compile_order -fileset sources_1

reset_run synth_1
launch_runs synth_1 -scripts_only

close_project
