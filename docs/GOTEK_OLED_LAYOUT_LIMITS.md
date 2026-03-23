# Gotek OLED layout limits (FlashFloppy 3.44)

## What FF.CFG can do

- **`display-order`** maps **content types** to **physical rows** on the panel (see [FF.CFG wiki](https://github.com/keirf/FlashFloppy/wiki/FF.CFG-Configuration-File)). List order is **top to bottom** on the OLED. Each entry is one **16 px** band unless marked with **`d`** (double height = **32 px** for that content).
- Common specifiers: **`0`** = current image **name**, **`0d`** = same content **double height**, **`1`** = **status** (e.g. `002/163 HFE`), **`7`** = **blank**, **`3`** = current **subfolder** name.
- **`oled-font`** applies **globally** (`6x13` vs `8x16`); you cannot assign different fonts per row.

## Padding gotcha (why `0,7,1` looked wrong)

`parse_display_order` in FlashFloppy fills any **unused** high nibbles with **`7`** (blank). For a **128×64** panel there are **four** 16 px bands.

- **`0,7,1`** only sets three entries; the **fourth** band is padded with **`7`**. So the layout is: name (16 px) → blank → **status** → **blank again**. The slot/type line is **not** on the physical bottom row.
- **`0d,7,1`** uses four explicit bands: double-height name (**32 px**) → blank (**16 px**) → status (**16 px**) on the **lowest** pixels — roughly **top 3/4** for the name block + spacer, **bottom 1/4** for status.

## What stock firmware does *not* do

FlashFloppy sends the **entire** current image basename to **content row 0** only (`lcd_write` → `text[0]` in the display driver). There is **no** option to split the filename at the **last underscore** into two **independent** name lines (e.g. `0002_ATW_Colorado_` on one row and `alogdig` on the next). Achieving that would require a **custom FlashFloppy build** that splits `cfg.slot.name` when drawing.

**Indexed mode** at USB root does not give you a “folder on row 3, short name on row 0” layout from the flat `000N_*` rack; wiki default **`3,0d,1`** is aimed at **native** navigation where row **3** is meaningful.

## Rack default: `display-order = 0d,7,1` (128×64)

For the SamplerZone **Extended** 128×64 OLED we use **`0d,7,1`**:

1. **Top 32 px** — double-height **filename** (full string; may scroll horizontally if long).
2. **Next 16 px** — blank spacer.
3. **Bottom 16 px** — **status** (`NNN/total HFE` / `IMG`, etc.).

Alternatives:

- **`0d,1`** — double-height name + status **immediately** under it; only **48 px** of content, **16 px** unused at the bottom (older rack preset).
- **`3,0d,1`** — FlashFloppy wiki default for 128×64: subfolder line + double-height name + status (row **3** is often empty in indexed root).
