open_project kraken_func_A7_8_slices_Sne.xpr
set out [open "fifo_status.txt" "w"]

puts $out "=== get_files matches for fifo_v3.sv ==="
set matches [get_files -all -quiet *fifo_v3.sv]
puts $out "count=[llength $matches]"
foreach f $matches {
  puts $out "file=$f"
  foreach p {FILE_TYPE IS_ENABLED IS_GLOBAL_INCLUDE USED_IN_SIMULATION USED_IN_SYNTHESIS USED_IN_IMPLEMENTATION} {
    if {![catch {set v [get_property $p $f]}]} {
      puts $out "  $p=$v"
    }
  }
}

puts $out "=== sim_1 files ==="
set simfs [get_files -of_objects [get_filesets sim_1]]
puts $out "count=[llength $simfs]"
foreach f $simfs {
  if {[string match "*fifo_v3.sv" $f] || [string match "*LUCA.sv" $f] || [string match "*kraken_soc_func_tb.sv" $f]} {
    puts $out "sim_file=$f"
  }
}

puts $out "=== compile order (sources_1) fifo/luca/tb ==="
set co [get_files -compile_order sources -used_in simulation]
foreach f $co {
  if {[string match "*fifo_v3.sv" $f] || [string match "*LUCA.sv" $f] || [string match "*kraken_soc_func_tb.sv" $f]} {
    puts $out "co_file=$f"
  }
}

close $out
close_project
exit 0
