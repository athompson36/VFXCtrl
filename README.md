# VFX-CTRL

A macOS-first editor, librarian, and future hardware control-surface companion for the Ensoniq VFX-SD.

## Status

This starter is intentionally split into two tracks:

1. **Verified today**
   - macOS app scaffold in SwiftUI
   - CoreMIDI transport skeleton
   - SysEx logging/sniffing tools
   - library data model
   - UI page model designed to map cleanly to future hardware
   - disk-image parser plan and placeholders

2. **Needs verification from the original Ensoniq MIDI spec / captures**
   - exact SysEx byte layouts beyond the message categories already verified
   - exact per-parameter addresses / offsets
   - exact bank/program dump framing and checksums
   - exact sequencer control semantics over MIDI SysEx

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
