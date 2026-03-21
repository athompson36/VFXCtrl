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

### Discrete parameters (menus)

`ParameterEnumLabels` supplies option strings for enum-like parameters (e.g. `filter.type` → “LP 2-pole” / “LP 3-pole”). **`ParameterDefinition.label`** is always the *control name* (e.g. “Filter #1 Type”), never a single option.

`LabeledParameterCell` for enums: **one green line** — the map `label` (e.g. “Wave Class”) — then a **menu picker** that shows the current option (no second green value line, no extra acronym row). Continuous params still use `VirtualEncoder` (value in the dial + short label).

**Audited (map vs enum options):** Filter types, wave class, MIDI enums, LFO waveshape, env modes, FX type list, mod sources/destinations, and system/program pitch tables align with `PARAMETER_MAP.md` / MIDI spec v2.00 where marked verified. **`sys.midiStatus`** options are Local / MIDI / Both (program-change routing), not generic Off/On.

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
