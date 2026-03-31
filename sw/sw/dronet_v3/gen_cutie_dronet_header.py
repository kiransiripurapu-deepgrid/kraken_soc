#!/usr/bin/env python3
from __future__ import annotations

import pathlib


ROOT = pathlib.Path(__file__).resolve().parent
ASSET_DIR = ROOT / "assets" / "tiny_pulp_dronet_v3_dory"
OUT_DIR = ROOT / "generated"
OUT_FILE = OUT_DIR / "cutie_dronet_assets.h"
FULL_ACT_HEX_FILE = OUT_DIR / "cutie_dronet_full_act_words.hex"
FULL_WEIGHT_HEX_FILE = OUT_DIR / "cutie_dronet_full_weight_words.hex"
STAGE2_ACT_HEX_FILE = OUT_DIR / "cutie_dronet_stage2_act_words.hex"
STAGE2_WEIGHT_HEX_FILE = OUT_DIR / "cutie_dronet_stage2_weight_words.hex"
STAGE3_ACT_HEX_FILE = OUT_DIR / "cutie_dronet_stage3_act_words.hex"
STAGE3_WEIGHT_HEX_FILE = OUT_DIR / "cutie_dronet_stage3_weight_words.hex"
STAGE4_ACT_HEX_FILE = OUT_DIR / "cutie_dronet_stage4_act_words.hex"
STAGE4_WEIGHT_HEX_FILE = OUT_DIR / "cutie_dronet_stage4_weight_words.hex"
STAGE5_ACT_HEX_FILE = OUT_DIR / "cutie_dronet_stage5_act_words.hex"
STAGE5_WEIGHT_HEX_FILE = OUT_DIR / "cutie_dronet_stage5_weight_words.hex"
STAGE6_ACT_HEX_FILE = OUT_DIR / "cutie_dronet_stage6_act_words.hex"
STAGE6_WEIGHT_HEX_FILE = OUT_DIR / "cutie_dronet_stage6_weight_words.hex"
STAGE7_ACT_HEX_FILE = OUT_DIR / "cutie_dronet_stage7_act_words.hex"
STAGE7_WEIGHT_HEX_FILE = OUT_DIR / "cutie_dronet_stage7_weight_words.hex"
STAGE8_ACT_HEX_FILE = OUT_DIR / "cutie_dronet_stage8_act_words.hex"
STAGE8_WEIGHT_HEX_FILE = OUT_DIR / "cutie_dronet_stage8_weight_words.hex"
STAGE9_ACT_HEX_FILE = OUT_DIR / "cutie_dronet_stage9_act_words.hex"
STAGE9_WEIGHT_HEX_FILE = OUT_DIR / "cutie_dronet_stage9_weight_words.hex"
STAGE10_ACT_HEX_FILE = OUT_DIR / "cutie_dronet_stage10_act_words.hex"
STAGE10_WEIGHT_HEX_FILE = OUT_DIR / "cutie_dronet_stage10_weight_words.hex"
STAGE11_ACT_HEX_FILE = OUT_DIR / "cutie_dronet_stage11_act_words.hex"
STAGE11_WEIGHT_HEX_FILE = OUT_DIR / "cutie_dronet_stage11_weight_words.hex"
STAGE12_ACT_HEX_FILE = OUT_DIR / "cutie_dronet_stage12_act_words.hex"
STAGE12_WEIGHT_HEX_FILE = OUT_DIR / "cutie_dronet_stage12_weight_words.hex"
STAGE13_ACT_HEX_FILE = OUT_DIR / "cutie_dronet_stage13_act_words.hex"
STAGE13_WEIGHT_HEX_FILE = OUT_DIR / "cutie_dronet_stage13_weight_words.hex"
STAGE14_ACT_HEX_FILE = OUT_DIR / "cutie_dronet_stage14_act_words.hex"
STAGE14_WEIGHT_HEX_FILE = OUT_DIR / "cutie_dronet_stage14_weight_words.hex"

