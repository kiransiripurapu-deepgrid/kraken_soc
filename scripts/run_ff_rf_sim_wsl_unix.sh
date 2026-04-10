#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SIM_SRC_DIR="$ROOT_DIR/scripts/kraken_func_a7/kraken_func_a7.sim/sim_1/behav/xsim"
RUN_DIR_BASE="$ROOT_DIR/tmp_ff_rf_sim"
REUSE_RUN_DIR="${REUSE_RUN_DIR:-}"
if [[ -n "$REUSE_RUN_DIR" ]]; then
  RUN_DIR="$REUSE_RUN_DIR"
else
  RUN_STAMP="$(date +%Y%m%d_%H%M%S_%N)"
  RUN_DIR="${RUN_DIR_BASE}_${RUN_STAMP}"
fi
PRJ_SRC="$SIM_SRC_DIR/kraken_soc_func_tb_vlog.prj"
PRJ_RUN="$RUN_DIR/kraken_soc_func_tb_vlog.prj"
SNE_PRJ_FRAGMENT_SRC="$SIM_SRC_DIR/sne_vlog_fragment.prj"
TCL_SRC="$SIM_SRC_DIR/kraken_soc_func_tb.tcl"
TCL_RUN="$RUN_DIR/kraken_soc_func_tb.tcl"
GLBL_SRC="$SIM_SRC_DIR/glbl.v"
DEFAULT_MEM_FILE="$ROOT_DIR/sw/basic/hello.mem"
MEM_FILE="${1:-${MEM_FILE:-$DEFAULT_MEM_FILE}}"
MEM_FILE="$(realpath "$MEM_FILE")"

XVLOG_BAT='C:\Xilinx\Vivado\2022.2\bin\xvlog.bat'
XELAB_BAT='C:\Xilinx\Vivado\2022.2\bin\xelab.bat'
XSIM_BAT='C:\Xilinx\Vivado\2022.2\bin\xsim.bat'
CMD_EXE='/mnt/c/Windows/System32/cmd.exe'

run_cmd() {
  "$CMD_EXE" /C "$1"
}

if [[ ! -f "$MEM_FILE" ]]; then
  echo "ERROR: firmware image not found at $MEM_FILE" >&2
  echo "Build it first with: make -C $ROOT_DIR/sw/basic or pass a valid .mem path" >&2
  exit 1
fi

if [[ ! -f "$PRJ_SRC" || ! -f "$TCL_SRC" || ! -f "$GLBL_SRC" ]]; then
  echo "ERROR: expected generated simulation inputs are missing under $SIM_SRC_DIR" >&2
  exit 1
fi

mkdir -p "$RUN_DIR"

python3 - "$PRJ_SRC" "$PRJ_RUN" "$SIM_SRC_DIR" <<'PY'
import os
import re
import sys

src_prj, dst_prj, sim_src_dir = sys.argv[1:4]
pattern = re.compile(r'"([^"]+)"')
include_pattern = re.compile(r'(-i\s+)(\S+)')
sne_evt_fifo_rel = "../../../../../../DeepGrid_D100.srcs/sources_1/new/sne_evt_fifo.sv"

def to_windows_path(path: str) -> str:
    if path.startswith("/mnt/") and len(path) > 6:
        drive = path[5].upper()
        tail = path[6:].replace("/", "\\")
        return f"{drive}:{tail}"
    return path.replace("/", "\\")

with open(src_prj, "r", encoding="utf-8") as fin:
    src_lines = fin.readlines()

has_sne_evt_fifo = any("sne_evt_fifo.sv" in line for line in src_lines)

with open(dst_prj, "w", encoding="utf-8", newline="\n") as fout:
    for line in src_lines:
        def repl(match):
            path = match.group(1).replace("cv32e40p_register_file_latch.sv", "cv32e40p_register_file_ff.sv")
            if os.path.isabs(path):
                resolved = path
            else:
                resolved = os.path.normpath(os.path.join(sim_src_dir, path))
                resolved = to_windows_path(resolved)
            return f'"{resolved}"'
        line = pattern.sub(repl, line)
        if line.startswith("sv xil_defaultlib") and " -d SLICES=8 -d NGGROUPS=16 " not in line:
            line = line.replace("sv xil_defaultlib", "sv xil_defaultlib -d SLICES=8 -d NGGROUPS=16", 1)
        fout.write(line)
    if not has_sne_evt_fifo:
        sne_evt_fifo_path = os.path.normpath(os.path.join(sim_src_dir, sne_evt_fifo_rel))
        fout.write(f'sv xil_defaultlib "{to_windows_path(sne_evt_fifo_path)}"\n')
PY

if [[ -f "$SNE_PRJ_FRAGMENT_SRC" ]]; then
python3 - "$SNE_PRJ_FRAGMENT_SRC" "$PRJ_RUN" "$SIM_SRC_DIR" <<'PY'
import os
import re
import sys

src_frag, dst_prj, sim_src_dir = sys.argv[1:4]
pattern = re.compile(r'"([^"]+)"')
include_pattern = re.compile(r'(-i\s+)(\S+)')

