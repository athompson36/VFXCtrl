#!/usr/bin/env python3
"""
FlashFloppy 3.44 indexed rack — **numeric slot** filenames (empty indexed-prefix in FF.CFG):

    0000_VFX_SD_OS_2.10.IMG
    0001_Stock_Library_Disk.IMG
    0002_ATW_Colorado_alogdig.HFE

Slot = first four digits. Friendly text follows `_`. No DSKA prefix on the stick.

Refreshes under the build folder:
  - Renames on disk (also migrates legacy DSKA####_* → ####_*)
  - VFX_RACK_CATALOG.json, .md, .csv, DUPLICATES_REPORT.md

**Deploy bundle:** copy `000*` + `FF.CFG` only — **not** `IMG.CFG`, `IMAGE_A.CFG`, catalogs, or `.upd`.

Usage (from repo root):
  python3 tools/apply_vfx_rack_friendly_indexed_names.py [path/to/VFX-RACK-BUILD-FF344]
"""
from __future__ import annotations

import csv
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

SUFFIX_MAX_LEN = 96


def raw_suffix_from_source(source_relative_path: str) -> str:
    p = Path(source_relative_path)
    parts = p.parts
    if len(parts) >= 2 and parts[0].lower() == "blanks":
        m = re.match(r"blank(\d+)$", p.stem, re.I)
        if m:
            return f"Blank_{int(m.group(1)):03d}"
    without_ext = str(p.with_suffix("")).replace("\\", "/")
    segments = without_ext.split("/")
    return "_".join(seg.replace(" ", "_") for seg in segments)


def sanitize_suffix(s: str) -> str:
    s = s.strip()
    for c in '\\/:*?"<>|':
        s = s.replace(c, "_")
    s = s.replace(" ", "_")
    s = re.sub(r"_+", "_", s)
    s = s.strip("_.")
    if len(s) > SUFFIX_MAX_LEN:
        s = s[: SUFFIX_MAX_LEN].rstrip("_.")
    return s or "disk"


def disambiguate_suffixes(slots: list[dict]) -> list[str]:
    bases: list[str] = []
    for item in slots:
        raw = raw_suffix_from_source(item["source_relative_path"])
        bases.append(sanitize_suffix(raw))

    seen: dict[str, int] = {}
    out: list[str] = []
    for i, item in enumerate(slots):
        b = bases[i]
        key = b.lower()
        if key not in seen:
            seen[key] = item["slot"]
            out.append(b)
        else:
            out.append(f"{b}_s{item['slot']:03d}")
    return out


def indexed_basename(slot: int, suffix: str, ext_uc: str) -> str:
    return f"{slot:04d}_{suffix}.{ext_uc}"


def legacy_plain_dska(slot: int, ext_lower: str) -> str:
    return f"DSKA{slot:04d}{ext_lower}"


def _write_markdown(data: dict, md_path: Path) -> None:
    lines = [
        "# VFX-SD indexed rack catalog (FlashFloppy 3.44)",
        "",
        "Build: **`VFX-RACK-BUILD-FF344`** — `indexed-prefix = \"\"` → files **`0000_*` … `0163_*`**. ",
        "Source: `ensoniq-vfx-sd/VFX-SD Backup`",
        "",
        "| Slot | Indexed file | Friendly label | Source path | Size | SHA256 (prefix) |",
        "| ---: | --- | --- | --- | ---: | --- |",
    ]
    for s in data["slots"]:
        h = (s.get("sha256") or "")[:16] + "…" if s.get("sha256") else ""
        fn = s["indexed_filename"].replace("|", "\\|")
        lab = s["friendly_label"].replace("|", "\\|")
        src = s["source_relative_path"].replace("|", "\\|")
        lines.append(f"| {s['slot']} | `{fn}` | {lab} | `{src}` | {s['size_bytes']} | `{h}` |")
    lines.append("")
    md_path.write_text("\n".join(lines), encoding="utf-8")