INPUT_FILE = ASSET_DIR / "inputs.hex"
WEIGHT_FILE = ASSET_DIR / "ConvBNRelu0_weights.hex"
STAGE2_ACT_FILE = OUT_DIR / "layer_payloads" / "stage1_maxpool_output_words.hex"
STAGE2_WEIGHT_FILE = OUT_DIR / "layer_payloads" / "stage02_layerConvDWBNRelu2_weights.hex"
STAGE3_ACT_FILE = OUT_DIR / "layer_payloads" / "stage2_output_words.hex"
STAGE3_WEIGHT_FILE = OUT_DIR / "layer_payloads" / "stage03_layerConvBNRelu3_weights.hex"
STAGE4_ACT_FILE = OUT_DIR / "layer_payloads" / "stage3_output_words.hex"
STAGE4_WEIGHT_FILE = OUT_DIR / "layer_payloads" / "stage04_layerConvDWBNRelu4_weights.hex"
STAGE5_ACT_FILE = OUT_DIR / "layer_payloads" / "stage4_output_words.hex"
STAGE5_WEIGHT_FILE = OUT_DIR / "layer_payloads" / "stage05_layerConvBNRelu3_weights.hex"
STAGE6_ACT_FILE = OUT_DIR / "layer_payloads" / "stage5_output_words.hex"
STAGE6_WEIGHT_FILE = OUT_DIR / "layer_payloads" / "stage06_layerConvDWBNRelu6_weights.hex"
STAGE7_ACT_FILE = OUT_DIR / "layer_payloads" / "stage6_output_words.hex"
STAGE7_WEIGHT_FILE = OUT_DIR / "layer_payloads" / "stage07_layerConvBNRelu7_weights.hex"
STAGE8_ACT_FILE = OUT_DIR / "layer_payloads" / "stage7_output_words.hex"
STAGE8_WEIGHT_FILE = OUT_DIR / "layer_payloads" / "stage08_layerConvDWBNRelu8_weights.hex"
STAGE9_ACT_FILE = OUT_DIR / "layer_payloads" / "stage8_output_words.hex"
STAGE9_WEIGHT_FILE = OUT_DIR / "layer_payloads" / "stage09_layerConvBNRelu9_weights.hex"
STAGE10_ACT_FILE = OUT_DIR / "layer_payloads" / "stage9_output_words.hex"
STAGE10_WEIGHT_FILE = OUT_DIR / "layer_payloads" / "stage10_layerConvDWBNRelu10_weights.hex"
STAGE11_ACT_FILE = OUT_DIR / "layer_payloads" / "stage10_output_words.hex"
STAGE11_WEIGHT_FILE = OUT_DIR / "layer_payloads" / "stage11_layerConvBNRelu11_weights.hex"
STAGE12_ACT_FILE = OUT_DIR / "layer_payloads" / "stage11_output_words.hex"
STAGE12_WEIGHT_FILE = OUT_DIR / "layer_payloads" / "stage12_layerConvDWBNRelu12_weights.hex"
STAGE13_ACT_FILE = OUT_DIR / "layer_payloads" / "stage12_output_words.hex"
STAGE13_WEIGHT_FILE = OUT_DIR / "layer_payloads" / "stage13_layerConvBNRelu13_weights.hex"
STAGE14_ACT_FILE = OUT_DIR / "layer_payloads" / "stage13_output_words.hex"
STAGE14_WEIGHT_FILE = ASSET_DIR / "MatMul14_weights.hex"

SMOKE_ACT_WORD_LIMIT = 8
SMOKE_WEIGHT_WORD_LIMIT = 8
PARTIAL_ACT_WORD_LIMIT = 32
PARTIAL_WEIGHT_WORD_LIMIT = None


def to_words_le(data: bytes, limit_words: int | None = None) -> list[int]:
    words: list[int] = []
    padded = data + b"\x00" * ((4 - (len(data) % 4)) % 4)
    max_bytes = len(padded) if limit_words is None else min(len(padded), limit_words * 4)
    for idx in range(0, max_bytes, 4):
        words.append(int.from_bytes(padded[idx:idx + 4], "little", signed=False))
    return words


def fmt_words(words: list[int]) -> str:
    return ",\n  ".join(f"0x{word:08X}u" for word in words)


def words_to_le_bytes(words: list[int]) -> bytes:
    return b"".join(word.to_bytes(4, "little", signed=False) for word in words)


def s8(value: int) -> int:
    return value if value < 0x80 else value - 0x100


