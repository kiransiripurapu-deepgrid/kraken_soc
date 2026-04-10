// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

/*
 * cluster_timer_wrap.sv
 * Davide Rossi <davide.rossi@unibo.it>
 * Antonio Pullini <pullinia@iis.ee.ethz.ch>
 * Igor Loi <igor.loi@unibo.it>
 * Francesco Conti <fconti@iis.ee.ethz.ch>
 */

module cluster_timer_wrap
#(
  parameter int unsigned ID_WIDTH  = 2
)
(
  input  logic          clk_i,
  input  logic          rst_ni,
  input  logic          ref_clk_i,
  
  XBAR_PERIPH_BUS.Slave periph_slave,
  
  input  logic          event_lo_i,
  input  logic          event_hi_i,
  
  output logic          irq_lo_o,
  output logic          irq_hi_o,
  
  output logic          busy_o
);
   
  // Functional-synthesis stub: keep the peripheral bus responsive, but do not
  // implement the real timer unit yet.
  assign irq_lo_o = 1'b0;
  assign irq_hi_o = 1'b0;
  assign busy_o   = 1'b0;

  assign periph_slave.gnt     = 1'b1;
  assign periph_slave.r_valid = 1'b1;
  assign periph_slave.r_opc   = '0;
  assign periph_slave.r_id    = '0;
  assign periph_slave.r_rdata = 32'h0;
   
endmodule
