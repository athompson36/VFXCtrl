# VFX-CTRL Product Spec

## Product
VFX-CTRL is a macOS editor/librarian/programmer for the Ensoniq VFX-SD, designed from day one to become the software prototype for a dedicated external hardware programmer.

## Primary goals

- Edit VFX-SD sound parameters faster than the onboard menu structure.
- Organize programs, presets, banks, and live sets.
- Establish a hardware-friendly page layout.
- Add sequencer transport, tap tempo, and FX control pages if those controls can be verified over MIDI/SysEx.
- Export curated sets for Gotek-based workflows.

## Non-goals for v1

- Claiming a complete SysEx map before verification.
- Writing arbitrary floppy images directly without validation.
- Replacing the VFX-SD internal waveform ROM.

## App modes

### 1. Live Editor
Connected directly over MIDI. Fetch current patch, edit, compare, store snapshots.

### 2. Librarian
Tag, search, dedupe, compare, and organize programs/banks from SysEx files.

### 3. Set Builder
Curate collections for studio/live use and later export them into bank/disk workflows.

## UX principles

- Instrument-like, not spreadsheet-like.
- Eight controls per page.
- Strong labels and value feedback.
- A/B compare at all times.
- Hardware mirroring from the start.

## Initial page model

1. Wave
2. Motion
3. Filter
4. Amp
5. Mod
6. Performance
7. Sequencer
8. FX
9. Macro

## Future hardware mirror

- 8 encoders minimum per page
- 1 mini OLED per encoder
- 1 larger main OLED
- navigation encoder
- page buttons
- transport keys
- tap tempo key
- shift / compare / store buttons

## Deliverables in this starter

- SwiftUI starter app
- CoreMIDI manager
- SysEx logger and inspector
- parameter map template
- reverse-engineering workflow
- disk-image parser plan
- hardware concept brief
