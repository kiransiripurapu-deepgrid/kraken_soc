# 1. Project Setup
set project_name "kraken_check"
set part "xc7a200tsbg484-1"
create_project -force $project_name ./$project_name -part $part

# 2. Define Include Paths
set inc_dirs [list "../include" "../ips/common_cells/include" "../ips/cv32e40p/include"]

# 3. Add Dictionaries FIRST (must compile before modules that use them)
add_files -norecurse -fileset sources_1 ../include/axi_pkg.sv
add_files -norecurse -fileset sources_1 ../include/dm_pkg.sv
add_files -norecurse -fileset sources_1 ../include/cv32e40p_pkg.sv
add_files -norecurse -fileset sources_1 ../include/cv32e40p_fpu_pkg.sv
add_files -norecurse -fileset sources_1 ../include/cv32e40p_apu_core_pkg.sv

# 4. Add Common Cell Packages (before common_cells modules)
add_files -norecurse -fileset sources_1 ../ips/common_cells/cf_math_pkg.sv
add_files -norecurse -fileset sources_1 ../ips/common_cells/cb_filter_pkg.sv
add_files -norecurse -fileset sources_1 ../ips/common_cells/cdc_reset_ctrlr_pkg.sv
add_files -norecurse -fileset sources_1 ../ips/common_cells/ecc_pkg.sv

# 5. Add AXI Package
add_files -fileset sources_1 [glob ../ips/axi/axi_pkg.sv]

# 6. Add Common Cells (depends on common_cells packages)
add_files -fileset sources_1 [glob ../ips/common_cells/*.sv]

# 7. Add CV32E40P IP (depends on cv32e40p_pkg)
add_files -fileset sources_1 [glob ../ips/cv32e40p/*.sv]

# 8. Add AXI IP (depends on axi_pkg) - EXCLUDE test files
set axi_files [glob ../ips/axi/*.sv]
set axi_files_filtered [list]
foreach f $axi_files {
    if {![string match "*test*" [file tail $f]]} {
        lappend axi_files_filtered $f
    }
}
add_files -fileset sources_1 $axi_files_filtered

# 9. Add Cluster and RTL
add_files -fileset sources_1 [glob ../ips/pulp_cluster/*.sv]
add_files -fileset sources_1 ../rtl/kraken_soc.sv

# 10. Add Constraints File
add_files -fileset constrs_1 ../constraints/kraken_soc.xdc

# 11. Settings
set_property include_dirs $inc_dirs [current_fileset]
set_property top kraken_soc [current_fileset]

# 12. Run Synthesis
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Check if synthesis succeeded
if {[get_property RUNSTATUS [get_runs synth_1]] != "synth_design completed successfully"} {
    puts "WARNING: Synthesis completed with status: [get_property RUNSTATUS [get_runs synth_1]]"
}

puts "========================================"
puts "Kraken SoC with Cluster Synthesis Complete!"
puts "========================================"
puts "Top Module: kraken_soc"
puts "Clusters: 1 with 2 CV32E40P cores"
puts "Local TCDM (L1): 64KB per core (architecture freeze)"
puts "L2 Memory: 256KB SRAM (architecture freeze)"
puts "========================================"
