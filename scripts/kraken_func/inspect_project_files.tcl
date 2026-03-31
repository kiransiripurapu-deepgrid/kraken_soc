open_project C:/Users/kiran/fpga_project/mini_kraken/scripts/kraken_func/kraken_func.xpr
foreach f [list \
  "C:/Users/kiran/fpga_project/mini_kraken/include/cv32e40p_pkg.sv" \
  "C:/Users/kiran/fpga_project/mini_kraken/ips/cv32e40p/cv32e40p_core.sv" \
  "C:/Users/kiran/fpga_project/mini_kraken/mini_kraken.srcs/sources_1/new/riscv_core_stub.sv" \
  "C:/Users/kiran/fpga_project/mini_kraken/mini_kraken.srcs/sources_1/new/icache_hier_top.sv" \
  "C:/Users/kiran/fpga_project/mini_kraken/mini_kraken.srcs/sources_1/new/cluster_clock_gating.sv" \
] {
  set gf [get_files -all $f]
  puts "FILE=$f"
  puts "  MATCHES=[llength $gf]"
  if {[llength $gf] > 0} {
    foreach obj $gf {
      catch {puts "  IS_ENABLED=[get_property IS_ENABLED $obj]"}
      catch {puts "  USED_IN=[get_property USED_IN $obj]"}
      catch {puts "  FILE_TYPE=[get_property FILE_TYPE $obj]"}
    }
  }
}
close_project
