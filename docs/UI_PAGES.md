# UI Pages

Editor tabs map to **`EditorPage`** in `EditorState.swift`. Most synthesis tabs render **`ParameterDefinitionsPage`**, which lists every `ParameterDefinition` in `ParameterMap.swift` for that tab, **grouped by VFX-SD hardware SysEx page** (see `ParameterCatalog.sectionTitle`).

## Data-driven tabs (full parameter map)

| Tab | Source | Notes |
|-----|--------|--------|
| **Wave** | `ParameterDefinitionsPage(.wave)` | Wave 7–10, pitch 11, program pitch table, voice status 38, legacy wave keys |
| **Motion** | `ParameterDefinitionsPage(.motion)` | Pitch mod 12, LFO 18–19, legacy motion/LFO aliases |
| **Filter** | `ParameterDefinitionsPage(.filter)` | Filters 13–14, legacy filter keys |
| **Amp** | `ParameterDefinitionsPage(.amp)` | Output 15–17, Env1–3 (20–28), amp.* aliases |
| **Performance** | `ParameterDefinitionsPage(.performance)` | Program control page 5, pan/mod page 16, perf.* patch fields |
| **FX** | `ParameterDefinitionsPage(.fx)` | Routing dest 16, effects 29, legacy fx.* |
| **Macro** | `ParameterDefinitionsPage(.macro)` | Eight macro knobs (patch-only routing via `MacroEngine`) |

Ranges and short labels come from the map; tooltips show full label + note.

## Custom layouts

| Tab | UI |
|-----|-----|
| **System** | Custom pickers/sliders for master, MIDI, pitch table + scrollable grid of **remaining** system parameters (`excludeKeys` in `SystemPage`) |
| **Mod** | `ModTwoSlotView` — two routes with source/dest menus; scaler/shape depths **0…15** (hardware) |
| **Sequencer** | Segmented sub-pages (`SeqTransportView`, tempo/clock, song/track, quant/rec, dump/load) |

## Live MIDI

Keys in `LiveSysExBuilder.supportedLiveKeys` send when Live is enabled. Legacy / unmapped keys still edit the patch model only.

## Historical

Earlier versions used fixed 8-knob `PageGrid` layouts per tab; those encoders are superseded by the map-driven UI above (except Mod + System + Sequencer).
