// ----------------------------------------------------------------------
//
// File: cutie_conf.sv
//
// Created: 06.05.2022
//
// Copyright (C) 2022, ETH Zurich and University of Bologna.
//
// Author: Moritz Scherer, ETH Zurich
//
// SPDX-License-Identifier: SHL-0.51
//
// Copyright and related rights are licensed under the Solderpad Hardware License,
// Version 0.51 (the "License"); you may not use this file except in compliance with
// the License. You may obtain a copy of the License at http://solderpad.org/licenses/SHL-0.51.
// Unless required by applicable law or agreed to in writing, software, hardware and materials
// distributed under this License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and limitations under the License.
//
// ----------------------------------------------------------------------


package cutie_params;

`ifdef KRAKEN_FPGA_SYNTH_PROFILE
   // Reduced FPGA synthesis profile.
   // Keep the one-core SoC and CUTIE path buildable on Arty A7 while the
   // larger DroNet-oriented dimensions remain available for behavioral sim.
   parameter int unsigned N_I = 16; // # MAX. INPUT CHANNELS
   parameter int unsigned N_O = 16; // # MAX. OUTPUT CHANNELS, SHOULD EQUAL N_I

   // SYSTEM ARCHITECTURE PARAMETERS
   parameter int unsigned K = 5; // KERNEL SIZE, INTERPRETED AS QUADRATIC, I.E. (KxK)
   parameter int unsigned IMAGEWIDTH = 16;
   parameter int unsigned IMAGEHEIGHT = 16;
   parameter int unsigned TCN_WIDTH = 8;
   parameter int unsigned NUMACTMEMBANKSETS = 2; // double buffering only
   parameter int unsigned NUM_LAYERS = 2;
`else
   // Functional-simulation profile.
   // These values lift the image/layer limits toward the exported DroNet v3
   // workload so the main kraken_func_a7 project can model a more realistic
   // network shape in behavioral simulation.
   //
   // Note: this profile is much less FPGA-friendly than the reduced Arty A7
   // bring-up profile that was previously used.
   parameter int unsigned N_I = 32; // # MAX. INPUT CHANNELS
   parameter int unsigned N_O = 32; // # MAX. OUTPUT CHANNELS, SHOULD EQUAL N_I

   // SYSTEM ARCHITECTURE PARAMETERS
   parameter int unsigned K = 3; // KERNEL SIZE, INTERPRETED AS QUADRATIC, I.E. (KxK)
   parameter int unsigned IMAGEWIDTH = 200; // align with exported DroNet input size
   parameter int unsigned IMAGEHEIGHT = 200;
   parameter int unsigned TCN_WIDTH = 16;
   parameter int unsigned NUMACTMEMBANKSETS = 2; // double buffering only
   parameter int unsigned NUM_LAYERS = 15; // exported DroNet v3 stage count
`endif

   // HARDWARE IMPLEMENTATION PARAMETERS
   parameter int unsigned WEIGHT_STAGGER = 2; // NUMBER OF WORDS PER MAX. CHANNEL
   parameter int unsigned PIPELINEDEPTH = 2;
   parameter int unsigned WEIGHTMEMORYBANKDEPTH = NUM_LAYERS*WEIGHT_STAGGER*K*K; // NUMBER OF WORDS PER WEIGHT MEMORY BANK

   // OCU POOL PARAMETERS
   parameter int unsigned POOLING_FIFODEPTH = IMAGEWIDTH/2;
   parameter int unsigned THRESHOLD_FIFODEPTH = NUM_LAYERS;
   parameter int unsigned LAYER_FIFODEPTH = NUM_LAYERS;

   parameter int unsigned WEIGHTBANKDEPTH = NUM_LAYERS*WEIGHT_STAGGER*K*K;
   parameter int unsigned USAGEWIDTH = POOLING_FIFODEPTH > 1 ? $clog2(POOLING_FIFODEPTH) : 1;

endpackage
