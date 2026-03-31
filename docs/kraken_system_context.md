# Project Prompt: Building the Kraken SoC (PULP-based)

## Objective
We are building a custom RISC-V SoC named **Kraken**. It is based on a "Surgical Extraction" of the PULPissimo and Compute Cluster platforms. Instead of using the full PULP build system (Bender/IPApprox), we are manually "joining" the IPs in VS Code to maintain a clean, readable, and Vivado-compatible RTL structure.

## Current Workspace Architecture
The project is located at `C:\Users\kiran\fpga_project\mini_kraken\`.

### Directory Structure
- **`/rtl`** — Contains `kraken_soc.sv` (Our Top-Level "Joining" file).
- **`/include`** — Global SystemVerilog packages and headers:
  - `axi_pkg.sv`
  - `dm_pkg.sv`
  - `cv32e40p_pkg.sv`
  - `cv32e40p_apu_core_pkg.sv`
  - `cv32e40p_fpu_pkg.sv`
- **`/include/axi`** — Specific AXI header files:
  - `typedef.svh`
  - `assign.svh`
  - `port.svh`
- **`/include/common_cells`** — Common cell library headers:
  - `assertions.svh`
  - `registers.svh`
- **`/ips/cv32e40p`** — The RISC-V "Brain" (Fabric Controller core):
  - `cv32e40p_core.sv` (Main core module)
  - `cv32e40p_obi_interface.sv` (OBI protocol interface)
  - Related pipeline and control modules
- **`/ips/axi`** — AXI Interconnect modules (Crossbars, bridges, shims):
  - `axi_xbar.sv` (AXI crossbar)
  - `axi_to_mem.sv` (OBI/AXI protocol converter)
  - `axi_lite_to_axi.sv` (AXI-Lite to AXI bridge)
  - Various AXI utilities and shims
- **`/ips/common_cells`** — Standard library cells:
  - `sram.sv` (SRAM wrapper)
  - `fifo_v3.sv` (FIFO implementations)
  - `rr_arb_tree.sv` (Round-robin arbiters)
  - Other utility modules
- **`/ips/register_interface`** — Register interface modules
- **`/scripts`** — Tcl scripts for automated Vivado synthesis/elaboration:
  - `build_kraken.tcl`
  - Supporting scripts

## Source of IP (Reference)
Original files were extracted from: `C:\Users\kiran\pulpissimo-fresh\.bender\git\checkouts\`.

## Current Development Phase: "Joining Phase"

We need to accomplish the following:

### 1. Instantiate the Fabric Controller
- Link the `cv32e40p_core` to the main AXI bus
- Ensure proper clock, reset, and interrupt connectivity

### 2. Protocol Conversion
- Use the `axi_to_mem` shim to bridge the core's OBI (Open Bus Interface) to the AXI Interconnect
- Ensure proper data width, address width, and ID width conversion

### 3. Cluster Integration
- Prepare to instantiate the pulp_cluster and map its TCDM and AXI slave ports
- Plan L1 data cache and shared memory hierarchy

### 4. Memory Mapping
- Point the AXI crossbar to a 4KB L2 SRAM (`sram.sv`) for initial instruction fetch
- Set up proper address decoder for memory regions

## Your AI Collaborator's Task

### Code Generation
When asked to instantiate a module, I will:
- Look at the port lists in the `/ips` directory to ensure perfect mapping
- Check parameter defaults and custom configurations
- Generate clean, synthesizable SystemVerilog

### Dependency Tracking
When you use a type (like `id_t` or `addr_t`), I will:
- Remind you to check the AXI typedef macros in `/include/axi/`
- Verify that all necessary packages are included
- Ensure type consistency across module boundaries

### Error Debugging
If Vivado returns a Synth 8-xxx error, I will:
- Help you trace which package or header is missing from `build_kraken.tcl`
- Check for undefined interfaces or signals
- Verify parameter compatibility between modules

### Code Style
All generated code will:
- Follow clean, parameterized SystemVerilog conventions
- Use modern interfaces where possible
- Include proper documentation and inline comments
- Be compatible with Vivado synthesis tools

## Key Files to Reference

| File | Purpose |
|------|---------|
| `rtl/kraken_soc.sv` | Top-level SoC instantiation and joining logic |
| `include/axi_pkg.sv` | AXI type definitions and parameters |
| `include/cv32e40p_pkg.sv` | CV32E40P core type definitions |
| `ips/cv32e40p/cv32e40p_core.sv` | RISC-V core (main compute engine) |
| `ips/axi/axi_to_mem.sv` | OBI to AXI protocol converter |
| `ips/axi/axi_xbar.sv` | AXI crossbar for interconnect |
| `ips/common_cells/sram.sv` | Synchronous RAM wrapper |
| `scripts/build_kraken.tcl` | Vivado synthesis build script |

## Next Steps
Ready to assist with:
- Port mapping and module instantiation
- Debugging compilation errors
- Creating joining logic in `kraken_soc.sv`
- Optimizing interconnect architecture