def _write_csv(data: dict, csv_path: Path) -> None:
    with open(csv_path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(
            ["slot", "indexed_filename", "friendly_label", "source_relative_path", "size_bytes", "sha256"]
        )
        for s in data["slots"]:
            w.writerow(
                [
                    s["slot"],
                    s["indexed_filename"],
                    s["friendly_label"],
                    s["source_relative_path"],
                    s["size_bytes"],
                    s.get("sha256") or "",
                ]
            )


def _write_duplicates_report(data: dict, report_path: Path) -> None:
    by_hash: dict[str, list[dict]] = defaultdict(list)
    for s in data["slots"]:
        h = s.get("sha256") or ""
        if h:
            by_hash[h].append(s)
    dups = {h: rows for h, rows in by_hash.items() if len(rows) > 1}
    lines = [
        "# VFX-SD rack — duplicate image content (SHA-256)",
        "",
        "Exact byte-identical files only. This build **keeps** each slot file; use for awareness.",
        "",
    ]
    if not dups:
        lines.append("No duplicate checksums detected among catalogued slots.")
    else:
        for h in sorted(dups.keys()):
            rows = sorted(dups[h], key=lambda r: int(r["slot"]))
            lines.append(f"## `{h[:16]}…`")
            lines.append("")
            for r in rows:
                lines.append(
                    f"- Slot {int(r['slot']):03d}: `{r['indexed_filename']}` ← `{r['source_relative_path']}`"
                )
            lines.append("")
    report_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def _write_ff344_cfg(build: Path) -> None:
    """FlashFloppy 3.44 + VFX-SD: empty indexed-prefix, numeric slot files 0000_*.IMG."""
    text = """## FF.CFG — Ensoniq VFX-SD + FlashFloppy 3.44 (indexed, numeric slots)
##
## indexed-prefix = \"\"  →  slot files must be named 0000_*.*, 0001_*.*, … (four digits).
## Deploy: copy 000*.HFE / 000*.IMG + this FF.CFG only. Do NOT copy IMAGE_A.CFG or IMG.CFG.
##
## Note: FF 3.x uses autoselect-file-secs (seconds), not autoselect-file=yes. Non-zero enables auto-select.

interface = shugart
host = ensoniq
nav-mode = indexed
indexed-prefix = ""
pin02 = auto
pin34 = ready
write-protect = no

ejected-on-startup = no
image-on-startup = init

display-type = auto
oled-font = 6x13
display-order = 0,1
display-off-secs = 60
display-on-activity = yes

autoselect-file-secs = 2
autoselect-folder-secs = 2
folder-sort = always
sort-priority = files
nav-loop = yes
twobutton-action = zero
rotary = none

motor-delay = 200
step-delay = 3
track-change = instant
write-drain = instant
head-settle-ms = 12
chgrst = delay-3

display-scroll-rate = 200
display-scroll-pause = 2000
nav-scroll-rate = 80
nav-scroll-pause = 300

step-volume = 10
extend-image = yes
"""
    (build / "FF.CFG").write_text(text, encoding="utf-8")


def apply_build(build: Path) -> int:
    cat_path = build / "VFX_RACK_CATALOG.json"
    if not cat_path.is_file():
        print("Missing:", cat_path, file=sys.stderr)
        return 1

    with open(cat_path, encoding="utf-8") as f:
        data = json.load(f)

    slots: list[dict] = data["slots"]
    suffixes = disambiguate_suffixes(slots)

    renames: list[tuple[str, str]] = []
    for item, suf in zip(slots, suffixes):
        prev_name = item["indexed_filename"]
        ext = Path(prev_name).suffix
        if not ext:
            print("No extension:", prev_name, file=sys.stderr)
            return 1
        ext_lc = ext.lower()
        ext_uc = ext.upper().lstrip(".")
        new_name = indexed_basename(int(item["slot"]), suf, ext_uc)
        item["indexed_filename"] = new_name

        old_path = build / prev_name
        if not old_path.is_file():
            plain_dska = build / legacy_plain_dska(int(item["slot"]), ext_lc)
            if plain_dska.is_file():
                old_path = plain_dska
                prev_name = plain_dska.name

        new_path = build / new_name
        if prev_name == new_name:
            continue
        if not old_path.is_file():
            print("MISSING:", prev_name, "→", new_name, file=sys.stderr)
            continue
        if new_path.exists() and old_path.resolve() != new_path.resolve():
            print("COLLISION:", new_name, file=sys.stderr)
            return 1
        if old_path.resolve() != new_path.resolve():
            old_path.rename(new_path)
            renames.append((prev_name, new_name))

    with open(cat_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")

    _write_markdown(data, build / "VFX_RACK_CATALOG.md")
    _write_csv(data, build / "VFX_RACK_CATALOG.csv")
    _write_duplicates_report(data, build / "DUPLICATES_REPORT.md")

    img_cfg = build / "IMG.CFG"
    if img_cfg.is_file():
        img_cfg.unlink()

    _write_ff344_cfg(build)

    print(f"OK: {len(renames)} rename(s); FF.CFG (FF 3.44); catalog refreshed; numeric 0000_* filenames.")
    return 0


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    build = Path(sys.argv[1]) if len(sys.argv) > 1 else root / "gotek/ensoniq-vfx-sd/VFX-RACK-BUILD-FF344"
    return apply_build(build)


if __name__ == "__main__":
    raise SystemExit(main())
