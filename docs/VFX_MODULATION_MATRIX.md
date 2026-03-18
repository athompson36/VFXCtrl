# VFX-SD Modulation Matrix

## Overview

The VFX-SD provides **spatial matrix modulation** with up to **15 modulation sources** that can be routed to **10 destinations** per voice. Sources and destinations are documented from the Ensoniq VFX/VFX-SD manuals, polynominal.com, bobbyblues.recup.ch, and Sound Quest Midi Quest.

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

## UI Mapping

- **Mod page**: Full matrix grid — rows = sources, columns = destinations. Each cell = depth (0–127). Global **Pedal** and **Pressure** amounts (existing `mod.pedal`, `mod.pressure`) can sit above or below the matrix.
- **State keys**: `mod.matrix.<src>.<dest>` for depth; `mod.pedal`, `mod.pressure` unchanged. Legacy slot keys (`mod.src1`, `mod.dest1`, `mod.depth1`, etc.) remain for compatibility; matrix view is the primary editor.

## Status

- **verified**: Source/destination lists from multiple public references.
- **inferred**: Matrix depth range 0–127; bipolar not confirmed.
- **unknown**: SysEx byte layout for matrix; number of simultaneous routes per voice (full 15×10 vs. limited slots).