def to_windows_path(path: str) -> str:
    if path.startswith("/mnt/") and len(path) > 6:
        drive = path[5].upper()
        tail = path[6:].replace("/", "\\")
        return f"{drive}:{tail}"
    return path.replace("/", "\\")

with open(src_frag, "r", encoding="utf-8") as fin, open(dst_prj, "a", encoding="utf-8", newline="\n") as fout:
    for line in fin:
        def repl(match):
            path = match.group(1)
            if os.path.isabs(path):
                resolved = path
            else:
                resolved = os.path.normpath(os.path.join(sim_src_dir, path))
            return f'"{to_windows_path(resolved)}"'
        line = pattern.sub(repl, line)
        def repl_inc(match):
            raw_path = match.group(2)
            quoted = raw_path.startswith('"') and raw_path.endswith('"')
            path = raw_path[1:-1] if quoted else raw_path
            is_windows_abs = len(path) >= 2 and path[1] == ":"
            if os.path.isabs(path) or is_windows_abs:
                resolved = path
            else:
                resolved = os.path.normpath(os.path.join(sim_src_dir, path))
            resolved = to_windows_path(resolved)
            resolved = f'"{resolved}"' if quoted or " " in resolved else resolved
            return f'{match.group(1)}{resolved}'
        fout.write(include_pattern.sub(repl_inc, line))
        if not line.endswith("\n"):
            fout.write("\n")
PY
fi

SNAPSHOT_DIR="$RUN_DIR/xsim.dir/kraken_soc_func_tb_ffrf_behav"
SNAPSHOT_EXE="$SNAPSHOT_DIR/xsimk.exe"
REUSE_SNAPSHOT="${REUSE_SNAPSHOT:-0}"
if [[ "$REUSE_SNAPSHOT" != "1" || ! -f "$SNAPSHOT_EXE" ]]; then
  cp "$GLBL_SRC" "$RUN_DIR/"
fi

SIM_RUNTIME="${SIM_RUNTIME:-10us}"
case "$(basename "$MEM_FILE")" in
  demo_mode.mem)
  SIM_RUNTIME="450us"
  ;;
  sne_smoke.mem)
  SIM_RUNTIME="50us"
  ;;
  multimodal_smoke.mem)
  SIM_RUNTIME="550us"
  ;;
  cutie_dma_smoke.mem)
  SIM_RUNTIME="400us"
  ;;
  dronet_v3_stage0.mem|dronet_v3_stage0_preload.mem|dronet_v3_full_preload.mem)
  SIM_RUNTIME="550us"
  ;;
  dronet_v3_stage2_preload.mem)
  SIM_RUNTIME="40us"
  ;;
  dronet_v3_stage3_preload.mem)
  SIM_RUNTIME="40us"
  ;;
  dronet_v3_stage4_preload.mem)
  SIM_RUNTIME="40us"
  ;;
  dronet_v3_stage5_preload.mem)
  SIM_RUNTIME="40us"
  ;;
  dronet_v3_stage6_preload.mem)
  SIM_RUNTIME="40us"
  ;;
  dronet_v3_stage7_preload.mem)
  SIM_RUNTIME="40us"
  ;;
  dronet_v3_stage8_preload.mem)
  SIM_RUNTIME="40us"
  ;;
  dronet_v3_stage9_preload.mem)
  SIM_RUNTIME="40us"
  ;;
  dronet_v3_stage10_preload.mem)
  SIM_RUNTIME="40us"
  ;;
  dronet_v3_stage11_preload.mem)
  SIM_RUNTIME="40us"
  ;;
  dronet_v3_stage12_preload.mem)
  SIM_RUNTIME="40us"
  ;;
  dronet_v3_stage13_preload.mem)
  SIM_RUNTIME="40us"
  ;;
  dronet_v3_stage14_software.mem|dronet_v3_stage14_hardware_preload.mem|dronet_v3_full_hardware.mem)
    SIM_RUNTIME="80us"
    ;;
  dronet_v3_driver.mem|dronet_v3_smoke.mem|dronet_v3_partial.mem|dronet_v3_full.mem)
  SIM_RUNTIME="50us"
  ;;
esac

python3 - "$TCL_SRC" "$TCL_RUN" "$SIM_RUNTIME" <<'PY'
import sys
src_tcl, dst_tcl, sim_runtime = sys.argv[1:4]
with open(src_tcl, "r", encoding="utf-8") as fin:
    data = fin.read()
data = data.replace("run 10us", f"run {sim_runtime}")
with open(dst_tcl, "w", encoding="utf-8", newline="\n") as fout:
    fout.write(data)
PY

RUN_DIR_WIN="$(wslpath -w "$RUN_DIR")"
PRJ_RUN_WIN="$(wslpath -w "$PRJ_RUN")"
ROOT_DIR_XSIM="$(wslpath -w "$ROOT_DIR")"
ROOT_DIR_XSIM="${ROOT_DIR_XSIM//\\/\/}"

