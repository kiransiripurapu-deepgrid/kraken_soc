#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import pathlib
import re
import sys
from typing import Any


REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent
CUTIE_CONF = REPO_ROOT / "include" / "cutie_conf.sv"
MANIFEST = REPO_ROOT / "sw" / "dronet_v3" / "generated" / "dronet_v3_manifest.json"
REPORT = REPO_ROOT / "sw" / "dronet_v3" / "generated" / "dronet_v3_compat_report.json"


def select_profile_text(text: str, profile: str) -> str:
    match = re.search(
        r"`ifdef\s+KRAKEN_FPGA_SYNTH_PROFILE(?P<fpga>.*?)`else(?P<sim>.*?)`endif",
        text,
        re.DOTALL,
    )
    if not match:
        raise RuntimeError(f"Could not isolate profile branches in {CUTIE_CONF}")
    return match.group("fpga" if profile == "fpga" else "sim")


def parse_param(name: str, text: str) -> int:
    match = re.search(rf"parameter\s+int\s+unsigned\s+{re.escape(name)}\s*=\s*(\d+)", text)
    if not match:
        raise RuntimeError(f"Could not find parameter {name} in selected CUTIE profile text")
    return int(match.group(1))


def load_manifest() -> dict[str, Any]:
    if not MANIFEST.exists():
        raise RuntimeError(
            f"Missing manifest {MANIFEST}. Generate it first with "
            "make -C sw/dronet_v3 manifest"
        )
    return json.loads(MANIFEST.read_text(encoding="utf-8"))


def kernel_supported(layer_kernel: int | None, cutie_k: int) -> bool:
    if layer_kernel is None:
        return False
    return layer_kernel == cutie_k


def op_supported(op: str | None) -> bool:
    # The current CUTIE integration is conv-centric and the proven path is a
    # single programmed layer. Treat non-convolutional ops as unsupported.
    return op in {"conv", "depthwise_conv", "pointwise_conv"}


