# Ensoniq VFX-SD Gotek — FlashFloppy 3.44 indexed friendly-name workflow

This is the **current** rack policy for the in-repo build **`gotek/ensoniq-vfx-sd/VFX-RACK-BUILD-FF344/`**. It targets the **[SamplerZone Gotek Extended](https://samplerzone.com/products/gotek-extended-floppy-emulator)** (34×19 mm OLED, rotary encoder, two buttons) and FlashFloppy **3.44**, while remaining valid for any Gotek running the same firmware options.

## Verified target stack

- **Synth:** Ensoniq VFX-SD  
- **Gotek:** SamplerZone Gotek Extended (or equivalent OLED + rotary)  
- **Firmware:** FlashFloppy **3.44**  
- **USB:** FAT32, MBR  
- **Prep OS:** macOS  

## Indexed mode (FF 3.44)

FlashFloppy matches files as:

`<indexed-prefix><4-digit-slot>*.*`

With **`indexed-prefix = ""`** (empty, quoted in `FF.CFG`), patterns are:

- `0000*.*`, `0001*.*`, `0002*.*`, …

The **slot** is the leading four digits. Any text after that (e.g. `_ATW_Colorado_Demos`) is part of the **filename** and is shown on the Gotek display—there is **no** `DSKA` prefix on the stick.

## FF.CFG baseline (extended OLED, manual selection)

Shipped **`FF.CFG`** is tuned for:

- **Indexed reliability:** `nav-mode = indexed`, `indexed-prefix = ""`, `nav-loop = yes`  
- **Ensoniq:** `interface = shugart`, `host = ensoniq`, `pin02 = auto`, `pin34 = ready`  
- **Manual mount:** `autoselect-file-secs = 0`, `autoselect-folder-secs = 0` (FlashFloppy uses **seconds** here; `0` disables auto-select — there is no `autoselect-file=yes` in FF 3.44)  
- **Power-up:** `ejected-on-startup = no`, `image-on-startup = init` — start on the **normal navigation** screen with slot 0000 selected so the **FAT filename** is visible. (`ejected-on-startup = yes` can leave a **EjectMenu** / slot-count layout on 128×64 hardware where the name row never appears.) Eject with the Gotek buttons when you want no disk.  
- **Rotary + buttons:** `rotary = full,reverse` so **clockwise** increases slot (omit `,reverse` if your wiring is already correct). `twobutton-action = zero` (default prev/next/slot-0).  
- **Font:** `oled-font = 8x16` for bolder text than `6x13` (trade-off: slightly fewer characters per scroll line).  
- **Display (128×64 Extended OLED):** `display-type = oled-128x64`, `display-order = 0d,7,1` — **`0d`** = **double-height** current **image name** (32 px, `oled-font = 8x16`), **`7`** = blank 16 px spacer, **`1`** = **status** on the **lowest** 16 px (`002/163 HFE`, etc.). That is a **3/4 + 1/4** vertical split (48 px above the status line, 16 px status). Do **not** use `0,7,1` if you want the status line on the physical bottom: FlashFloppy pads missing `display-order` nibbles with blank rows, so `0,7,1` leaves a **fourth** blank band *under* the status. **Splitting the filename at the last `_` into two separate name rows is not possible** with stock FlashFloppy (one string → content row 0 only); see `docs/GOTEK_OLED_LAYOUT_LIMITS.md`. There is **no** `display-nav-name` in official FF.CFG. Wiki default for 128×64 is `3,0d,1` (subfolder + double-height name + status); we use `0d,7,1` so indexed root does not rely on row **3** (current folder).  
- **Readability:** `display-off-secs = 255` (panel stays on), `display-scroll-rate = 400`, `display-scroll-pause = 1800`, `nav-scroll-rate = 180`, `nav-scroll-pause = 800` (all **milliseconds**; wiki minimum for `display-scroll-rate` is **100**)  

**Stability (unchanged where safe):** `motor-delay = 200`, `track-change = instant`, `write-drain = instant`, `head-settle-ms = 12`, `chgrst = delay-3`, `extend-image = yes`.

Optional line **`step-delay = 3`** is kept from the prior rack; if your firmware build ignores unknown keys, it is harmless. If a parser complains, remove it (see `BUILD_README.txt`).

Do **not** deploy **`IMAGE_A.CFG`** (avoid `image-on-startup = last` dependency).

Do **not** deploy **`IMG.CFG`** for this workflow.

Changelog: **`FF_CFG_CHANGELOG.md`** in the build folder.

## Disk filenames on USB

Pattern:

`0000_Friendly_Name.IMG`  
`0001_Friendly_Name.IMG`  
`0002_Friendly_Name.HFE`  

Rules:

- First **four digits** = slot (zero-padded).  
- **`_`** then a concise, sanitized descriptive name (spaces → `_`, `/` → `_`, collapse `__`, FAT-safe). Prefer **short** names on the larger OLED so scrolling is rare.  
- **`.IMG` / `.HFE`** preserved; use **uppercase** extensions in the rack build.  
- Do **not** convert image types.

Slot **0000** = VFX-SD OS disk (e.g. `0000_VFX_SD_OS_2.10.IMG`).  
Slot **0001** = stock library (e.g. `0001_Stock_Library_Disk.IMG`).  
Remaining slots follow a **deterministic** order from the backup (root → ATW → Ensoniq → blanks, etc.). Selected slots use **display overrides** in `tools/apply_vfx_rack_friendly_indexed_names.py` for shorter names (e.g. `0027_ATW_Colorado_Demos.HFE`).

## Duplicates

Checksums are recorded in **`VFX_RACK_CATALOG.json`**. **`DUPLICATES_REPORT.md`** lists SHA-256 collisions. The rack **keeps** one file per slot (including template blanks that share bytes); nothing is silently deduped away unless you run a separate dedupe pass.

## Build outputs (in repo)

| Path | Role |
| --- | --- |
| `VFX-RACK-BUILD-FF344/000*.IMG` / `000*.HFE` | Deploy payloads |
| `VFX-RACK-BUILD-FF344/FF.CFG` | FlashFloppy config |
| `VFX_RACK_CATALOG.json` / `.md` / `.csv` | Librarian / human reference |
| `DUPLICATES_REPORT.md` | Duplicate checksum report |
| `FF_CFG_CHANGELOG.md` | FF.CFG + naming change history |

Optional: copy the whole folder to **`~/Documents/VFX-RACK-BUILD-FF344/`** for offline prep; deploy only `000*` + `FF.CFG`.

## Deployment (macOS)

```bash
diskutil eraseDisk FAT32 GOTEK MBRFormat /dev/diskX
cp /path/to/VFX-RACK-BUILD-FF344/000* /Volumes/GOTEK/
cp /path/to/VFX-RACK-BUILD-FF344/FF.CFG /Volumes/GOTEK/
sync
diskutil eject /dev/diskX
```

If you use an **`FF/`** folder on the stick, place **`FF.CFG` there** (not the root).

Do **not** copy `IMAGE_A.CFG`, `IMG.CFG`, catalogs, README, `.upd`, or AppleDouble `._*` files.

After prep, use **Finder** or **`dot_clean`** on the volume if needed to strip `._*` before the Gotek sees the stick.

## Regenerating the rack

From repo root:

```bash
python3 tools/apply_vfx_rack_friendly_indexed_names.py gotek/ensoniq-vfx-sd/VFX-RACK-BUILD-FF344
```

This refreshes numeric filenames from catalog rules + slot display overrides, rewrites **`FF.CFG`** for FF 3.44, removes **`IMG.CFG`** from the build folder, and updates catalogs + duplicate report.

## VFX-CTRL app

**Floppy Emulator** → **FF.CFG** editor **Apply recommended (VFX-SD rack + extended OLED)** merges the same baseline (for the active `indexed-prefix`, including `""`).

**Indexed disk rack:** choose `VFX-RACK-BUILD-FF344`, **Copy deployables to SD/USB**. The app copies only `000*_*.HFE` / `000*_*.IMG` and `FF.CFG`.

For **library `.syx` export**, the USB export sheet can still use a **`DSKA`** prefix; set **`indexed-prefix`** in `FF.CFG` to match if you mix loose `.syx` with indexed disk images.

## Success criteria

- Slot **0000** boots the OS image.  
- **Encoder:** browse slots without timed auto-mount; **press** to mount (FF default behavior with `autoselect-* = 0`).  
- Display shows **friendly** filenames in **double-height** row 0 with **status on the bottom 16 px** (`display-order` **0d,7,1** on 128×64), not a half-screen EjectMenu with no name.  
- No missing-file errors when selecting slots.  
- Rebuild from backup + script is **deterministic**.