echo "INFO: Running FF register-file simulation from $RUN_DIR"
echo "INFO: Using firmware image $(wslpath -w "$MEM_FILE")"
echo "INFO: Using simulation runtime $SIM_RUNTIME"
if [[ "$REUSE_SNAPSHOT" == "1" && -f "$SNAPSHOT_EXE" ]]; then
  echo "INFO: Reusing existing simulation snapshot at $SNAPSHOT_DIR"
else
  run_cmd "cd /D $RUN_DIR_WIN && call $XVLOG_BAT --incr --relax -L uvm -prj $PRJ_RUN_WIN"
  run_cmd "cd /D $RUN_DIR_WIN && call $XELAB_BAT --incr --debug typical --relax --mt 2 -L xil_defaultlib -L uvm -L unisims_ver -L unimacro_ver -L secureip --snapshot kraken_soc_func_tb_ffrf_behav xil_defaultlib.kraken_soc_func_tb xil_defaultlib.glbl -log elaborate_ffrf.log"
fi
MEM_FILE_XSIM="$(wslpath -w "$MEM_FILE")"
MEM_FILE_XSIM="${MEM_FILE_XSIM//\\/\/}"
run_cmd "cd /D $RUN_DIR_WIN && call $XSIM_BAT kraken_soc_func_tb_ffrf_behav -testplusarg \"MEM_INIT_FILE=$MEM_FILE_XSIM\" -testplusarg \"PROJECT_ROOT=$ROOT_DIR_XSIM\" -key Behavioral:sim_1:Functional:kraken_soc_func_tb -tclbatch kraken_soc_func_tb.tcl -log simulate_ffrf.log"

SIM_LOG="$RUN_DIR/simulate_ffrf.log"
if [[ ! -f "$SIM_LOG" ]]; then
  echo "ERROR: simulation log not generated at $SIM_LOG" >&2
  exit 1
fi

echo
echo "===== Simulation Summary ====="
grep -E "FIRMWARE checkpoint writes:|scratch0_cafebabe=|sne_start=|uart_S=|dronet_scratch0=|dronet_stage0_scratch1=|dronet_stage2_scratch1=|dronet_stage3_scratch1=|dronet_stage4_scratch1=|dronet_stage5_scratch1=|dronet_stage6_scratch1=|dronet_stage7_scratch1=|dronet_stage8_scratch1=|dronet_stage9_scratch1=|dronet_stage10_scratch1=|dronet_stage11_scratch1=|dronet_stage12_scratch1=|dronet_stage13_scratch1=|dronet_stage14_scratch1=|stage0_sig=|stage14_sig=|cutie_done_evt=|cutie_timeout_evt=|Firmware profile:|profile_checkpoint=|FIRMWARE_BOOT_CHECK:|CUTIE Activity:|MMIO Activity Seen:|Main Region Fetch:|demo_status=|demo_result=|cycle0=|cutie_sig=|UART TX      <= 41|UART TX      <= 42|UART TX      <= 43|UART TX      <= 44|UART TX      <= 46|UART TX      <= 4d|UART TX      <= 50|UART TX      <= 53|MMIO scratch0 <= cafebabe|MMIO scratch0 <= 534e4501|MMIO scratch0 <= 534e4502|MMIO scratch0 <= 534e45f0|MMIO scratch0 <= 534e45f1|MMIO scratch0 <= 44454d4f|MMIO scratch0 <= 4d4d494f|MMIO scratch1 <= 0badf00d|MMIO scratch0 <= d203a101|MMIO scratch0 <= 000014d6|MMIO scratch1 <= 00040004|MMIO scratch1 <= 00c80504|MMIO scratch1 <= 00320304|MMIO scratch1 <= 00190104|MMIO scratch1 <= 00190304|MMIO scratch1 <= 05190104|MMIO scratch1 <= 06190304|MMIO scratch1 <= 07130108|MMIO scratch1 <= 08130308|MMIO scratch1 <= 09130108|MMIO scratch1 <= 0a070308|MMIO scratch1 <= 0b070110|MMIO scratch1 <= 0c070310|MMIO scratch1 <= 0d070110|MMIO scratch1 <= 0e010102|MMIO scratch1 <= 99b1e9c1|cutie_start_write=|linear_mode=|linear_words=|out0=|out1=|sig=" "$SIM_LOG" || true

case "$(basename "$MEM_FILE")" in
  dronet_v3_stage14_hardware_preload.mem|dronet_v3_full_hardware.mem)
    echo
    if grep -q "MMIO scratch0 <= 000014d6" "$SIM_LOG" && \
       grep -q "UART TX      <= 50" "$SIM_LOG" && \
       grep -q "CUTIE busy=0 evt=01" "$SIM_LOG"; then
      echo "Hardware verdict: PASS"
      echo "  final_signature=000014d6"
      echo "  final_uart=P"
      echo "  cutie_done_evt=YES"
    else
      echo "Hardware verdict: FAIL"
    fi
    ;;
esac
echo
echo "Full log: $SIM_LOG"
