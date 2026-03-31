# DroNet v3 Driver Bring-Up

This directory adds a CUTIE-oriented firmware path that is closer to a
DroNet-style workload than the original `sw/basic/hello.c` smoke test.

The main hardware project remains:
- `scripts/kraken_func_a7/kraken_func_a7.xpr`

What it does today:
- loads a small activation payload through the CUTIE activation-memory MMIO port
- loads a small weight payload through the CUTIE weight-memory MMIO port
- configures one CUTIE layer
- queues the layer with `STORE_TO_FIFO`
- starts computation
- polls for completion through the live CUTIE status register
- leaves observable progress in the SoC MMIO scratch/GPIO/UART registers

What it does not claim yet:
- full DroNet v3 weight dump
- full multi-layer network execution
- validated accuracy against a real DroNet dataset

## Vendored assets

The repo now vendors the exported DORY network bundle at:
- `sw/dronet_v3/assets/tiny_pulp_dronet_v3_dory`

These files were copied from:
- `C:/Users/kiran/fpga_project/pulp_workspace/pulp-dronet/tiny-pulp-dronet-v3/drone-applications/gap8-dronet-app/tiny-pulp-dronet-v3/DORY_network`

The vendored bundle includes:
- `inputs.hex`
- per-layer `*_weights.hex` files
- exported `inc/` headers
- exported `src/` sources

These assets are now available inside the main `mini_kraken` / `kraken_func_a7`
workspace for follow-on conversion and integration work.

## Build

```bash
cd sw/dronet_v3
make
```

This generates:
- `dronet_v3_driver.elf`
- `dronet_v3_driver.bin`
- `dronet_v3_driver.mem`

## Run

From the repo root in WSL:

```bash
bash scripts/run_ff_rf_sim_wsl.sh /mnt/c/Users/kiran/fpga_project/mini_kraken/sw/dronet_v3/dronet_v3_driver.mem
```

Or in Vivado Tcl:

```tcl
set ::env(MEM_FILE) "C:/Users/kiran/fpga_project/mini_kraken/sw/dronet_v3/dronet_v3_driver.mem"
source C:/Users/kiran/fpga_project/mini_kraken/run_basic_c_sim.tcl
```

## Success signals

In simulation you should see:
- initial MMIO writes for scratch/UART
- CUTIE activation and weight write pulses
- CUTIE `busy` transition high then low
- `evt=01` on normal completion

The current expected DroNet smoke summary is:
- `dronet_scratch0=YES`
- `dronet_scratch1=YES`
- `uart_D=YES`
- `cutie_cfg_write=YES`
- `cutie_start_write=YES`
- `cutie_done_evt=YES`
- `cutie_timeout_evt=NO`
- `profile_checkpoint=PASS`
- `FIRMWARE_BOOT_CHECK: PASS`

## Current verification status

What is verified right now:
- the vendored DroNet export files are present in the repo
- the `dronet_v3_driver.mem` firmware still runs correctly in the
  `kraken_func_a7` simulation flow
- CUTIE starts and completes normally in functional sim
- the current smoke geometry is intentionally compact:
  - `IMG_W = 4`
  - `IMG_H = 4`
  - `NI = 1`
  - `NO = 4`
  - `stride = 1`

What is not wired yet:
- parsing the vendored `inputs.hex` and real layer `*_weights.hex` files directly
  from firmware
- executing the full exported multi-layer DroNet network end-to-end
- proving numerical accuracy against the original DroNet export

## Compatibility audit

The vendored export is a real DORY DroNet bundle, but it is not directly runnable on the
current `kraken_func_a7` CUTIE integration.

Use this audit command from the repo root:

```bash
python3 scripts/check_dronet_v3_compat.py
```

This checks the vendored DroNet export against the live CUTIE profile and reports the
current blockers, including:
- CUTIE image-size limits versus DroNet's `200x200` input
- fixed CUTIE kernel size versus DroNet's mixed `5x5`, `3x3`, and `1x1` stages
- exported DORY byte-oriented weights versus CUTIE's ternary-packed weight format
