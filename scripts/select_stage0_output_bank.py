#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LAYER_DIR = ROOT / "sw" / "dronet_v3" / "generated" / "layer_payloads"


def stage_paths(stage: str) -> tuple[Path, Path, Path, Path]:
    return (
        LAYER_DIR / f"{stage}_output_bank0_words.hex",
        LAYER_DIR / f"{stage}_output_bank1_words.hex",
        LAYER_DIR / f"{stage}_output_words.hex",
        LAYER_DIR / f"{stage}_output_summary.json",
    )


def load_words(path: Path) -> list[str]:
    if not path.exists():
        raise FileNotFoundError(path)
    return [line.strip().lower() for line in path.read_text().splitlines() if line.strip()]


def summarize(words: list[str]) -> dict[str, object]:
    known = 0
    unknown = 0
    nonzero_known = 0
    first_nonzero = None
    first_unknown = None
    sanitized: list[str] = []
    for idx, word in enumerate(words):
        if len(word) != 8 or any(ch not in "0123456789abcdef" for ch in word):
            unknown += 1
            if first_unknown is None:
                first_unknown = {"index": idx, "value": word}
            sanitized.append("00000000")
            continue
        known += 1
        if int(word, 16) != 0:
            nonzero_known += 1
            if first_nonzero is None:
                first_nonzero = {"index": idx, "value": word}
        sanitized.append(word)
    return {
        "line_count": len(words),
        "known_count": known,
        "unknown_count": unknown,
        "nonzero_known_count": nonzero_known,
        "first_nonzero": first_nonzero,
        "first_unknown": first_unknown,
        "sanitized_words": sanitized,
    }


def pick_bank(bank0: dict[str, object], bank1: dict[str, object]) -> str:
    score0 = (bank0["nonzero_known_count"], -bank0["unknown_count"])
    score1 = (bank1["nonzero_known_count"], -bank1["unknown_count"])
    return "bank1" if score1 > score0 else "bank0"


def main() -> None:
    stage = sys.argv[1] if len(sys.argv) > 1 else "stage0"
    bank0_path, bank1_path, out_hex, out_json = stage_paths(stage)
    bank0_words = load_words(bank0_path)
    bank1_words = load_words(bank1_path)
    bank0 = summarize(bank0_words)
    bank1 = summarize(bank1_words)
    selected = pick_bank(bank0, bank1)
    chosen = bank1 if selected == "bank1" else bank0

    out_hex.write_text("".join(f"{word}\n" for word in chosen["sanitized_words"]))
    report = {
        "stage": stage,
        "selected_bank": selected,
        "bank0": {k: v for k, v in bank0.items() if k != "sanitized_words"},
        "bank1": {k: v for k, v in bank1.items() if k != "sanitized_words"},
        "output_hex": str(out_hex.relative_to(ROOT)).replace("\\", "/"),
        "sanitization": "unknown words replaced with 00000000",
    }
    out_json.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
