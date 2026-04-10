// Minimal PULP SoC defines required by the extracted cluster RTL.
//
// This repo contains a partial extraction of PULP IP for Vivado integration.
// The full upstream environment normally provides these macros via a common
// include. We keep this file minimal and aligned with the frozen architecture.

`ifndef PULP_SOC_DEFINES_SV
`define PULP_SOC_DEFINES_SV

// Architecture freeze
`define NB_CORES    8

// Reasonable defaults for the extracted cluster wrappers
`define NB_DMAS     4
`define NB_MPERIPHS 1
`define NB_SPERIPHS 13

`endif


