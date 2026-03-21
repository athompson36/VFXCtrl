# VFX-CTRL

A macOS-first editor, librarian, and future hardware control-surface companion for the Ensoniq VFX-SD.

## Status

The app is past “scaffold”: CoreMIDI I/O, program dump parse/serialize, a **map-driven** editor UI, librarian (import/export, live sets, Gotek-oriented naming), and **live** parameter SysEx when enabled. What remains for a confident **1.0** is mostly **hardware proof** (captures in `sysex/`, checksum, request/send flows), **coverage polish** (map vs `LiveSysExBuilder`), and **macOS release engineering** — see [`docs/ROADMAP.md`](docs/ROADMAP.md), [`TODO.md`](TODO.md) (Phase 7), [`docs/PRODUCTION_CHECKLIST.md`](docs/PRODUCTION_CHECKLIST.md), [`docs/RELEASE.md`](docs/RELEASE.md), [`CHANGELOG.md`](CHANGELOG.md), and [`docs/SUPPORT.md`](docs/SUPPORT.md).

**Still needs verification from the Ensoniq MIDI spec / your synth**
   - per-parameter behavior on hardware (even when addresses come from the spec)
   - bank/program dump checksums
   - sequencer / FX scope the VFX-SD actually accepts over SysEx

## What this project is for

- fast patch editing from macOS
- librarian and live-set organization
- proving a page-based semi-knob-per-function UI before hardware
- future hardware controller with:
  - one small OLED per knob
  - one main OLED
  - navigation encoder + buttons
  - transport + tap tempo
  - FX control
  - sequencer page set

## Build targets

- macOS 14+
- Swift 5.10+
- Xcode 16+

**Build:** Open the project folder in Xcode (File → Open → select the `vfx-ctrl` folder containing `Package.swift`), or run `swift build` from the project root. Run the **VFXCtrl** target to launch the app.

## Recommended first test workflow

1. Connect the VFX-SD over a reliable MIDI interface.
2. Verify the synth has SysEx receive enabled.
3. Capture a **Current Program** dump from the front panel.
4. Save the raw SysEx in `sysex/`.
5. Use `tools/vfx_sysex_inspector.py` to inspect and diff dumps.
6. Map one parameter at a time using the reverse-engineering guide in `docs/PARAMETER_RESEARCH_WORKFLOW.md`.

## Important caution

This repository does **not** pretend the parameter address map is complete. The docs mark every field as one of:

- `verified`
- `inferred`
- `unknown`

That keeps the project safe and honest while still letting you move quickly.

## Gotek / FlashFloppy and HFE

- **FlashFloppy** (Gotek firmware) commonly uses **HFE** (or indexed raw images) for floppy emulation. Constraints vary by image type and jumper settings; keep **folder depth shallow** and filenames short on the USB stick (the app’s **Export** options help with that — see `docs/VFX_SD_Context.md` and `docs/GOTEK_COMPATIBILITY_AUDIT.md`).
- **VFX-CTRL does not write HFE or raw disk images** in-app. There is **no binary HFE writer** until **Phase 3** of [`docs/DISK_IMAGE_PLAN.md`](docs/DISK_IMAGE_PLAN.md) and a **verified** Ensoniq/VFX-SD sector layout for your sources.
- **Phase 2** (read-only image metadata in code) is also unimplemented; until then use the **manual** `.img` → external tool / MIDI capture → **`.syx`** path described in `DISK_IMAGE_PLAN.md`.
- For librarian workflows today: prefer **loose `.syx`**, **Live Sets**, optional **`bank.json`** on export, and duplicate detection on import.
