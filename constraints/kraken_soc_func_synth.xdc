###############################################################################
# DeepGrid_D100 bring-up constraints for kraken_soc_func_fpga
# Device: XC7A200T-1SBG484C (SBG484 package, speed grade -1)
#
# These pins were chosen from Vivado's valid package-pin list for the current
# part so implementation can complete cleanly on the present project. The
# previous H16/D9/H17/K15/J13/N14 assignments were not valid for this package
# and caused:
#   - DRC NSTD-1 / UCIO-1 on clk_i and led_o[1:2]
#   - DRC RTSTAT-1 due to unrouted rst_ni_IBUF
#
# If this design is later moved onto a specific board, remap these PACKAGE_PIN
# values to that board's actual clock/reset/LED connections.
###############################################################################

## Package-valid clock-capable input used for the current bring-up build
set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS33} [get_ports clk_i]
create_clock -name sys_clk_pin -period 20.000 -waveform {0.000 10.000} [get_ports clk_i]

## Active-low reset input on a package-valid user IO
set_property -dict {PACKAGE_PIN Y17 IOSTANDARD LVCMOS33} [get_ports rst_ni]
set_property PULLUP true [get_ports rst_ni]
set_false_path -from [get_ports rst_ni]

## Four package-valid user outputs used for the demo LEDs
set_property -dict {PACKAGE_PIN Y16  IOSTANDARD LVCMOS33} [get_ports {led_o[0]}]
set_property -dict {PACKAGE_PIN AA16 IOSTANDARD LVCMOS33} [get_ports {led_o[1]}]
set_property -dict {PACKAGE_PIN AB16 IOSTANDARD LVCMOS33} [get_ports {led_o[2]}]
set_property -dict {PACKAGE_PIN AB17 IOSTANDARD LVCMOS33} [get_ports {led_o[3]}]

## Board-level configuration
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLDOWN [current_design]

## Modest output delay model for the constrained board-visible outputs
set_output_delay -clock sys_clk_pin -min 0.5 [get_ports {led_o[0]}]
set_output_delay -clock sys_clk_pin -min 0.5 [get_ports {led_o[1]}]
set_output_delay -clock sys_clk_pin -min 0.5 [get_ports {led_o[2]}]
set_output_delay -clock sys_clk_pin -min 0.5 [get_ports {led_o[3]}]
set_output_delay -clock sys_clk_pin -max 2.5 [get_ports {led_o[0]}]
set_output_delay -clock sys_clk_pin -max 2.5 [get_ports {led_o[1]}]
set_output_delay -clock sys_clk_pin -max 2.5 [get_ports {led_o[2]}]
set_output_delay -clock sys_clk_pin -max 2.5 [get_ports {led_o[3]}]
