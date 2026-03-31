import pathlib
import sys


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: elf_to_mem.py <input.bin> <output.mem>", file=sys.stderr)
        return 1

    in_path = pathlib.Path(sys.argv[1])
    out_path = pathlib.Path(sys.argv[2])
    data = in_path.read_bytes()

    if len(data) % 4:
        data += b"\x00" * (4 - (len(data) % 4))

    words = []
    for i in range(0, len(data), 4):
        word = int.from_bytes(data[i:i + 4], byteorder="little", signed=False)
        words.append(f"{word:08x}")

    out_path.write_text("\n".join(words) + ("\n" if words else ""))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
