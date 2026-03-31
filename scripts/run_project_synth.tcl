open_project C:/Users/kiran/fpga_project/mini_kraken/scripts/kraken_func/kraken_func.xpr
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
set s [get_property STATUS [get_runs synth_1]]
puts "CODEx_SYNTH_STATUS=$s"
close_project
exit
