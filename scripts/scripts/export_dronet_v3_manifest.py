#!/usr/bin/env python3
from __future__ import annotations

import ast
import json
import pathlib
import re
from typing import Any


REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent
DRONET_ROOT = REPO_ROOT / "sw" / "dronet_v3" / "assets" / "tiny_pulp_dronet_v3_dory"
NETWORK_C = DRONET_ROOT / "src" / "network.c"
GENERATED_DIR = REPO_ROOT / "sw" / "dronet_v3" / "generated"
OUT_FILE = GENERATED_DIR / "dronet_v3_manifest.json"


def parse_c_int_array(name: str, text: str) -> list[int]:
    match = re.search(rf"{re.escape(name)}\s*\[\d+\]\s*=\s*\{{([^}}]+)\}};", text, re.MULTILINE)
    if not match:
        raise RuntimeError(f"Could not find array {name} in network.c")
    body = match.group(1).replace("\n", " ")
    return [int(item.strip()) for item in body.split(",") if item.strip()]


def parse_c_string_array(name: str, text: str) -> list[str]:
    match = re.search(rf"{re.escape(name)}\s*\[\]\s*=\s*\{{([^}}]+)\}};", text, re.MULTILINE)
    if not match:
        raise RuntimeError(f"Could not find array {name} in network.c")
    return re.findall(r'"([^"]+)"', match.group(1))


def parse_layer_sequence(text: str) -> list[str]:
    match = re.search(r"switch\s*\(i\)\s*\{(?P<body>.*?)\n\s*\}", text, re.DOTALL)
    if not match:
        raise RuntimeError("Could not find network layer switch")
    body = match.group("body")
    seq = re.findall(r"case\s+\d+:\s+([A-Za-z0-9_]+)\(args\);", body)
    if not seq:
        raise RuntimeError("Could not extract network layer sequence")
    return seq


def parse_weight_files_for_layers(sequence: list[str], weight_files: list[str]) -> list[str | None]:
    mapped: list[str | None] = []
    weight_idx = 0
    for layer in sequence:
        if layer.startswith("layerMaxPool"):
            mapped.append(None)
            continue
        if weight_idx >= len(weight_files):
            raise RuntimeError("Weight file list shorter than weighted layer sequence")
        mapped.append(weight_files[weight_idx])
        weight_idx += 1
    return mapped


def parse_layer_source(layer_name: str) -> dict[str, Any]:
    src_path = DRONET_ROOT / "src" / f"{layer_name}.c"
    text = src_path.read_text(encoding="utf-8")

    info: dict[str, Any] = {
        "source_file": str(src_path.relative_to(REPO_ROOT)).replace("\\", "/"),
        "kernel_op": None,
        "kernel_size": None,
        "input_bytes_dma": None,
        "weight_bytes_dma": None,
        "output_bytes_dma": None,
        "tile_input_h": None,
        "tile_input_w": None,
        "tile_output_h": None,
        "tile_output_w": None,
        "tile_ni": None,
        "tile_no": None,
    }

    if "pulp_nn_depthwise_" in text:
        info["kernel_op"] = "depthwise_conv"
        m = re.search(r"pulp_nn_depthwise_[A-Za-z0-9_]+\([\s\S]*?\n\s*[A-Za-z0-9_]+,\n\s*(\d+),\n\s*(\d+),\n\s*p_t,", text)
        if m:
            info["kernel_size"] = int(m.group(1))
    elif "pulp_nn_pointwise_" in text:
        info["kernel_op"] = "pointwise_conv"
        info["kernel_size"] = 1
    elif "pulp_nn_conv_" in text:
        info["kernel_op"] = "conv"
        m = re.search(r"pulp_nn_conv_[A-Za-z0-9_]+\([\s\S]*?\n\s*[A-Za-z0-9_]+,\n\s*[A-Za-z0-9_]+,\n\s*(\d+),\n\s*(\d+),\n\s*p_t,", text)
        if m:
            info["kernel_size"] = int(m.group(1))
    elif "pulp_nn_linear_out_32" in text:
        info["kernel_op"] = "matmul"
        info["kernel_size"] = 1
    elif layer_name.startswith("layerMaxPool"):
        info["kernel_op"] = "maxpool"

    dma_matches = re.findall(
        r"dory_dma_memcpy_3d_custom(?:_blocking|_weights|_hwc_to_chw|_out)?\(\s*\n"
        r"\s*l2_[xWy], // ext\s*\n"
        r"\s*\(l1_buffer \+ \d+\) \+ \d+, // loc.*?\n"
        r"\s*(\d+), // size.*?\n"
        r"\s*(\d+), // stride_1.*?\n"
        r"\s*(\d+), // stride_0.*?\n"
        r"\s*(\d+), // length_2.*?\n"
        r"\s*(\d+), // length_0",
        text,
        re.DOTALL,
    )

    if dma_matches:
        # first copy is input, second is weights for weighted layers
        input_dma = dma_matches[0]
        info["input_bytes_dma"] = int(input_dma[0])
        info["tile_input_h"] = int(input_dma[3])
        info["tile_input_w"] = int(input_dma[4])
        if len(dma_matches) > 1:
            weight_dma = dma_matches[1]
            info["weight_bytes_dma"] = int(weight_dma[0])

    out_match = re.search(
        r"y_tile_size_h\s*=\s*\([^?]+\)\s+\?\s+(\d+)\s*:\s*\d+;\s*\n"
        r"\s*y_tile_size_w\s*=\s*\([^?]+\)\s+\?\s+(\d+)\s*:\s*\d+;",
        text,
    )
    if out_match:
        info["tile_output_h"] = int(out_match.group(1))
        info["tile_output_w"] = int(out_match.group(2))

    no_match = re.search(r"W_tile_size_nof\s*=\s*\([^?]+\)\s+\?\s+(\d+)\s*:\s*\d+;", text)
    ni_match = re.search(r"W_tile_size_nif\s*=\s*\([^?]+\)\s+\?\s+(\d+)\s*:\s*\d+;", text)
    if no_match:
        info["tile_no"] = int(no_match.group(1))
    if ni_match:
        info["tile_ni"] = int(ni_match.group(1))

    out_bytes_match = re.search(r"y_tile_size_byte\s*=\s*.*?;", text)
    if out_bytes_match:
        expr = out_bytes_match.group(0)
        consts = [int(v) for v in re.findall(r"\b\d+\b", expr)]
        if consts:
            info["output_bytes_dma"] = consts[-1]

    return info


