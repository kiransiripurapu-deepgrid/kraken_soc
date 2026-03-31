set proj_root C:/Users/kiran/fpga_project/mini_kraken
set fs [get_filesets sources_1]

proc maybe_remove_file {fs path} {
  set f [get_files -quiet -of_objects $fs $path]
  if {[llength $f] > 0} {
    remove_files -fileset $fs $f
  }
}

proc maybe_add_file {fs path} {
  if {![file exists $path]} {
    puts "WARNING: Missing file $path"
    return
  }
  set existing [get_files -quiet -of_objects $fs $path]
  if {[llength $existing] == 0} {
    add_files -norecurse -fileset $fs $path
  }
}

proc maybe_add_glob {fs pattern} {
  foreach path [lsort [glob -nocomplain $pattern]] {
    maybe_add_file $fs $path
  }
}

proc maybe_add_glob_filtered {fs pattern exclude_patterns} {
  foreach path [lsort [glob -nocomplain $pattern]] {
    set skip 0
    foreach ex $exclude_patterns {
      if {[string match $ex $path]} {
        set skip 1
        break
      }
    }
    if {!$skip} {
      maybe_add_file $fs $path
    }
  }
}

maybe_remove_file $fs "$proj_root/mini_kraken.srcs/sources_1/imports/cluster_rtl/axi2per_wrap.sv"
maybe_remove_file $fs "$proj_root/mini_kraken.srcs/sources_1/imports/cluster_rtl/per2axi_wrap.sv"
maybe_remove_file $fs "$proj_root/mini_kraken.srcs/sources_1/new/hci_core_intf.sv"
maybe_remove_file $fs "$proj_root/mini_kraken.srcs/sources_1/imports/cluster_rtl/pulp_cluster.sv"
maybe_remove_file $fs "$proj_root/mini_kraken.srcs/sources_1/imports/cluster_rtl/pulp_cluster_wrap.sv"

# Remove fallback stubs first; re-add only when no functional RTL exists.
foreach stub {
  C:/Users/kiran/fpga_project/mini_kraken/scripts/rtl_stubs/axi2per_wrap_stub.sv
  C:/Users/kiran/fpga_project/mini_kraken/scripts/rtl_stubs/per2axi_wrap_stub.sv
  C:/Users/kiran/fpga_project/mini_kraken/scripts/rtl_stubs/axi2mem_stub.sv
  C:/Users/kiran/fpga_project/mini_kraken/scripts/rtl_stubs/tc_clk_mux2.sv
} {
  maybe_remove_file $fs $stub
}

foreach path {
  C:/Users/kiran/fpga_project/mini_kraken/mini_kraken.srcs/sources_1/imports/cluster_rtl/axi2per_wrap.sv
  C:/Users/kiran/fpga_project/mini_kraken/mini_kraken.srcs/sources_1/imports/cluster_rtl/per2axi_wrap.sv
  C:/Users/kiran/fpga_project/mini_kraken/ips/pulp_cluster/pulp_cluster_top.sv
  C:/Users/kiran/fpga_project/mini_kraken/include/cutie_conf.sv
  C:/Users/kiran/fpga_project/mini_kraken/ips/cutie/conf/cutie_enums.sv
  C:/Users/kiran/fpga_project/pulp_workspace/pulp_cluster/.bender/git/checkouts/hwpe-stream-bc1f2d87c271f75a/rtl/hwpe_stream_package.sv
  C:/Users/kiran/fpga_project/pulp_workspace/pulp_cluster/.bender/git/checkouts/cluster_interconnect-9a146c2c6998a1b5/rtl/tcdm_interconnect/tcdm_interconnect_pkg.sv
  C:/Users/kiran/fpga_project/pulp_workspace/pulp_cluster/.bender/git/checkouts/hci-f956ddaaacdaf461/rtl/ecc/hci_ecc_manager_reg_pkg.sv
  C:/Users/kiran/fpga_project/mini_kraken/mini_kraken.srcs/sources_1/new/cutie_hwpe_wrap.sv
  C:/Users/kiran/fpga_project/mini_kraken/mini_kraken.srcs/sources_1/new/prim_subreg.sv
  C:/Users/kiran/fpga_project/mini_kraken/mini_kraken.srcs/sources_1/new/mchan.sv
  C:/Users/kiran/fpga_project/mini_kraken/mini_kraken.srcs/sources_1/new/cluster_control_unit.sv
  C:/Users/kiran/fpga_project/mini_kraken/mini_kraken.srcs/sources_1/new/event_unit_top.sv
} {
  maybe_add_file $fs $path
}

# Keep stubs only for modules not present in this workspace snapshot.
if {![file exists "$proj_root/mini_kraken.srcs/sources_1/imports/cluster_rtl/axi2mem.sv"]} {
  maybe_add_file $fs "C:/Users/kiran/fpga_project/mini_kraken/scripts/rtl_stubs/axi2mem_stub.sv"
}
if {![file exists "$proj_root/mini_kraken.srcs/sources_1/imports/cluster_rtl/tc_clk_mux2.sv"]} {
  maybe_add_file $fs "C:/Users/kiran/fpga_project/mini_kraken/scripts/rtl_stubs/tc_clk_mux2.sv"
}

maybe_add_glob_filtered $fs "$proj_root/ips/cutie/rtl/*.sv" [list *tb_* */tb/*]
maybe_add_glob $fs "C:/Users/kiran/fpga_project/pulp_workspace/pulp_cluster/.bender/git/checkouts/cluster_interconnect-9a146c2c6998a1b5/rtl/tcdm_interconnect/*.sv"
maybe_add_glob_filtered $fs "C:/Users/kiran/fpga_project/pulp_workspace/pulp_cluster/.bender/git/checkouts/hci-f956ddaaacdaf461/rtl/*.sv" [list *hci_package.sv]
maybe_add_glob_filtered $fs "C:/Users/kiran/fpga_project/pulp_workspace/pulp_cluster/.bender/git/checkouts/hci-f956ddaaacdaf461/rtl/*/*.sv" [list *hci_package.sv]
maybe_add_glob_filtered $fs "C:/Users/kiran/fpga_project/pulp_workspace/pulp_cluster/.bender/git/checkouts/hci-f956ddaaacdaf461/rtl/*/*/*.sv" [list *hci_package.sv]

set include_dirs [list \
  $proj_root/include \
  $proj_root/ips/common_cells/include \
  $proj_root/ips/cv32e40p/include \
  $proj_root/mini_kraken.srcs/sources_1/imports \
  $proj_root/ips/register_interface \
  $proj_root/mini_kraken.srcs/sources_1/new \
  C:/Users/kiran/fpga_project/pulp_workspace/pulp_cluster/.bender/git/checkouts/hwpe-stream-bc1f2d87c271f75a/rtl \
  C:/Users/kiran/fpga_project/pulp_workspace/pulp_cluster/.bender/git/checkouts/cluster_interconnect-9a146c2c6998a1b5/rtl/low_latency_interco \
  C:/Users/kiran/fpga_project/pulp_workspace/pulp_cluster/.bender/git/checkouts/cluster_interconnect-9a146c2c6998a1b5/rtl/peripheral_interco \
]
set_property include_dirs $include_dirs $fs
set_property top kraken_soc_func $fs

update_compile_order -fileset $fs
puts "Project sources_1 updated."
