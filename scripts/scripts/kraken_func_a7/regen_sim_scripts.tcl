puts "Opening project..."
open_project kraken_func_a7.xpr

puts "Ensuring simulation top..."
set_property top kraken_soc_func_tb [get_filesets sim_1]
set_property top_auto_set false [get_filesets sim_1]
set_property source_set sources_1 [get_filesets sim_1]

set tb_file [file normalize "../../sim/kraken_soc_func_tb.sv"]
if {[llength [get_files -of_objects [get_filesets sim_1] $tb_file]] == 0} {
  add_files -fileset sim_1 $tb_file
}

puts "Resetting sim run..."
if {[llength [get_runs sim_1 -quiet]] > 0} {
  reset_run sim_1
}

puts "Generating simulation scripts only..."
launch_simulation -simset sim_1 -mode behavioral -scripts_only

puts "Saving and closing..."
save_project_as kraken_func_a7 -force
close_project
puts "Done"
exit 0
