###############################################################################
# Arty A7-200T constraints for kraken_soc_func_fpga
# Device: XC7A200T-1SBG484C (SBG484 package, speed grade -1)
#
# NOTE ON PIN ASSIGNMENTS:
#   The Arty A7-200T uses the SBG484 484-ball package, which has DIFFERENT
#   physical pin locations from the CSG324 package used on the Arty A7-100T.
#   The PACKAGE_PIN values below are for the Arty A7-200T / XC7A200T-SBG484.
#   Verify these against the official Digilent Arty A7-200T Master XDC before
#   running implementation.  Synthesis does not enforce pin locations, so
#   synthesis will pass regardless; implementation will DRC-check them.
#
# Arty A7-200T board connections (SBG484 package):
#   100 MHz sys clock : H16
#   BTN0 (reset)      : D9   -- verify against board schematic
#   LD0..LD3 (LEDs)   : H17, K15, J13, N14 -- verify against board schematic
###############################################################################

## Clock input: 50 MHz target for easier closure on the functional FPGA build
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports clk_i]
create_clock -name sys_clk_pin -period 20.000 -waveform {0.000 10.000} [get_ports clk_i]

## Active-low reset button (BTN0, Arty A7-200T / SBG484: D9 -- verify with board XDC)
set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS33} [get_ports rst_ni]
set_property PULLUP true [get_ports rst_ni]
set_false_path -from [get_ports rst_ni]

## Board-visible status outputs on the four user LEDs (Arty A7-200T / SBG484)
## Verify pin assignments against the official Digilent Arty A7-200T Master XDC
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {led_o[0]}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {led_o[1]}]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {led_o[2]}]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {led_o[3]}]

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
