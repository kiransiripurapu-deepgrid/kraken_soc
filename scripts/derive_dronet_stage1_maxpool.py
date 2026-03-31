#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LAYER_DIR = ROOT / "sw" / "dronet_v3" / "generated" / "layer_payloads"
INPUT_HEX = LAYER_DIR / "stage0_output_words.hex"
OUTPUT_HEX = LAYER_DIR / "stage1_maxpool_output_words.hex"
OUTPUT_JSON = LAYER_DIR / "stage1_maxpool_output_summary.json"

IN_H = 100
IN_W = 100
CHANNELS = 4
POOL = 2
STRIDE = 2
OUT_H = 50
OUT_W = 50


def read_words(path: Path) -> list[int]:
    vals: list[int] = []
    for raw in path.read_text().splitlines():
        word = raw.strip().lower()
        if not word:
            continue
        if len(word) != 8 or any(ch not in "0123456789abcdef" for ch in word):
            raise ValueError(f"invalid word in {path}: {word}")
        vals.append(int(word, 16))
    return vals


def unpack_bytes(words: list[int]) -> list[int]:
    out: list[int] = []
    for word in words:
        out.extend([(word >> shift) & 0xFF for shift in (0, 8, 16, 24)])
    return out


def pack_words(values: list[int]) -> list[int]:
    words: list[int] = []
    for i in range(0, len(values), 4):
        chunk = values[i:i + 4]
        while len(chunk) < 4:
            chunk.append(0)
        word = chunk[0] | (chunk[1] << 8) | (chunk[2] << 16) | (chunk[3] << 24)
        words.append(word)
    return words


def at(buf: list[int], y: int, x: int, c: int) -> int:
    return buf[(y * IN_W + x) * CHANNELS + c]


def main() -> None:
    words = read_words(INPUT_HEX)
    values = unpack_bytes(words)
    expected = IN_H * IN_W * CHANNELS
    if len(values) < expected:
        raise ValueError(f"expected at least {expected} activation bytes, found {len(values)}")
    values = values[:expected]

    pooled: list[int] = []
    for oy in range(OUT_H):
      for ox in range(OUT_W):
        iy = oy * STRIDE
        ix = ox * STRIDE
        for c in range(CHANNELS):
            m = max(
                at(values, iy + ky, ix + kx, c)
                for ky in range(POOL)
                for kx in range(POOL)
            )
            pooled.append(m)

    out_words = pack_words(pooled)
    OUTPUT_HEX.write_text("".join(f"{word:08x}\n" for word in out_words))
    summary = {
        "input_hex": str(INPUT_HEX.relative_to(ROOT)).replace("\\", "/"),
        "output_hex": str(OUTPUT_HEX.relative_to(ROOT)).replace("\\", "/"),
        "input_shape_hwc": [IN_H, IN_W, CHANNELS],
        "output_shape_hwc": [OUT_H, OUT_W, CHANNELS],
        "pool_kernel": [POOL, POOL],
        "stride": [STRIDE, STRIDE],
        "word_count": len(out_words),
        "first_words": [f"{w:08x}" for w in out_words[:8]],
    }
    OUTPUT_JSON.write_text(json.dumps(summary, indent=2) + "\n")
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