def stage14_reference(act_words: list[int], weight_words: list[int]) -> tuple[int, int, int]:
    act_bytes = words_to_le_bytes(act_words)[:784]
    weight_bytes = words_to_le_bytes(weight_words)[:1568]
    outputs: list[int] = []
    for out_idx in range(2):
        acc = 0
        row = weight_bytes[out_idx * 784:(out_idx + 1) * 784]
        for act, weight in zip(act_bytes, row):
            acc += s8(act) * s8(weight)
        outputs.append(acc & 0xFFFFFFFF)
    signature = (outputs[0] ^ ((outputs[1] << 1) & 0xFFFFFFFF) ^ (outputs[1] >> 31)) & 0xFFFFFFFF
    return outputs[0], outputs[1], signature


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    input_bytes = INPUT_FILE.read_bytes()
    weight_bytes = WEIGHT_FILE.read_bytes()

    smoke_act_words = to_words_le(input_bytes, SMOKE_ACT_WORD_LIMIT)
    smoke_weight_words = to_words_le(weight_bytes, SMOKE_WEIGHT_WORD_LIMIT)
    partial_act_words = to_words_le(input_bytes, PARTIAL_ACT_WORD_LIMIT)
    partial_weight_words = to_words_le(weight_bytes, PARTIAL_WEIGHT_WORD_LIMIT)
    full_act_words = to_words_le(input_bytes)
    full_weight_words = to_words_le(weight_bytes)
    stage2_act_words = []
    stage2_weight_words = []
    if STAGE2_ACT_FILE.exists():
        stage2_act_words = [int(line.strip(), 16) for line in STAGE2_ACT_FILE.read_text().splitlines() if line.strip()]
    if STAGE2_WEIGHT_FILE.exists():
        stage2_weight_words = [int(line.strip(), 16) for line in STAGE2_WEIGHT_FILE.read_text().splitlines() if line.strip()]
    stage3_act_words = []
    stage3_weight_words = []
    if STAGE3_ACT_FILE.exists():
        stage3_act_words = [int(line.strip(), 16) for line in STAGE3_ACT_FILE.read_text().splitlines() if line.strip()]
    if STAGE3_WEIGHT_FILE.exists():
        stage3_weight_words = [int(line.strip(), 16) for line in STAGE3_WEIGHT_FILE.read_text().splitlines() if line.strip()]
    stage4_act_words = []
    stage4_weight_words = []
    if STAGE4_ACT_FILE.exists():
        stage4_act_words = [int(line.strip(), 16) for line in STAGE4_ACT_FILE.read_text().splitlines() if line.strip()]
    if STAGE4_WEIGHT_FILE.exists():
        stage4_weight_words = [int(line.strip(), 16) for line in STAGE4_WEIGHT_FILE.read_text().splitlines() if line.strip()]
    stage5_act_words = []
    stage5_weight_words = []
    if STAGE5_ACT_FILE.exists():
        stage5_act_words = [int(line.strip(), 16) for line in STAGE5_ACT_FILE.read_text().splitlines() if line.strip()]
    if STAGE5_WEIGHT_FILE.exists():
        stage5_weight_words = [int(line.strip(), 16) for line in STAGE5_WEIGHT_FILE.read_text().splitlines() if line.strip()]
    stage6_act_words = []
    stage6_weight_words = []
    if STAGE6_ACT_FILE.exists():
        stage6_act_words = [int(line.strip(), 16) for line in STAGE6_ACT_FILE.read_text().splitlines() if line.strip()]
    if STAGE6_WEIGHT_FILE.exists():
        stage6_weight_words = [int(line.strip(), 16) for line in STAGE6_WEIGHT_FILE.read_text().splitlines() if line.strip()]
    stage7_act_words = []
    stage7_weight_words = []
    if STAGE7_ACT_FILE.exists():
        stage7_act_words = [int(line.strip(), 16) for line in STAGE7_ACT_FILE.read_text().splitlines() if line.strip()]
    if STAGE7_WEIGHT_FILE.exists():
        stage7_weight_words = [int(line.strip(), 16) for line in STAGE7_WEIGHT_FILE.read_text().splitlines() if line.strip()]
    stage8_act_words = []
    stage8_weight_words = []
    if STAGE8_ACT_FILE.exists():
        stage8_act_words = [int(line.strip(), 16) for line in STAGE8_ACT_FILE.read_text().splitlines() if line.strip()]
    if STAGE8_WEIGHT_FILE.exists():
        stage8_weight_words = [int(line.strip(), 16) for line in STAGE8_WEIGHT_FILE.read_text().splitlines() if line.strip()]
    stage9_act_words = []
    stage9_weight_words = []
    if STAGE9_ACT_FILE.exists():
        stage9_act_words = [int(line.strip(), 16) for line in STAGE9_ACT_FILE.read_text().splitlines() if line.strip()]
    if STAGE9_WEIGHT_FILE.exists():
        stage9_weight_words = [int(line.strip(), 16) for line in STAGE9_WEIGHT_FILE.read_text().splitlines() if line.strip()]
    stage10_act_words = []
    stage10_weight_words = []
    if STAGE10_ACT_FILE.exists():
        stage10_act_words = [int(line.strip(), 16) for line in STAGE10_ACT_FILE.read_text().splitlines() if line.strip()]
    if STAGE10_WEIGHT_FILE.exists():
        stage10_weight_words = [int(line.strip(), 16) for line in STAGE10_WEIGHT_FILE.read_text().splitlines() if line.strip()]
    stage11_act_words = []
    stage11_weight_words = []
    if STAGE11_ACT_FILE.exists():
        stage11_act_words = [int(line.strip(), 16) for line in STAGE11_ACT_FILE.read_text().splitlines() if line.strip()]
    if STAGE11_WEIGHT_FILE.exists():
        stage11_weight_words = [int(line.strip(), 16) for line in STAGE11_WEIGHT_FILE.read_text().splitlines() if line.strip()]
    stage12_act_words = []
    stage12_weight_words = []
    if STAGE12_ACT_FILE.exists():
        stage12_act_words = [int(line.strip(), 16) for line in STAGE12_ACT_FILE.read_text().splitlines() if line.strip()]
    if STAGE12_WEIGHT_FILE.exists():
        stage12_weight_words = [int(line.strip(), 16) for line in STAGE12_WEIGHT_FILE.read_text().splitlines() if line.strip()]
    stage13_act_words = []
    stage13_weight_words = []
    if STAGE13_ACT_FILE.exists():
        stage13_act_words = [int(line.strip(), 16) for line in STAGE13_ACT_FILE.read_text().splitlines() if line.strip()]
    if STAGE13_WEIGHT_FILE.exists():
        stage13_weight_words = [int(line.strip(), 16) for line in STAGE13_WEIGHT_FILE.read_text().splitlines() if line.strip()]
    stage14_act_words = []
    stage14_weight_words = []
    if STAGE14_ACT_FILE.exists():
        stage14_act_words = [int(line.strip(), 16) for line in STAGE14_ACT_FILE.read_text().splitlines() if line.strip()]
    if STAGE14_WEIGHT_FILE.exists():
        stage14_weight_words = to_words_le(STAGE14_WEIGHT_FILE.read_bytes())
    stage14_out0 = 0
    stage14_out1 = 0
    stage14_signature = 0
    if stage14_act_words and stage14_weight_words:
        stage14_out0, stage14_out1, stage14_signature = stage14_reference(stage14_act_words, stage14_weight_words)

    header = f"""#ifndef CUTIE_DRONET_ASSETS_H
#define CUTIE_DRONET_ASSETS_H

#include <stdint.h>

/*
 * Auto-generated from vendored DroNet export files:
 *   {INPUT_FILE.as_posix()}
 *   {WEIGHT_FILE.as_posix()}
 *
 * This is a CUTIE-compatible smoke payload derived from real DroNet assets.
 * It does not yet represent a full end-to-end network export.
 */

#define CUTIE_DRONET_INPUT_BYTES {len(input_bytes)}u
#define CUTIE_DRONET_WEIGHT_BYTES {len(weight_bytes)}u

#define CUTIE_DRONET_EXPORT_IMG_W 200u
#define CUTIE_DRONET_EXPORT_IMG_H 200u
#define CUTIE_DRONET_EXPORT_NI 1u
#define CUTIE_DRONET_EXPORT_NO 4u
#define CUTIE_DRONET_EXPORT_STRIDE 2u
#define CUTIE_DRONET_EXPORT_KERNEL 5u

/* Current CUTIE build is fixed-K and uses a reduced control subset. */
#define CUTIE_DRONET_COMPAT_K 3u
#define CUTIE_DRONET_COMPAT_POOL_EN 0u
#define CUTIE_DRONET_COMPAT_POOL_K 1u

/*
 * Current firmware only loads a tiny smoke payload from the exported assets.
 * Use a small geometry that matches the truncated payload so CUTIE can
 * complete in simulation. The original export dimensions above are kept as
 * reference metadata only.
 */
#define CUTIE_DRONET_SMOKE_IMG_W 4u
#define CUTIE_DRONET_SMOKE_IMG_H 4u
#define CUTIE_DRONET_SMOKE_NI 1u
#define CUTIE_DRONET_SMOKE_NO 4u
#define CUTIE_DRONET_SMOKE_STRIDE 1u

#define CUTIE_DRONET_STAGE0_IMG_W CUTIE_DRONET_EXPORT_IMG_W
#define CUTIE_DRONET_STAGE0_IMG_H CUTIE_DRONET_EXPORT_IMG_H
#define CUTIE_DRONET_STAGE0_NI CUTIE_DRONET_EXPORT_NI
#define CUTIE_DRONET_STAGE0_NO CUTIE_DRONET_EXPORT_NO
#define CUTIE_DRONET_STAGE0_STRIDE CUTIE_DRONET_EXPORT_STRIDE
#define CUTIE_DRONET_STAGE0_KERNEL CUTIE_DRONET_EXPORT_KERNEL
#define CUTIE_DRONET_STAGE0_EXPECTED_SIGNATURE 0x99B1E9C1u

#define CUTIE_DRONET_STAGE2_IMG_W 50u
#define CUTIE_DRONET_STAGE2_IMG_H 50u
#define CUTIE_DRONET_STAGE2_NI 4u
#define CUTIE_DRONET_STAGE2_NO 4u
#define CUTIE_DRONET_STAGE2_STRIDE 2u
#define CUTIE_DRONET_STAGE2_KERNEL 3u
#define CUTIE_DRONET_STAGE2_MARKER 0x00320304u

#define CUTIE_DRONET_STAGE3_IMG_W 25u
#define CUTIE_DRONET_STAGE3_IMG_H 25u
#define CUTIE_DRONET_STAGE3_NI 4u
#define CUTIE_DRONET_STAGE3_NO 4u
#define CUTIE_DRONET_STAGE3_STRIDE 1u
#define CUTIE_DRONET_STAGE3_KERNEL 1u
#define CUTIE_DRONET_STAGE3_MARKER 0x00190104u

#define CUTIE_DRONET_STAGE4_IMG_W 25u
#define CUTIE_DRONET_STAGE4_IMG_H 25u
#define CUTIE_DRONET_STAGE4_NI 4u
#define CUTIE_DRONET_STAGE4_NO 4u
#define CUTIE_DRONET_STAGE4_STRIDE 1u
#define CUTIE_DRONET_STAGE4_KERNEL 3u
#define CUTIE_DRONET_STAGE4_MARKER 0x00190304u

#define CUTIE_DRONET_STAGE5_IMG_W 25u
#define CUTIE_DRONET_STAGE5_IMG_H 25u
#define CUTIE_DRONET_STAGE5_NI 4u
#define CUTIE_DRONET_STAGE5_NO 4u
#define CUTIE_DRONET_STAGE5_STRIDE 1u
#define CUTIE_DRONET_STAGE5_KERNEL 1u
#define CUTIE_DRONET_STAGE5_MARKER 0x05190104u

#define CUTIE_DRONET_STAGE6_IMG_W 25u
#define CUTIE_DRONET_STAGE6_IMG_H 25u
#define CUTIE_DRONET_STAGE6_NI 4u
#define CUTIE_DRONET_STAGE6_NO 4u
#define CUTIE_DRONET_STAGE6_STRIDE 2u
#define CUTIE_DRONET_STAGE6_KERNEL 3u
#define CUTIE_DRONET_STAGE6_MARKER 0x06190304u

#define CUTIE_DRONET_STAGE7_IMG_W 13u
#define CUTIE_DRONET_STAGE7_IMG_H 13u
#define CUTIE_DRONET_STAGE7_NI 4u
#define CUTIE_DRONET_STAGE7_NO 8u
#define CUTIE_DRONET_STAGE7_STRIDE 1u
#define CUTIE_DRONET_STAGE7_KERNEL 1u
#define CUTIE_DRONET_STAGE7_MARKER 0x07130108u

#define CUTIE_DRONET_STAGE8_IMG_W 13u
#define CUTIE_DRONET_STAGE8_IMG_H 13u
#define CUTIE_DRONET_STAGE8_NI 8u
#define CUTIE_DRONET_STAGE8_NO 8u
#define CUTIE_DRONET_STAGE8_STRIDE 1u
#define CUTIE_DRONET_STAGE8_KERNEL 3u
#define CUTIE_DRONET_STAGE8_MARKER 0x08130308u

#define CUTIE_DRONET_STAGE9_IMG_W 13u
#define CUTIE_DRONET_STAGE9_IMG_H 13u
#define CUTIE_DRONET_STAGE9_NI 8u
#define CUTIE_DRONET_STAGE9_NO 8u
#define CUTIE_DRONET_STAGE9_STRIDE 1u
#define CUTIE_DRONET_STAGE9_KERNEL 1u
#define CUTIE_DRONET_STAGE9_MARKER 0x09130108u

#define CUTIE_DRONET_STAGE10_IMG_W 13u
#define CUTIE_DRONET_STAGE10_IMG_H 13u
#define CUTIE_DRONET_STAGE10_NI 8u
#define CUTIE_DRONET_STAGE10_NO 8u
#define CUTIE_DRONET_STAGE10_STRIDE 2u
#define CUTIE_DRONET_STAGE10_KERNEL 3u
#define CUTIE_DRONET_STAGE10_MARKER 0x0A070308u

#define CUTIE_DRONET_STAGE11_IMG_W 7u
#define CUTIE_DRONET_STAGE11_IMG_H 7u
#define CUTIE_DRONET_STAGE11_NI 8u
#define CUTIE_DRONET_STAGE11_NO 16u
#define CUTIE_DRONET_STAGE11_STRIDE 1u
#define CUTIE_DRONET_STAGE11_KERNEL 1u
#define CUTIE_DRONET_STAGE11_MARKER 0x0B070110u

#define CUTIE_DRONET_STAGE12_IMG_W 7u
#define CUTIE_DRONET_STAGE12_IMG_H 7u
#define CUTIE_DRONET_STAGE12_NI 16u
#define CUTIE_DRONET_STAGE12_NO 16u
#define CUTIE_DRONET_STAGE12_STRIDE 1u
#define CUTIE_DRONET_STAGE12_KERNEL 3u
#define CUTIE_DRONET_STAGE12_MARKER 0x0C070310u

#define CUTIE_DRONET_STAGE13_IMG_W 7u
#define CUTIE_DRONET_STAGE13_IMG_H 7u
#define CUTIE_DRONET_STAGE13_NI 16u
#define CUTIE_DRONET_STAGE13_NO 16u
#define CUTIE_DRONET_STAGE13_STRIDE 1u
#define CUTIE_DRONET_STAGE13_KERNEL 1u
#define CUTIE_DRONET_STAGE13_MARKER 0x0D070110u

#define CUTIE_DRONET_STAGE14_OUT_DIM 2u
#define CUTIE_DRONET_STAGE14_INPUT_DIM 784u
#define CUTIE_DRONET_STAGE14_MARKER 0x0E010102u
#define CUTIE_DRONET_STAGE14_EXPECT_OUT0 0x{stage14_out0:08x}u
#define CUTIE_DRONET_STAGE14_EXPECT_OUT1 0x{stage14_out1:08x}u
#define CUTIE_DRONET_STAGE14_EXPECT_SIGNATURE 0x{stage14_signature:08x}u

#define CUTIE_DRONET_PARTIAL_IMG_W 8u
#define CUTIE_DRONET_PARTIAL_IMG_H 8u
#define CUTIE_DRONET_PARTIAL_NI 1u
#define CUTIE_DRONET_PARTIAL_NO 4u
#define CUTIE_DRONET_PARTIAL_STRIDE 1u

#define CUTIE_DRONET_SMOKE_ACT_WORD_COUNT {len(smoke_act_words)}u
#define CUTIE_DRONET_SMOKE_WEIGHT_WORD_COUNT {len(smoke_weight_words)}u
#define CUTIE_DRONET_STAGE0_ACT_WORD_COUNT {len(full_act_words)}u
#define CUTIE_DRONET_STAGE0_WEIGHT_WORD_COUNT {len(full_weight_words)}u
#define CUTIE_DRONET_STAGE2_ACT_WORD_COUNT {len(stage2_act_words)}u
#define CUTIE_DRONET_STAGE2_WEIGHT_WORD_COUNT {len(stage2_weight_words)}u
#define CUTIE_DRONET_STAGE3_ACT_WORD_COUNT {len(stage3_act_words)}u
#define CUTIE_DRONET_STAGE3_WEIGHT_WORD_COUNT {len(stage3_weight_words)}u
#define CUTIE_DRONET_STAGE4_ACT_WORD_COUNT {len(stage4_act_words)}u
#define CUTIE_DRONET_STAGE4_WEIGHT_WORD_COUNT {len(stage4_weight_words)}u
#define CUTIE_DRONET_STAGE5_ACT_WORD_COUNT {len(stage5_act_words)}u
#define CUTIE_DRONET_STAGE5_WEIGHT_WORD_COUNT {len(stage5_weight_words)}u
#define CUTIE_DRONET_STAGE6_ACT_WORD_COUNT {len(stage6_act_words)}u
#define CUTIE_DRONET_STAGE6_WEIGHT_WORD_COUNT {len(stage6_weight_words)}u
#define CUTIE_DRONET_STAGE7_ACT_WORD_COUNT {len(stage7_act_words)}u
#define CUTIE_DRONET_STAGE7_WEIGHT_WORD_COUNT {len(stage7_weight_words)}u
#define CUTIE_DRONET_STAGE8_ACT_WORD_COUNT {len(stage8_act_words)}u
#define CUTIE_DRONET_STAGE8_WEIGHT_WORD_COUNT {len(stage8_weight_words)}u
#define CUTIE_DRONET_STAGE9_ACT_WORD_COUNT {len(stage9_act_words)}u
#define CUTIE_DRONET_STAGE9_WEIGHT_WORD_COUNT {len(stage9_weight_words)}u
#define CUTIE_DRONET_STAGE10_ACT_WORD_COUNT {len(stage10_act_words)}u
#define CUTIE_DRONET_STAGE10_WEIGHT_WORD_COUNT {len(stage10_weight_words)}u
#define CUTIE_DRONET_STAGE11_ACT_WORD_COUNT {len(stage11_act_words)}u
#define CUTIE_DRONET_STAGE11_WEIGHT_WORD_COUNT {len(stage11_weight_words)}u
#define CUTIE_DRONET_STAGE12_ACT_WORD_COUNT {len(stage12_act_words)}u
#define CUTIE_DRONET_STAGE12_WEIGHT_WORD_COUNT {len(stage12_weight_words)}u
#define CUTIE_DRONET_STAGE13_ACT_WORD_COUNT {len(stage13_act_words)}u
#define CUTIE_DRONET_STAGE13_WEIGHT_WORD_COUNT {len(stage13_weight_words)}u
#define CUTIE_DRONET_STAGE14_ACT_WORD_COUNT {len(stage14_act_words)}u
#define CUTIE_DRONET_STAGE14_WEIGHT_WORD_COUNT {len(stage14_weight_words)}u
#define CUTIE_DRONET_PARTIAL_ACT_WORD_COUNT {len(partial_act_words)}u
#define CUTIE_DRONET_PARTIAL_WEIGHT_WORD_COUNT {len(partial_weight_words)}u
#define CUTIE_DRONET_FULL_ACT_WORD_COUNT {len(full_act_words)}u
#define CUTIE_DRONET_FULL_WEIGHT_WORD_COUNT {len(full_weight_words)}u

static const uint32_t g_dronet_act_words[{len(smoke_act_words)}] = {{
  {fmt_words(smoke_act_words)}
}};

static const uint32_t g_dronet_weight_words[{len(smoke_weight_words)}] = {{
  {fmt_words(smoke_weight_words)}
}};

static const uint32_t g_dronet_partial_act_words[{len(partial_act_words)}] = {{
  {fmt_words(partial_act_words)}
}};

static const uint32_t g_dronet_partial_weight_words[{len(partial_weight_words)}] = {{
  {fmt_words(partial_weight_words)}
}};

#ifdef CUTIE_DRONET_INCLUDE_FULL_PAYLOAD
static const uint32_t g_dronet_full_act_words[{len(full_act_words)}] = {{
  {fmt_words(full_act_words)}
}};

static const uint32_t g_dronet_full_weight_words[{len(full_weight_words)}] = {{
  {fmt_words(full_weight_words)}
}};

#if {1 if stage2_act_words else 0}
static const uint32_t g_dronet_stage2_act_words[{len(stage2_act_words)}] = {{
  {fmt_words(stage2_act_words)}
}};
#endif

#if {1 if stage2_weight_words else 0}
static const uint32_t g_dronet_stage2_weight_words[{len(stage2_weight_words)}] = {{
  {fmt_words(stage2_weight_words)}
}};
#endif

#if {1 if stage3_act_words else 0}
static const uint32_t g_dronet_stage3_act_words[{len(stage3_act_words)}] = {{
  {fmt_words(stage3_act_words)}
}};
#endif

#if {1 if stage3_weight_words else 0}
static const uint32_t g_dronet_stage3_weight_words[{len(stage3_weight_words)}] = {{
  {fmt_words(stage3_weight_words)}
}};
#endif

#if {1 if stage4_act_words else 0}
static const uint32_t g_dronet_stage4_act_words[{len(stage4_act_words)}] = {{
  {fmt_words(stage4_act_words)}
}};
#endif

#if {1 if stage4_weight_words else 0}
static const uint32_t g_dronet_stage4_weight_words[{len(stage4_weight_words)}] = {{
  {fmt_words(stage4_weight_words)}
}};
#endif

#if {1 if stage5_act_words else 0}
static const uint32_t g_dronet_stage5_act_words[{len(stage5_act_words)}] = {{
  {fmt_words(stage5_act_words)}
}};
#endif

#if {1 if stage5_weight_words else 0}
static const uint32_t g_dronet_stage5_weight_words[{len(stage5_weight_words)}] = {{
  {fmt_words(stage5_weight_words)}
}};
#endif

#if {1 if stage6_act_words else 0}
static const uint32_t g_dronet_stage6_act_words[{len(stage6_act_words)}] = {{
  {fmt_words(stage6_act_words)}
}};
#endif

#if {1 if stage6_weight_words else 0}
static const uint32_t g_dronet_stage6_weight_words[{len(stage6_weight_words)}] = {{
  {fmt_words(stage6_weight_words)}
}};
#endif

#if {1 if stage7_act_words else 0}
static const uint32_t g_dronet_stage7_act_words[{len(stage7_act_words)}] = {{
  {fmt_words(stage7_act_words)}
}};
#endif

#if {1 if stage7_weight_words else 0}
static const uint32_t g_dronet_stage7_weight_words[{len(stage7_weight_words)}] = {{
  {fmt_words(stage7_weight_words)}
}};
#endif

#if {1 if stage8_act_words else 0}
static const uint32_t g_dronet_stage8_act_words[{len(stage8_act_words)}] = {{
  {fmt_words(stage8_act_words)}
}};
#endif

#if {1 if stage8_weight_words else 0}
static const uint32_t g_dronet_stage8_weight_words[{len(stage8_weight_words)}] = {{
  {fmt_words(stage8_weight_words)}
}};
#endif

#if {1 if stage9_act_words else 0}
static const uint32_t g_dronet_stage9_act_words[{len(stage9_act_words)}] = {{
  {fmt_words(stage9_act_words)}
}};
#endif

#if {1 if stage9_weight_words else 0}
static const uint32_t g_dronet_stage9_weight_words[{len(stage9_weight_words)}] = {{
  {fmt_words(stage9_weight_words)}
}};
#endif

#if {1 if stage10_act_words else 0}
static const uint32_t g_dronet_stage10_act_words[{len(stage10_act_words)}] = {{
  {fmt_words(stage10_act_words)}
}};
#endif

#if {1 if stage10_weight_words else 0}
static const uint32_t g_dronet_stage10_weight_words[{len(stage10_weight_words)}] = {{
  {fmt_words(stage10_weight_words)}
}};
#endif

#if {1 if stage11_act_words else 0}
static const uint32_t g_dronet_stage11_act_words[{len(stage11_act_words)}] = {{
  {fmt_words(stage11_act_words)}
}};
#endif

#if {1 if stage11_weight_words else 0}
static const uint32_t g_dronet_stage11_weight_words[{len(stage11_weight_words)}] = {{
  {fmt_words(stage11_weight_words)}
}};
#endif

#if {1 if stage12_act_words else 0}
static const uint32_t g_dronet_stage12_act_words[{len(stage12_act_words)}] = {{
  {fmt_words(stage12_act_words)}
}};
#endif

#if {1 if stage12_weight_words else 0}
static const uint32_t g_dronet_stage12_weight_words[{len(stage12_weight_words)}] = {{
  {fmt_words(stage12_weight_words)}
}};
#endif

#if {1 if stage13_act_words else 0}
static const uint32_t g_dronet_stage13_act_words[{len(stage13_act_words)}] = {{
  {fmt_words(stage13_act_words)}
}};
#endif

#if {1 if stage13_weight_words else 0}
static const uint32_t g_dronet_stage13_weight_words[{len(stage13_weight_words)}] = {{
  {fmt_words(stage13_weight_words)}
}};
#endif

#if {1 if stage14_act_words else 0}
static const uint32_t g_dronet_stage14_act_words[{len(stage14_act_words)}] = {{
  {fmt_words(stage14_act_words)}
}};
#endif

#if {1 if stage14_weight_words else 0}
static const uint32_t g_dronet_stage14_weight_words[{len(stage14_weight_words)}] = {{
  {fmt_words(stage14_weight_words)}
}};
#endif
#endif

#endif /* CUTIE_DRONET_ASSETS_H */
"""

    OUT_FILE.write_text(header, encoding="utf-8", newline="\n")
    FULL_ACT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in full_act_words) + "\n", encoding="utf-8", newline="\n")
    FULL_WEIGHT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in full_weight_words) + "\n", encoding="utf-8", newline="\n")
    if stage2_act_words:
        STAGE2_ACT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage2_act_words) + "\n", encoding="utf-8", newline="\n")
    if stage2_weight_words:
        STAGE2_WEIGHT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage2_weight_words) + "\n", encoding="utf-8", newline="\n")
    if stage3_act_words:
        STAGE3_ACT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage3_act_words) + "\n", encoding="utf-8", newline="\n")
    if stage3_weight_words:
        STAGE3_WEIGHT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage3_weight_words) + "\n", encoding="utf-8", newline="\n")
    if stage4_act_words:
        STAGE4_ACT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage4_act_words) + "\n", encoding="utf-8", newline="\n")
    if stage4_weight_words:
        STAGE4_WEIGHT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage4_weight_words) + "\n", encoding="utf-8", newline="\n")
    if stage5_act_words:
        STAGE5_ACT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage5_act_words) + "\n", encoding="utf-8", newline="\n")
    if stage5_weight_words:
        STAGE5_WEIGHT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage5_weight_words) + "\n", encoding="utf-8", newline="\n")
    if stage6_act_words:
        STAGE6_ACT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage6_act_words) + "\n", encoding="utf-8", newline="\n")
    if stage6_weight_words:
        STAGE6_WEIGHT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage6_weight_words) + "\n", encoding="utf-8", newline="\n")
    if stage7_act_words:
        STAGE7_ACT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage7_act_words) + "\n", encoding="utf-8", newline="\n")
    if stage7_weight_words:
        STAGE7_WEIGHT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage7_weight_words) + "\n", encoding="utf-8", newline="\n")
    if stage8_act_words:
        STAGE8_ACT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage8_act_words) + "\n", encoding="utf-8", newline="\n")
    if stage8_weight_words:
        STAGE8_WEIGHT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage8_weight_words) + "\n", encoding="utf-8", newline="\n")
    if stage9_act_words:
        STAGE9_ACT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage9_act_words) + "\n", encoding="utf-8", newline="\n")
    if stage9_weight_words:
        STAGE9_WEIGHT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage9_weight_words) + "\n", encoding="utf-8", newline="\n")
    if stage10_act_words:
        STAGE10_ACT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage10_act_words) + "\n", encoding="utf-8", newline="\n")
    if stage10_weight_words:
        STAGE10_WEIGHT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage10_weight_words) + "\n", encoding="utf-8", newline="\n")
    if stage11_act_words:
        STAGE11_ACT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage11_act_words) + "\n", encoding="utf-8", newline="\n")
    if stage11_weight_words:
        STAGE11_WEIGHT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage11_weight_words) + "\n", encoding="utf-8", newline="\n")
    if stage12_act_words:
        STAGE12_ACT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage12_act_words) + "\n", encoding="utf-8", newline="\n")
    if stage12_weight_words:
        STAGE12_WEIGHT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage12_weight_words) + "\n", encoding="utf-8", newline="\n")
    if stage13_act_words:
        STAGE13_ACT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage13_act_words) + "\n", encoding="utf-8", newline="\n")
    if stage13_weight_words:
        STAGE13_WEIGHT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage13_weight_words) + "\n", encoding="utf-8", newline="\n")
    if stage14_act_words:
        STAGE14_ACT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage14_act_words) + "\n", encoding="utf-8", newline="\n")
    if stage14_weight_words:
        STAGE14_WEIGHT_HEX_FILE.write_text("\n".join(f"{word:08x}" for word in stage14_weight_words) + "\n", encoding="utf-8", newline="\n")
    print(f"Wrote {OUT_FILE}")
    print(f"Wrote {FULL_ACT_HEX_FILE}")
    print(f"Wrote {FULL_WEIGHT_HEX_FILE}")
    if stage2_act_words:
        print(f"Wrote {STAGE2_ACT_HEX_FILE}")
    if stage2_weight_words:
        print(f"Wrote {STAGE2_WEIGHT_HEX_FILE}")
    if stage3_act_words:
        print(f"Wrote {STAGE3_ACT_HEX_FILE}")
    if stage3_weight_words:
        print(f"Wrote {STAGE3_WEIGHT_HEX_FILE}")
    if stage4_act_words:
        print(f"Wrote {STAGE4_ACT_HEX_FILE}")
    if stage4_weight_words:
        print(f"Wrote {STAGE4_WEIGHT_HEX_FILE}")
    if stage5_act_words:
        print(f"Wrote {STAGE5_ACT_HEX_FILE}")
    if stage5_weight_words:
        print(f"Wrote {STAGE5_WEIGHT_HEX_FILE}")
    if stage6_act_words:
        print(f"Wrote {STAGE6_ACT_HEX_FILE}")
    if stage6_weight_words:
        print(f"Wrote {STAGE6_WEIGHT_HEX_FILE}")
    if stage7_act_words:
        print(f"Wrote {STAGE7_ACT_HEX_FILE}")
    if stage7_weight_words:
        print(f"Wrote {STAGE7_WEIGHT_HEX_FILE}")
    if stage8_act_words:
        print(f"Wrote {STAGE8_ACT_HEX_FILE}")
    if stage8_weight_words:
        print(f"Wrote {STAGE8_WEIGHT_HEX_FILE}")
    if stage9_act_words:
        print(f"Wrote {STAGE9_ACT_HEX_FILE}")
    if stage9_weight_words:
        print(f"Wrote {STAGE9_WEIGHT_HEX_FILE}")
    if stage10_act_words:
        print(f"Wrote {STAGE10_ACT_HEX_FILE}")
    if stage10_weight_words:
        print(f"Wrote {STAGE10_WEIGHT_HEX_FILE}")
    if stage11_act_words:
        print(f"Wrote {STAGE11_ACT_HEX_FILE}")
    if stage11_weight_words:
        print(f"Wrote {STAGE11_WEIGHT_HEX_FILE}")
    if stage12_act_words:
        print(f"Wrote {STAGE12_ACT_HEX_FILE}")
    if stage12_weight_words:
        print(f"Wrote {STAGE12_WEIGHT_HEX_FILE}")
    if stage13_act_words:
        print(f"Wrote {STAGE13_ACT_HEX_FILE}")
    if stage13_weight_words:
        print(f"Wrote {STAGE13_WEIGHT_HEX_FILE}")
    if stage14_act_words:
        print(f"Wrote {STAGE14_ACT_HEX_FILE}")
    if stage14_weight_words:
        print(f"Wrote {STAGE14_WEIGHT_HEX_FILE}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
