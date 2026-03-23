# FF.CFG changelog — VFX-RACK-BUILD-FF344

## 2026-03-23 — SamplerZone Gotek Extended (34×19 mm OLED) optimization

Aligned with FlashFloppy **3.44** [FF.CFG wiki](https://github.com/keirf/FlashFloppy/wiki/FF.CFG-Configuration-File) only (no `IMAGE_A.CFG`, no `IMG.CFG`, no undocumented keys).

### Behavior

| Setting | Before | After | Why |
| --- | --- | --- | --- |
| `autoselect-file-secs` | `2` | `0` | Disable timed auto-mount while browsing |
| `autoselect-folder-secs` | `2` | `0` | Same for folders |
| `ejected-on-startup` | `no` | `yes` | No auto-inserted disk at power-up |
| `rotary` | `none` | `full` | Encoder is standard on this hardware |
| `display-off-secs` | `60` | `255` | Keep OLED on (playing-distance readability) |
| `display-scroll-rate` | `200` ms | `400` ms | Slower filename scroll |
| `display-scroll-pause` | `2000` ms | `1800` ms | Pause at scroll ends (tunable) |
| `nav-scroll-rate` | `80` | `180` | Slower scroll while navigating |
| `nav-scroll-pause` | `300` | `800` | Longer pause before nav scroll |

Unchanged: `interface=shugart`, `host=ensoniq`, `nav-mode=indexed`, `indexed-prefix=""`, `display-order=0,1` (image name + status), `image-on-startup=init`, `motor-delay=200`, `chgrst=delay-3`, `step-delay=3` (remove `step-delay` if your build ignores it).

### Spec note

Some guides mention `display-nav-name`, `display-slot`, `autoselect-file` — those are **not** valid FlashFloppy 3.44 options. The wiki equivalents are **`display-order`** (rows 0=name, 1=status/track info) and **`autoselect-file-secs` / `autoselect-folder-secs`**.

### Filenames (same commit)

Six slots got shorter OLED-friendly suffixes (slot unchanged): 27–30 (ATW Colorado VFXsd*), 141–142 (Ensoniq VFX keys/RAM). Regenerated `VFX_RACK_CATALOG.*` and `DUPLICATES_REPORT.md`.

---

## 2026-03-23 — 128×64 OLED layout (fix EjectMenu / missing filename)

On SamplerZone **Extended** hardware, `display-type = auto` with `display-order = 0,1` can match the **128×32** preset. The lower half of a **128×64** panel may then show **EjectMenu** and **`000/163 IMG`** without the FAT filename.

| Setting | Previous rack | Updated | Why |
| --- | --- | --- | --- |
| `display-type` | `auto` | `oled-128x64` | Force 64-pixel-tall layout per [FF.CFG wiki](https://github.com/keirf/FlashFloppy/wiki/FF.CFG-Configuration-File) |
| `display-order` | `0,1` | `0d,1` | `0d` = **double-height** current image name; `1` = status (wiki row specifiers) |
| `ejected-on-startup` | `yes` | `no` | Ejected state can use **menu** layouts where `display-order` is ignored; starting **inserted** on `image-on-startup = init` shows the normal filename UI. **Autoselect stays 0** so scrolling slots does not auto-mount. Eject with buttons when you want no disk. |

If your module is actually **128×32**, set `display-type = auto` and `display-order = 0,1` again.

---

## 2026-03-23 — Status line on true bottom + large name (`0d,7,1`)

`0d,1` used only ~48 px of a 64 px OLED (double-height name + status), leaving the bottom **16 px** unused.

**`0,7,1`** (single-height name) looked wrong on hardware: only two visible text lines, tiny font, and the status line was **not** on the physical bottom — FlashFloppy pads the **fourth** 16 px band with blank (`7`), so the order is name → blank → **status** → **blank**.

**`display-order = 0d,7,1`** fills all four bands: **double-height** image name (32 px), blank spacer (16 px), status (16 px) on the **lowest** row — ~**3/4** above the status line, **1/4** for `NNN/163 HFE`. The full basename still appears on content row **0** only (no underscore split without a firmware fork); see `docs/GOTEK_OLED_LAYOUT_LIMITS.md`.

| Setting | Previous | Updated | Why |
| --- | --- | --- | --- |
| `display-order` | `0,7,1` | `0d,7,1` | Large (`0d`) name; status on bottom 16 px; no stray blank row under status |

---

## 2026-03-23 — Bolder font + clockwise slot increase

| Setting | Was | Now | Why |
| --- | --- | --- | --- |
| `oled-font` | `6x13` | `8x16` | Thicker characters, less “dot matrix” look ([FF.CFG wiki](https://github.com/keirf/FlashFloppy/wiki/FF.CFG-Configuration-File) — fewer chars per line). |
| `rotary` | `full` | `full,reverse` | `reverse` swaps encoder direction so **clockwise** advances the slot / selection. Remove `,reverse` if direction is wrong on your unit. |