def main() -> int:
    GENERATED_DIR.mkdir(parents=True, exist_ok=True)

    network_text = NETWORK_C.read_text(encoding="utf-8")
    layer_sequence = parse_layer_sequence(network_text)
    weight_files = parse_c_string_array("L3_weights_files", network_text)
    weight_files_by_layer = parse_weight_files_for_layers(layer_sequence, weight_files)

    manifest: dict[str, Any] = {
        "source": str(DRONET_ROOT.relative_to(REPO_ROOT)).replace("\\", "/"),
        "network_stage_count": len(layer_sequence),
        "input_image": {"width": 200, "height": 200, "channels": 1},
        "weight_files": weight_files,
        "arrays": {
            "check_weights_dimension": parse_c_int_array("check_weights_dimension", network_text),
            "cumulative_weights_dimension": parse_c_int_array("cumulative_weights_dimension", network_text),
            "check_activations_dimension": parse_c_int_array("check_activations_dimension", network_text),
            "check_activations_out_dimension": parse_c_int_array("check_activations_out_dimension", network_text),
            "layer_with_weights": parse_c_int_array("layer_with_weights", network_text),
            "allocate_layer": parse_c_int_array("allocate_layer", network_text),
        },
        "layers": [],
    }

    act_in = manifest["arrays"]["check_activations_dimension"]
    act_out = manifest["arrays"]["check_activations_out_dimension"]
    weight_dims = manifest["arrays"]["check_weights_dimension"]

    weight_dim_idx = 0
    for idx, layer_name in enumerate(layer_sequence):
        layer_info = parse_layer_source(layer_name)
        weighted = manifest["arrays"]["layer_with_weights"][idx] == 1
        layer_record: dict[str, Any] = {
            "index": idx,
            "name": layer_name,
            "op": layer_info["kernel_op"],
            "kernel_size": layer_info["kernel_size"],
            "input_activation_bytes": act_in[idx],
            "output_activation_bytes": act_out[idx],
            "weight_blob": weight_files_by_layer[idx],
            "weight_blob_bytes": weight_dims[idx] if weighted else 0,
            "tile_input_h": layer_info["tile_input_h"],
            "tile_input_w": layer_info["tile_input_w"],
            "tile_output_h": layer_info["tile_output_h"],
            "tile_output_w": layer_info["tile_output_w"],
            "tile_ni": layer_info["tile_ni"],
            "tile_no": layer_info["tile_no"],
            "source_file": layer_info["source_file"],
        }
        if weighted:
            weight_dim_idx += 1
        manifest["layers"].append(layer_record)

    OUT_FILE.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {OUT_FILE}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
