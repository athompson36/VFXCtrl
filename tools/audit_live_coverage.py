#!/usr/bin/env python3
"""
Compare ParameterMap.swift keys to LiveSysExBuilder live keys.

Run from repo root:
  python3 tools/audit_live_coverage.py

Exit 0 always (informational). Use output to close gaps in LiveSysExBuilder or
reclassify params to sysexPage 998+ in ParameterMap.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAP_FILE = ROOT / "src" / "patch" / "ParameterMap.swift"
LIVE_FILE = ROOT / "src" / "midi" / "LiveSysExBuilder.swift"

T_KEY_RE = re.compile(r't\["([^"]+)"\]\s*=')


def parse_parameter_rows(text: str) -> list[tuple[str, int]]:
    """One ParameterDefinition per line (as in ParameterMap.swift)."""
    rows: list[tuple[str, int]] = []
    for line in text.splitlines():
        if ".init(key:" not in line or "sysexPage:" not in line:
            continue
        mk = re.search(r'\.init\(key:\s*"([^"]+)"', line)
        mp = re.search(r"sysexPage:\s*(\d+)", line)
        if mk and mp:
            rows.append((mk.group(1), int(mp.group(1))))
    return rows


def parse_live_table_keys(text: str) -> set[str]:
    keys: set[str] = set()
    in_table = False
    for line in text.splitlines():
        if "static let parameterAddressTable" in line:
            in_table = True
        if in_table and line.strip().startswith("}()"):
            break
        if in_table:
            for m in T_KEY_RE.finditer(line):
                keys.add(m.group(1))
    return keys


def parse_virtual_and_cc(text: str) -> set[str]:
    extra: set[str] = set()
    # ccParameterKeys
    if m := re.search(
        r"static let ccParameterKeys: Set<String> = \[(.*?)\]",
        text,
        re.DOTALL,
    ):
        extra.update(re.findall(r'"([^"]+)"', m.group(1)))
    if m := re.search(
        r"static let virtualButtonKeys: Set<String> = \[(.*?)\]",
        text,
        re.DOTALL,
    ):
        extra.update(re.findall(r'"([^"]+)"', m.group(1)))
    return extra


def main() -> int:
    if not MAP_FILE.is_file() or not LIVE_FILE.is_file():
        print("Missing source files.", file=sys.stderr)
        return 1

    map_text = MAP_FILE.read_text(encoding="utf-8")
    live_text = LIVE_FILE.read_text(encoding="utf-8")

    rows = parse_parameter_rows(map_text)
    map_keys = {k for k, _ in rows}
    by_key_page = {k: p for k, p in rows}

    table_keys = parse_live_table_keys(live_text)
    extra = parse_virtual_and_cc(live_text)
    live_keys = table_keys | extra

    # Hardware-backed map rows: not UI-only pages 997–999 or legacy 998
    hardware = {k for k, p in by_key_page.items() if p < 997}

    in_map_not_live = sorted(hardware - live_keys)
    in_live_not_map = sorted(live_keys - map_keys)

    print("# Live vs ParameterMap audit\n")
    print(f"- Parameter map keys (total): **{len(map_keys)}**")
    print(f"- Keys in `parameterAddressTable` + CC + virtual: **{len(live_keys)}**")
    print(f"- Map keys with sysexPage < 997 (intended hardware): **{len(hardware)}**")
    print()
    print("## In ParameterMap (hardware page) but not in live builder\n")
    if not in_map_not_live:
        print("_None._\n")
    else:
        for k in in_map_not_live:
            print(f"- `{k}` (sysexPage {by_key_page[k]})")
        print()

    print("## In live builder but not in ParameterMap\n")
    if not in_live_not_map:
        print("_None._\n")
    else:
        for k in in_live_not_map:
            print(f"- `{k}`")
        print()

    print(
        "## Notes\n\n"
        "- Rows with sysexPage **998** / **999** / **997** are UI, macro, or legacy aliases — "
        "they are excluded from the “hardware” bucket above.\n"
        "- Add missing live rows to `LiveSysExBuilder.parameterAddressTable` or bump sysexPage to **998** "
        "with a note if intentionally patch-only.\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
