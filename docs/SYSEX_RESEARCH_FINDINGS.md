# SysEx Research Findings

## Status: RESOLVED

The official VFX-SD MIDI Implementation Specification v2.00 was found **in this repo** at `docs/Ensoniq VFX-SD MIDI Implementation Specification v2.00.md`. It contains the complete SysEx protocol, all parameter page/slot definitions, and the exact message formats. All previous guesses from Fizmo/MR documentation have been superseded.

## Key Findings

| Item | Value | Source |
|------|-------|--------|
| **Manufacturer** | `0x0F` (Ensoniq) | Spec section 2.1 |
| **Family ID** | `0x05` (VFX) | Spec section 2.1 |
| **Model ID** | `0x00` (VFX-SD) | Spec section 2.1 |
| **Parameter Change** | Command Type `01`, Message Type `00` | Spec section 3.1.2 |
| **Addressing** | Voice [0..5], Page [0..31], Slot [0..5] | Spec section 3.1.2 |
| **Data encoding** | All data nibblized (8-bit -> two 4-bit bytes) | Spec section 2.3 |
| **Master Volume** | MIDI CC 7 (NOT a SysEx parameter) | Spec Appendix B |
| **Virtual Buttons** | Command Type `00`, all panel buttons mapped | Spec section 3.1.1 |
| **Single Program Dump** | 1067 bytes, Message Type `02` | Spec section 3.3.1 |
| **All Programs Dump** | 63607 bytes, Message Type `03` | Spec section 3.3.2 |

## What Was Wrong Before

Our previous `LiveSysExBuilder` used a format guessed from Ensoniq Fizmo/MR documentation:
- `F0 0F 05 01 00 05 [addrHi] [addrLo] [value] F7` — **WRONG**

The correct format from the official spec:
- `F0 0F 05 00 [ch] 00 {nibblized: 01 voice page slot valHi valLo} F7` — **CORRECT**

Key differences:
1. Command Type is `01` (not `05`)
2. Parameters are addressed by page/slot/voice (not linear address)
3. All data bytes are nibblized (doubled in size)
4. Message Type `00` goes in the header
5. Master Volume has no SysEx parameter — use CC 7

## Complete Parameter Map

All parameters from spec section 5 are now implemented in:
- `src/midi/LiveSysExBuilder.swift` — address table and message builder
- `src/patch/ParameterMap.swift` — UI-facing parameter definitions
- `docs/VFX_SYSEX_SPEC.md` — complete protocol reference

## Sources Checked (for historical reference)

- **Official spec (in repo)** — Complete, authoritative, RESOLVED
- **Gearspace v2.10 thread** — Sequencer dumps only; not relevant for parameter change
- **Fizmo/MR docs** — Different protocol (command 0x05 for parameter change); NOT applicable to VFX-SD
- **sysexdb.com** — No byte layouts
- **ManualsLib (VFX manual p.144)** — Same content as the spec we have
- **Bobby Blues / ATW collection** — Patch sources, not protocol info
