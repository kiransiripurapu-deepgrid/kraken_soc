#!/usr/bin/env python3
from __future__ import annotations

import json
import pathlib
from typing import Any


REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent
DRONET_ROOT = REPO_ROOT / "sw" / "dronet_v3" / "assets" / "tiny_pulp_dronet_v3_dory"
GENERATED_DIR = REPO_ROOT / "sw" / "dronet_v3" / "generated"
MANIFEST = GENERATED_DIR / "dronet_v3_manifest.json"
OUT_DIR = GENERATED_DIR / "layer_payloads"


def to_words_le(data: bytes) -> list[int]:
    padded = data + b"\x00" * ((4 - (len(data) % 4)) % 4)
    return [
        int.from_bytes(padded[idx:idx + 4], "little", signed=False)
        for idx in range(0, len(padded), 4)
    ]


def write_hex_words(path: pathlib.Path, words: list[int]) -> None:
    path.write_text("\n".join(f"{word:08x}" for word in words) + "\n", encoding="utf-8", newline="\n")


def main() -> int:
    manifest: dict[str, Any] = json.loads(MANIFEST.read_text(encoding="utf-8"))
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    payload_manifest: dict[str, Any] = {
        "source_manifest": str(MANIFEST.relative_to(REPO_ROOT)).replace("\\", "/"),
        "input_payload": None,
        "derived_payloads": {},
        "layers": [],
    }

    # Only stage0 has a directly available activation payload in the export bundle.
    input_words = to_words_le((DRONET_ROOT / "inputs.hex").read_bytes())
    input_hex = OUT_DIR / "stage0_input_words.hex"
    write_hex_words(input_hex, input_words)
    payload_manifest["input_payload"] = {
        "path": str(input_hex.relative_to(REPO_ROOT)).replace("\\", "/"),
        "word_count": len(input_words),
        "note": "Only stage0 input activations are directly available in the exported bundle.",
    }

    stage0_output_hex = OUT_DIR / "stage0_output_words.hex"
    stage0_output_summary = OUT_DIR / "stage0_output_summary.json"
    stage1_pool_hex = OUT_DIR / "stage1_maxpool_output_words.hex"
    stage1_pool_summary = OUT_DIR / "stage1_maxpool_output_summary.json"
    stage2_output_hex = OUT_DIR / "stage2_output_words.hex"
    stage2_output_summary = OUT_DIR / "stage2_output_summary.json"
    stage3_output_hex = OUT_DIR / "stage3_output_words.hex"
    stage3_output_summary = OUT_DIR / "stage3_output_summary.json"
    stage4_output_hex = OUT_DIR / "stage4_output_words.hex"
    stage4_output_summary = OUT_DIR / "stage4_output_summary.json"
    stage5_output_hex = OUT_DIR / "stage5_output_words.hex"
    stage5_output_summary = OUT_DIR / "stage5_output_summary.json"
    stage6_output_hex = OUT_DIR / "stage6_output_words.hex"
    stage6_output_summary = OUT_DIR / "stage6_output_summary.json"
    stage7_output_hex = OUT_DIR / "stage7_output_words.hex"
    stage7_output_summary = OUT_DIR / "stage7_output_summary.json"
    stage8_output_hex = OUT_DIR / "stage8_output_words.hex"
    stage8_output_summary = OUT_DIR / "stage8_output_summary.json"
    stage9_output_hex = OUT_DIR / "stage9_output_words.hex"
    stage9_output_summary = OUT_DIR / "stage9_output_summary.json"
    stage10_output_hex = OUT_DIR / "stage10_output_words.hex"
    stage10_output_summary = OUT_DIR / "stage10_output_summary.json"
    stage11_output_hex = OUT_DIR / "stage11_output_words.hex"
    stage11_output_summary = OUT_DIR / "stage11_output_summary.json"
    stage12_output_hex = OUT_DIR / "stage12_output_words.hex"
    stage12_output_summary = OUT_DIR / "stage12_output_summary.json"
    if stage0_output_hex.exists():
        output_entry: dict[str, Any] = {
            "path": str(stage0_output_hex.relative_to(REPO_ROOT)).replace("\\", "/"),
            "note": "Derived from CUTIE stage0 preload simulation output.",
        }
        if stage0_output_summary.exists():
            output_entry["summary"] = json.loads(stage0_output_summary.read_text(encoding="utf-8"))
        payload_manifest["derived_payloads"]["stage0_output"] = output_entry
    if stage1_pool_hex.exists():
        pool_entry: dict[str, Any] = {
            "path": str(stage1_pool_hex.relative_to(REPO_ROOT)).replace("\\", "/"),
            "note": "Derived by applying the exported layerMaxPool1 operation to stage0_output_words.hex.",
        }
        if stage1_pool_summary.exists():
            pool_entry["summary"] = json.loads(stage1_pool_summary.read_text(encoding="utf-8"))
        payload_manifest["derived_payloads"]["stage1_maxpool_output"] = pool_entry
    if stage2_output_hex.exists():
        stage2_entry: dict[str, Any] = {
            "path": str(stage2_output_hex.relative_to(REPO_ROOT)).replace("\\", "/"),
            "note": "Derived from CUTIE stage2 preload simulation output.",
        }
        if stage2_output_summary.exists():
            stage2_entry["summary"] = json.loads(stage2_output_summary.read_text(encoding="utf-8"))
        payload_manifest["derived_payloads"]["stage2_output"] = stage2_entry
    if stage3_output_hex.exists():
        stage3_entry: dict[str, Any] = {
            "path": str(stage3_output_hex.relative_to(REPO_ROOT)).replace("\\", "/"),
            "note": "Derived from CUTIE stage3 preload simulation output.",
        }
        if stage3_output_summary.exists():
            stage3_entry["summary"] = json.loads(stage3_output_summary.read_text(encoding="utf-8"))
        payload_manifest["derived_payloads"]["stage3_output"] = stage3_entry
    if stage4_output_hex.exists():
        stage4_entry: dict[str, Any] = {
            "path": str(stage4_output_hex.relative_to(REPO_ROOT)).replace("\\", "/"),
            "note": "Derived from CUTIE stage4 preload simulation output.",
        }
        if stage4_output_summary.exists():
            stage4_entry["summary"] = json.loads(stage4_output_summary.read_text(encoding="utf-8"))
        payload_manifest["derived_payloads"]["stage4_output"] = stage4_entry
    if stage5_output_hex.exists():
        stage5_entry: dict[str, Any] = {
            "path": str(stage5_output_hex.relative_to(REPO_ROOT)).replace("\\", "/"),
            "note": "Derived from CUTIE stage5 preload simulation output.",
        }
        if stage5_output_summary.exists():
            stage5_entry["summary"] = json.loads(stage5_output_summary.read_text(encoding="utf-8"))
        payload_manifest["derived_payloads"]["stage5_output"] = stage5_entry
    if stage6_output_hex.exists():
        stage6_entry: dict[str, Any] = {
            "path": str(stage6_output_hex.relative_to(REPO_ROOT)).replace("\\", "/"),
            "note": "Derived from CUTIE stage6 preload simulation output.",
        }
        if stage6_output_summary.exists():
            stage6_entry["summary"] = json.loads(stage6_output_summary.read_text(encoding="utf-8"))
        payload_manifest["derived_payloads"]["stage6_output"] = stage6_entry
    if stage7_output_hex.exists():
        stage7_entry: dict[str, Any] = {
            "path": str(stage7_output_hex.relative_to(REPO_ROOT)).replace("\\", "/"),
            "note": "Derived from CUTIE stage7 preload simulation output.",
        }
        if stage7_output_summary.exists():
            stage7_entry["summary"] = json.loads(stage7_output_summary.read_text(encoding="utf-8"))
        payload_manifest["derived_payloads"]["stage7_output"] = stage7_entry
    if stage8_output_hex.exists():
        stage8_entry: dict[str, Any] = {
            "path": str(stage8_output_hex.relative_to(REPO_ROOT)).replace("\\", "/"),
            "note": "Derived from CUTIE stage8 preload simulation output.",
        }
        if stage8_output_summary.exists():
            stage8_entry["summary"] = json.loads(stage8_output_summary.read_text(encoding="utf-8"))
        payload_manifest["derived_payloads"]["stage8_output"] = stage8_entry
    if stage9_output_hex.exists():
        stage9_entry: dict[str, Any] = {
            "path": str(stage9_output_hex.relative_to(REPO_ROOT)).replace("\\", "/"),
            "note": "Derived from CUTIE stage9 preload simulation output.",
        }
        if stage9_output_summary.exists():
            stage9_entry["summary"] = json.loads(stage9_output_summary.read_text(encoding="utf-8"))
        payload_manifest["derived_payloads"]["stage9_output"] = stage9_entry
    if stage10_output_hex.exists():
        stage10_entry: dict[str, Any] = {
            "path": str(stage10_output_hex.relative_to(REPO_ROOT)).replace("\\", "/"),
            "note": "Derived from CUTIE stage10 preload simulation output.",
        }
        if stage10_output_summary.exists():
            stage10_entry["summary"] = json.loads(stage10_output_summary.read_text(encoding="utf-8"))
        payload_manifest["derived_payloads"]["stage10_output"] = stage10_entry
    if stage11_output_hex.exists():
        stage11_entry: dict[str, Any] = {
            "path": str(stage11_output_hex.relative_to(REPO_ROOT)).replace("\\", "/"),
            "note": "Derived from CUTIE stage11 preload simulation output.",
        }
        if stage11_output_summary.exists():
            stage11_entry["summary"] = json.loads(stage11_output_summary.read_text(encoding="utf-8"))
        payload_manifest["derived_payloads"]["stage11_output"] = stage11_entry
    if stage12_output_hex.exists():
        stage12_entry: dict[str, Any] = {
            "path": str(stage12_output_hex.relative_to(REPO_ROOT)).replace("\\", "/"),
            "note": "Derived from CUTIE stage12 preload simulation output.",
        }
        if stage12_output_summary.exists():
            stage12_entry["summary"] = json.loads(stage12_output_summary.read_text(encoding="utf-8"))
        payload_manifest["derived_payloads"]["stage12_output"] = stage12_entry

    for layer in manifest["layers"]:
        layer_entry: dict[str, Any] = {
            "index": layer["index"],
            "name": layer["name"],
            "op": layer["op"],
            "kernel_size": layer["kernel_size"],
            "weight_blob": layer["weight_blob"],
            "weight_blob_words_hex": None,
            "weight_word_count": 0,
            "activation_payload_available": layer["index"] == 0,
            "activation_note": None,
        }

        if layer["weight_blob"] is not None:
            weight_path = DRONET_ROOT / str(layer["weight_blob"])
            words = to_words_le(weight_path.read_bytes())
            hex_path = OUT_DIR / f"stage{layer['index']:02d}_{layer['name']}_weights.hex"
            write_hex_words(hex_path, words)
            layer_entry["weight_blob_words_hex"] = str(hex_path.relative_to(REPO_ROOT)).replace("\\", "/")
            layer_entry["weight_word_count"] = len(words)

        if layer["index"] == 1 and stage0_output_hex.exists():
            layer_entry["activation_payload_available"] = True
            layer_entry["activation_note"] = (
                "Uses the derived CUTIE stage0 output payload "
                f"{stage0_output_hex.relative_to(REPO_ROOT).as_posix()}."
            )
        elif layer["index"] == 2 and stage1_pool_hex.exists():
            layer_entry["activation_payload_available"] = True
            layer_entry["activation_note"] = (
                "Uses the derived layerMaxPool1 output payload "
                f"{stage1_pool_hex.relative_to(REPO_ROOT).as_posix()}."
            )
        elif layer["index"] == 3 and stage2_output_hex.exists():
            layer_entry["activation_payload_available"] = True
            layer_entry["activation_note"] = (
                "Uses the derived CUTIE stage2 output payload "
                f"{stage2_output_hex.relative_to(REPO_ROOT).as_posix()}."
            )
        elif layer["index"] == 4 and stage3_output_hex.exists():
            layer_entry["activation_payload_available"] = True
            layer_entry["activation_note"] = (
                "Uses the derived CUTIE stage3 output payload "
                f"{stage3_output_hex.relative_to(REPO_ROOT).as_posix()}."
            )
        elif layer["index"] == 5 and stage4_output_hex.exists():
            layer_entry["activation_payload_available"] = True
            layer_entry["activation_note"] = (
                "Uses the derived CUTIE stage4 output payload "
                f"{stage4_output_hex.relative_to(REPO_ROOT).as_posix()}."
            )
        elif layer["index"] == 6 and stage5_output_hex.exists():
            layer_entry["activation_payload_available"] = True
            layer_entry["activation_note"] = (
                "Uses the derived CUTIE stage5 output payload "
                f"{stage5_output_hex.relative_to(REPO_ROOT).as_posix()}."
            )
        elif layer["index"] == 7 and stage6_output_hex.exists():
            layer_entry["activation_payload_available"] = True
            layer_entry["activation_note"] = (
                "Uses the derived CUTIE stage6 output payload "
                f"{stage6_output_hex.relative_to(REPO_ROOT).as_posix()}."
            )
        elif layer["index"] == 8 and stage7_output_hex.exists():
            layer_entry["activation_payload_available"] = True
            layer_entry["activation_note"] = (
                "Uses the derived CUTIE stage7 output payload "
                f"{stage7_output_hex.relative_to(REPO_ROOT).as_posix()}."
            )
        elif layer["index"] == 9 and stage8_output_hex.exists():
            layer_entry["activation_payload_available"] = True
            layer_entry["activation_note"] = (
                "Uses the derived CUTIE stage8 output payload "
                f"{stage8_output_hex.relative_to(REPO_ROOT).as_posix()}."
            )
        elif layer["index"] == 10 and stage9_output_hex.exists():
            layer_entry["activation_payload_available"] = True
            layer_entry["activation_note"] = (
                "Uses the derived CUTIE stage9 output payload "
                f"{stage9_output_hex.relative_to(REPO_ROOT).as_posix()}."
            )
        elif layer["index"] == 11 and stage10_output_hex.exists():
            layer_entry["activation_payload_available"] = True
            layer_entry["activation_note"] = (
                "Uses the derived CUTIE stage10 output payload "
                f"{stage10_output_hex.relative_to(REPO_ROOT).as_posix()}."
            )
        elif layer["index"] == 12 and stage11_output_hex.exists():
            layer_entry["activation_payload_available"] = True
            layer_entry["activation_note"] = (
                "Uses the derived CUTIE stage11 output payload "
                f"{stage11_output_hex.relative_to(REPO_ROOT).as_posix()}."
            )
        elif layer["index"] == 13 and stage12_output_hex.exists():
            layer_entry["activation_payload_available"] = True
            layer_entry["activation_note"] = (
                "Uses the derived CUTIE stage12 output payload "
                f"{stage12_output_hex.relative_to(REPO_ROOT).as_posix()}."
            )
        elif layer["index"] != 0:
            layer_entry["activation_note"] = (
                "Intermediate activations are not present in the exported bundle; "
                "later stages need either a software reference dump or a CUTIE-driven previous-stage run."
            )

        payload_manifest["layers"].append(layer_entry)

    out_manifest = OUT_DIR / "payload_manifest.json"
    out_manifest.write_text(json.dumps(payload_manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {out_manifest}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
