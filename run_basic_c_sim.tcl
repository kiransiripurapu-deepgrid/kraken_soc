set project_name "kraken_func_a7"
set project_dir "./scripts/kraken_func_a7"

if {[info exists ::env(MEM_FILE)] && $::env(MEM_FILE) ne ""} {
    set mem_file $::env(MEM_FILE)
} else {
    set mem_file "./sw/basic/hello.mem"
}

set sim_runtime "10us"
if {[string match "*dronet_v3_driver.mem" [file tail $mem_file]]} {
    set sim_runtime "50us"
}

if {![file exists $mem_file]} {
    puts "ERROR: firmware image not found at $mem_file"
    puts "Build it first with: make -C ./sw/basic"
    exit 1
}

open_project "${project_dir}/${project_name}.xpr"

set latch_rf_path [file normalize "./ips/cv32e40p/cv32e40p_register_file_latch.sv"]
set ff_rf_path    [file normalize "./ips/cv32e40p/cv32e40p_register_file_ff.sv"]
set latch_rf_file [get_files -quiet $latch_rf_path]
set ff_rf_file    [get_files -quiet $ff_rf_path]

if {[llength $latch_rf_file] > 0 && [llength $ff_rf_file] > 0} {
    puts "INFO: Forcing FF register file for simulation"
    set_property IS_ENABLED false $latch_rf_file
    set_property USED_IN_SIMULATION false $latch_rf_file
    set_property USED_IN_SYNTHESIS false $latch_rf_file
    set_property USED_IN_IMPLEMENTATION false $latch_rf_file

    set_property IS_ENABLED true $ff_rf_file
    set_property USED_IN_SIMULATION true $ff_rf_file
    set_property USED_IN_SYNTHESIS true $ff_rf_file
    set_property USED_IN_IMPLEMENTATION true $ff_rf_file
}

# Make sure behavioral sim does not inherit the FPGA-only synthesis profile.
set_property verilog_define {} [get_filesets sources_1]

set_property top kraken_soc_func_tb [get_filesets sim_1]
set_property xsim.simulate.runtime $sim_runtime [get_filesets sim_1]
set mem_file_abs [file normalize $mem_file]
set_property xsim.simulate.xsim.more_options [format {-testplusarg MEM_INIT_FILE=%s} $mem_file_abs] [get_filesets sim_1]
puts "INFO: Using firmware image [file normalize $mem_file]"
puts "INFO: Using simulation runtime $sim_runtime"
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

catch {close_sim -force}
set sim_dir [file normalize "${project_dir}/${project_name}.sim/sim_1/behav/xsim"]
if {[file exists $sim_dir]} {
    puts "INFO: Removing stale simulation directory $sim_dir"
    catch {file delete -force $sim_dir}
}

launch_simulation -simset sim_1 -mode behavioral
run $sim_runtime
close_sim
close_project
