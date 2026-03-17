#!/usr/bin/env python3
import argparse
from pathlib import Path

def read_bytes(path: Path) -> bytes:
    return path.read_bytes()


def hexdump(data: bytes, width: int = 16) -> str:
    lines = []
    for i in range(0, len(data), width):
        chunk = data[i:i+width]
        hex_part = ' '.join(f'{b:02X}' for b in chunk)
        lines.append(f'{i:06X}  {hex_part}')
    return '\n'.join(lines)


def diff(a: bytes, b: bytes):
    out = []
    max_len = max(len(a), len(b))
    for i in range(max_len):
        av = a[i] if i < len(a) else None
        bv = b[i] if i < len(b) else None
        if av != bv:
            out.append((i, av, bv))
    return out


def main():
    parser = argparse.ArgumentParser(description='Inspect and diff VFX-SD SysEx captures')
    parser.add_argument('file_a', type=Path)
    parser.add_argument('file_b', nargs='?', type=Path)
    args = parser.parse_args()

    a = read_bytes(args.file_a)
    print(f'File A: {args.file_a} ({len(a)} bytes)')
    print(hexdump(a))

    if args.file_b:
        b = read_bytes(args.file_b)
        print(f'\nFile B: {args.file_b} ({len(b)} bytes)')
        print(hexdump(b))
        print('\nDifferences:')
        for offset, av, bv in diff(a, b):
            a_hex = '--' if av is None else f'{av:02X}'
            b_hex = '--' if bv is None else f'{bv:02X}'
            print(f'0x{offset:04X}: {a_hex} -> {b_hex}')

if __name__ == '__main__':
    main()
