# Basic C Firmware Bring-Up

This is the minimal firmware path for `kraken_soc_func` behavioral simulation.

## Build

Requires a RISC-V bare-metal toolchain such as `riscv32-unknown-elf-gcc`.

```bash
cd sw/basic
make
```

This generates:
- `hello.elf`
- `hello.bin`
- `hello.mem`

## Run In Vivado Simulation

From the repo root:

```bash
vivado -mode batch -source run_basic_c_sim.tcl
```

To run a different firmware image:

```bash
MEM_FILE=./sw/dronet_v3/dronet_v3_driver.mem vivado -mode batch -source run_basic_c_sim.tcl
```

## What success looks like

At the end of simulation, the testbench prints:

```text
FIRMWARE_BOOT_CHECK: PASS
```

That means the CPU fetched changing instructions from the preloaded SRAM image.

The current example firmware exercises the data/MMIO path by writing:
- `MMIO_SCRATCH0` at `0x1A100000`
- `MMIO_SCRATCH1` at `0x1A100004`
- `MMIO_GPIO` at `0x1A100008`
- `MMIO_UART_TX` at `0x1A10000C`

Readable monitor registers include:
- `0x1A100030` CUTIE status
- `0x1A100034` CUTIE readback

## Current limitation

This is still a minimal bring-up platform, but it now has:
- instruction SRAM
- data SRAM
- a tiny MMIO/status block
- a separate DroNet-oriented CUTIE driver flow under `sw/dronet_v3`
