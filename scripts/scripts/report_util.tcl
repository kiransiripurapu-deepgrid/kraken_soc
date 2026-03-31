open_project ./kraken_check/kraken_check.xpr
# Read the synthesized design
if {[get_runs synth_1 -quiet] ne ""} {
    open_run synth_1
} else {
    puts "ERROR: No synthesis run found"
    exit 1
}
report_utilization -file ./kraken_check/kraken_util.rpt
puts "Utilization report generated"
exit
