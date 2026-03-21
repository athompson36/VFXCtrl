# VFX-SD Modulation Matrix

## Overview

The VFX-SD provides **spatial matrix modulation** with up to **15 modulation sources** and **10 destinations** per voice. The hardware supports **only 2 simultaneous modulation routes** (two slots): Slot 1 = Source 1 → Destination 1 (Depth 1), Slot 2 = Source 2 → Destination 2 (Depth 2). The Mod Mixer/Shaper can blend two sources into one of these slot inputs. Source and destination lists are documented from the Ensoniq VFX/VFX-SD manuals, polynominal.com, bobbyblues.recup.ch, and Sound Quest Midi Quest. See `.cursor/rules/vfx-sd-capabilities.mdc` for the companion app rule.

## Modulation Sources (15)

| Index | Name            | Notes |
|------:|-----------------|-------|
| 0     | Pressure        | Aftertouch |
| 1     | Velocity        | Note velocity |
| 2     | Mod Wheel       | CC#1 |
| 3     | Pitch Wheel     | Pitch bend |
| 4     | Pedal           | Expression pedal |
| 5     | Envelope 1      | Pitch envelope |
| 6     | Envelope 2      | Filter envelope |
| 7     | LFO             | Single LFO, 7 shapes |
| 8     | Keyboard        | Key position / tracking |
| 9     | Timbre          | Data slider (preset-level) |
| 10    | Random          | Noise |
| 11    | Mixer/Shaper    | Two modulators blended; 16 shaper curves |
| 12    | Ext MIDI        | External MIDI controller |
| 13    | Wheel+Pressure  | Mod wheel and pressure combined |
| 14    | Vel+Pressure    | Velocity and pressure combined |

*Exact order and naming may vary by firmware; SysEx indices TBD until capture.*

## Modulation Destinations (10)

| Index | Name             | Notes |
|------:|------------------|-------|
| 0     | Wave Start       | Transwave / wave start point |
| 1     | Pitch            | Oscillator pitch |
| 2     | Filter 1 Cutoff  | First filter cutoff |
| 3     | Filter 2 Cutoff  | Second filter cutoff |
| 4     | LFO Rate         | LFO speed |
| 5     | LFO Level        | LFO depth/amount |
| 6     | Output Volume    | Amp/level |
| 7     | Pan              | Stereo pan |
| 8     | Transwave Index  | Transwave read position |
| 9     | FX Mix           | Effects wet/dry |

## Mod Mixer/Shaper

The VFX-SD also has a **Mod Mixer/Shaper**: two modulators can be blended into a single modulation input, with 16 Mod Shaper curves (linear, convex, concave, etc.). This is not yet represented in the matrix UI; future work can add a dedicated mixer/shaper section.

## UI Mapping (2-slot limit)

- **Canonical state keys** (per `.cursor/rules/vfx-sd-capabilities.mdc`): `mod.src1`, `mod.dest1`, `mod.depth1`, `mod.src2`, `mod.dest2`, `mod.depth2`, `mod.pedal`, `mod.pressure`. These are the only routing parameters the hardware supports; the companion app must use these as the single source of truth until SysEx is verified.
- **Mod page**: Two routing slots only. Each slot: one source (picker from the 15 sources), one destination (picker from the 10 destinations), one depth (0–127). Global **Pedal** and **Pressure** (0–127) remain separate.
- Any design-only or “full matrix” view must map to these 2 slots or be clearly marked as beyond hardware capability.

## Status

- **verified**: Source/destination lists from multiple public references; **2 simultaneous routes** per voice (manual / UI_PAGES / capability rule).
- **inferred**: Depth range 0–127 per slot; bipolar not confirmed.
- **unknown**: SysEx byte layout for the two slots.
