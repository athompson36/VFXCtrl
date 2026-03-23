# Ensoniq VFX-SD Gotek — FlashFloppy 3.44 indexed friendly-name workflow

This is the **current** rack policy for the in-repo build **`gotek/ensoniq-vfx-sd/VFX-RACK-BUILD-FF344/`**. It supersedes earlier DSKA-prefixed layouts.

## Verified target stack

- **Synth:** Ensoniq VFX-SD  
- **Gotek:** SFRKC30.AT2 (rotary encoder)  
- **Firmware:** FlashFloppy **3.44**  
- **USB:** FAT32, MBR  
- **Prep OS:** macOS  

## Indexed mode (FF 3.44)

FlashFloppy matches files as:

`<indexed-prefix><4-digit-slot>*.*`

With **`indexed-prefix = ""`** (empty, quoted in `FF.CFG`), patterns are:

- `0000*.*`, `0001*.*`, `0002*.*`, …

The **slot** is the leading four digits. Any text after that (e.g. `_ATW_Colorado_Pads`) is part of the **filename** and is shown on the Gotek display—there is **no** `DSKA` prefix on the stick.

## Required `FF.CFG` (summary)

Shipped in the build folder; keys include:

- `interface = shugart`
- `host = ensoniq`
- `nav-mode = indexed`
- `indexed-prefix = ""`
- `pin34 = ready`
- `display-type = auto`
- `image-on-startup = init`
- `motor-delay = 200` (and other stability-related options as in the file)

**Auto-select:** FlashFloppy 3.x uses **`autoselect-file-secs`** (seconds), not `autoselect-file=yes`. The bundled file uses a small non-zero value (e.g. `2`) to enable auto-select behavior.

Do **not** deploy **`IMAGE_A.CFG`**.

Do **not** deploy **`IMG.CFG`** for this workflow (no label map; avoid extra macOS copy issues and stick clutter).

If **`step-delay`** is not recognized by your exact build, delete that line.

## Disk filenames on USB

Pattern:

`0000_Friendly_Name.IMG`  
`0001_Friendly_Name.IMG`  
`0002_Friendly_Name.HFE`  

Rules:

- First **four digits** = slot (zero-padded).  
- **`_`** then a sanitized, concise descriptive name (spaces → `_`, `/` → `_`, collapse `__`, FAT-safe).  
- **`.IMG` / `.HFE`** preserved; use **uppercase** extensions in the rack build.  
- Do **not** convert image types.

Slot **0000** = VFX-SD OS disk (e.g. `0000_VFX_SD_OS_2.10.IMG`).  
Slot **0001** = stock library (e.g. `0001_Stock_Library_Disk.IMG`).  
Remaining slots follow a **deterministic** order from the backup (root → ATW → Ensoniq → blanks, etc.).

## Duplicates

Checksums are recorded in **`VFX_RACK_CATALOG.json`**. **`DUPLICATES_REPORT.md`** lists SHA-256 collisions. The rack **keeps** one file per slot (including template blanks that share bytes); nothing is silently deduped away unless you run a separate dedupe pass.

## Build outputs (in repo)

| Path | Role |
| --- | --- |
| `VFX-RACK-BUILD-FF344/000*.IMG` / `000*.HFE` | Deploy payloads |
| `VFX-RACK-BUILD-FF344/FF.CFG` | FlashFloppy config |
| `VFX_RACK_CATALOG.json` / `.md` / `.csv` | Librarian / human reference |
| `DUPLICATES_REPORT.md` | Duplicate checksum report |

Optional: copy the whole folder to **`~/Documents/VFX-RACK-BUILD-FF344/`** for offline prep; deploy only `000*` + `FF.CFG`.

## Deployment (macOS)

```bash
diskutil eraseDisk FAT32 GOTEK MBRFormat /dev/diskX
cp /path/to/VFX-RACK-BUILD-FF344/000* /Volumes/GOTEK/
cp /path/to/VFX-RACK-BUILD-FF344/FF.CFG /Volumes/GOTEK/
sync
```

Do **not** copy `IMAGE_A.CFG`, `IMG.CFG`, catalogs, README, `.upd`, or AppleDouble `._*` files.

After prep, use **Finder** or **`dot_clean`** on the volume if needed to strip `._*` before the Gotek sees the stick.

## Regenerating the rack

From repo root:

```bash
python3 tools/apply_vfx_rack_friendly_indexed_names.py gotek/ensoniq-vfx-sd/VFX-RACK-BUILD-FF344
```

This refreshes numeric filenames from `source_relative_path` rules, rewrites **`FF.CFG`** for FF 3.44, removes **`IMG.CFG`** from the build folder, and updates catalogs + duplicate report.

## VFX-CTRL app

**Floppy Emulator** → **Indexed disk rack**: choose `VFX-RACK-BUILD-FF344`, **Show in Finder**, **Copy deployables to SD/USB**. The app copies only `000*_*.HFE` / `000*_*.IMG` and `FF.CFG` (not `IMG.CFG`, not `._*`).

For **library `.syx` export**, the USB export sheet still defaults to **`DSKA`** prefix if you want classic `DSKA0000_*.syx` names; set **`indexed-prefix`** in `FF.CFG` to match.

## Success criteria

- Slot **0000** boots the OS image.  
- Encoder advances slots reliably.  
- Display shows **friendly** filenames (no `DSKA` prefix).  
- No missing-file errors when selecting slots.  
- Rebuild from backup + script is **deterministic**.
