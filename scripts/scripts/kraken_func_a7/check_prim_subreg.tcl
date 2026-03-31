open_project C:/Users/kiran/fpga_project/mini_kraken/scripts/kraken_func_a7/kraken_func_a7.xpr
proc ensure_file_in_fileset {fileset_name file_path} {
  set normalized_path [file normalize $file_path]
  set existing_file [get_files -quiet $normalized_path]
  if {[llength $existing_file] == 0} {
    puts "Adding $normalized_path to $fileset_name"
    add_files -fileset $fileset_name $normalized_path
    set existing_file [get_files -quiet $normalized_path]
  }
  return $existing_file
}
set f [ensure_file_in_fileset sources_1 C:/Users/kiran/fpga_project/mini_kraken/mini_kraken.srcs/sources_1/new/prim_subreg.sv]
puts "FOUND=[llength $f]"
puts "NAME=[get_property NAME $f]"
puts "USED_SYNTH=[get_property USED_IN_SYNTHESIS $f]"
close_project
exit