def stage_support(layer: dict[str, Any], cutie_cfg: dict[str, int], max_layers: int) -> dict[str, Any]:
    reasons: list[str] = []
    op = layer.get("op")
    kernel = layer.get("kernel_size")
    tile_output_h = layer.get("tile_output_h")
    tile_output_w = layer.get("tile_output_w")
    tile_ni = layer.get("tile_ni")
    tile_no = layer.get("tile_no")

    if not op_supported(op):
        reasons.append(f"op {op!r} is not part of the current CUTIE execution path")
    if not kernel_supported(kernel, cutie_cfg["K"]):
        reasons.append(f"kernel {kernel} does not match fixed CUTIE K={cutie_cfg['K']}")
    if tile_output_h is not None and tile_output_h > cutie_cfg["IMAGEHEIGHT"]:
        reasons.append(
            f"tile_output_h={tile_output_h} exceeds CUTIE IMAGEHEIGHT={cutie_cfg['IMAGEHEIGHT']}"
        )
    if tile_output_w is not None and tile_output_w > cutie_cfg["IMAGEWIDTH"]:
        reasons.append(
            f"tile_output_w={tile_output_w} exceeds CUTIE IMAGEWIDTH={cutie_cfg['IMAGEWIDTH']}"
        )
    if tile_ni is not None and tile_ni > cutie_cfg["N_I"]:
        reasons.append(f"tile_ni={tile_ni} exceeds CUTIE N_I={cutie_cfg['N_I']}")
    if tile_no is not None and tile_no > cutie_cfg["N_O"]:
        reasons.append(f"tile_no={tile_no} exceeds CUTIE N_O={cutie_cfg['N_O']}")
    if layer["index"] >= max_layers:
        reasons.append(f"stage index {layer['index']} exceeds queued-layer budget {max_layers}")
    if layer.get("weight_blob") is not None:
        reasons.append(
            "weight blob is a DORY byte-oriented export; current CUTIE flow still needs a CUTIE-native conversion step"
        )

    return {
        "index": layer["index"],
        "name": layer["name"],
        "op": op,
        "kernel_size": kernel,
        "tile_input_h": layer.get("tile_input_h"),
        "tile_input_w": layer.get("tile_input_w"),
        "tile_output_h": tile_output_h,
        "tile_output_w": tile_output_w,
        "tile_ni": tile_ni,
        "tile_no": tile_no,
        "supported_now": len(reasons) == 0,
        "reasons": reasons,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--profile",
        choices=("sim", "fpga"),
        default="sim",
        help="Select the CUTIE profile branch to audit against",
    )
    args = parser.parse_args()

    cutie_text = CUTIE_CONF.read_text(encoding="utf-8")
    profile_text = select_profile_text(cutie_text, args.profile)
    manifest = load_manifest()

    cutie_cfg = {
        "PROFILE": args.profile,
        "K": parse_param("K", profile_text),
        "IMAGEWIDTH": parse_param("IMAGEWIDTH", profile_text),
        "IMAGEHEIGHT": parse_param("IMAGEHEIGHT", profile_text),
        "NUM_LAYERS": parse_param("NUM_LAYERS", profile_text),
        "N_I": parse_param("N_I", profile_text),
        "N_O": parse_param("N_O", profile_text),
    }

    network_stage_count = int(manifest["network_stage_count"])
    weighted_stage_count = sum(1 for layer in manifest["layers"] if layer.get("weight_blob") is not None)
    support_rows = [
        stage_support(layer, cutie_cfg, cutie_cfg["NUM_LAYERS"])
        for layer in manifest["layers"]
    ]
    supported_now_count = sum(1 for row in support_rows if row["supported_now"])

    blockers: list[str] = []
    input_width = int(manifest["input_image"]["width"])
    input_height = int(manifest["input_image"]["height"])
    kernels = sorted(
        {
            int(layer["kernel_size"])
            for layer in manifest["layers"]
            if layer.get("kernel_size") is not None
        }
    )

    if cutie_cfg["IMAGEWIDTH"] < input_width or cutie_cfg["IMAGEHEIGHT"] < input_height:
        blockers.append(
            f"CUTIE profile is limited to {cutie_cfg['IMAGEWIDTH']}x{cutie_cfg['IMAGEHEIGHT']}, "
            f"but the exported DroNet input image is {input_width}x{input_height}."
        )
    if cutie_cfg["NUM_LAYERS"] < network_stage_count:
        blockers.append(
            f"CUTIE profile supports only {cutie_cfg['NUM_LAYERS']} queued layers, "
            f"but the exported DroNet network has {network_stage_count} stages."
        )
    if len(kernels) > 1 or cutie_cfg["K"] not in kernels:
        blockers.append(
            f"DroNet export uses mixed kernels {kernels}, while CUTIE is compiled with a fixed K={cutie_cfg['K']}."
        )
    blockers.append(
        "The exported DORY weights are byte-oriented generic CNN payloads, while CUTIE stores ternary-packed "
        "weights and threshold state; they are not directly load-compatible."
    )

    report = {
        "cutie_profile": cutie_cfg,
        "network_stage_count": network_stage_count,
        "weighted_stage_count": weighted_stage_count,
        "supported_now_count": supported_now_count,
        "blockers": blockers,
        "layers": support_rows,
    }
    REPORT.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    print("DroNet v3 Compatibility Audit")
    print("=============================")
    print(f"Main project:        {REPO_ROOT / 'scripts' / 'kraken_func_a7' / 'kraken_func_a7.xpr'}")
    print(
        "CUTIE profile:       "
        f"profile={cutie_cfg['PROFILE']} K={cutie_cfg['K']}, IMAGE={cutie_cfg['IMAGEWIDTH']}x{cutie_cfg['IMAGEHEIGHT']}, "
        f"N_I={cutie_cfg['N_I']}, N_O={cutie_cfg['N_O']}, NUM_LAYERS={cutie_cfg['NUM_LAYERS']}"
    )
    print(f"Manifest:            {MANIFEST.relative_to(REPO_ROOT)}")
    print(f"Exported stages:     {network_stage_count} total, {weighted_stage_count} weighted")
    print(f"Supported now:       {supported_now_count}/{network_stage_count}")
    print()
    print("Blockers")
    print("--------")
    for blocker in blockers:
        print(f"- {blocker}")
    print()
    print("Per-Layer Snapshot")
    print("------------------")
    for row in support_rows:
        status = "SUPPORTED" if row["supported_now"] else "BLOCKED"
        reason = row["reasons"][0] if row["reasons"] else "ready"
        print(
            f"- stage {row['index']:>2} {row['name']}: {status} "
            f"(op={row['op']}, k={row['kernel_size']}, ni={row['tile_ni']}, no={row['tile_no']}, "
            f"out={row['tile_output_h']}x{row['tile_output_w']})"
        )
        print(f"  first blocker: {reason}")
    print()
    print("Report")
    print("------")
    print(f"Wrote {REPORT}")
    print()
    print("Conclusion")
    print("----------")
    print(
        "The current mini-Kraken CUTIE path can now run the checked exported stage0 preload milestone, "
        "but the full DroNet network still requires multi-layer scheduling, mixed-kernel support, "
        "and a CUTIE-native weight conversion/export path."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
