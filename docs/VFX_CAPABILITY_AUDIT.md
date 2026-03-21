# VFX-SD Companion App: Capability Audit

**UI model (2025–2026):** Editor tabs (**Wave**, **Motion**, **Filter**, etc.) render **`ParameterDefinitionsPage`**, which pulls every `ParameterDefinition` for that tab from **`ParameterMap.swift`** via **`ParameterCatalog`**. Controls are grouped by **VFX-SD SysEx page** (`sysexPage`), shown in a **4-column** `LazyVGrid`. Each cell is **`LabeledParameterCell`**: **menu picker** when **`ParameterEnumLabels`** supplies a name list for that key/range, otherwise **`VirtualEncoder`** with the definition’s **min/max** (not a global 0…127).

**Sources of truth:** `src/patch/ParameterMap.swift`, `docs/PARAMETER_MAP.md`, MIDI spec v2.00.

---

## 1. Wave tab (map-driven)

| Group | Keys (summary) | Map range / notes |
|-------|----------------|-------------------|
| Wave page 7 | `wave.select` | 0–147 (VFX-SD II wave index; UI labels `Wave #n`) |
| | `wave.class` | 0–12 (enum names) |
| | `wave.delay` | 0–251 (251 = key up) |
| | `wave.start` | 0–127 |
| | `wave.velStart` | 0–255 (signed semantics per spec note) |
| | `wave.direction` | 0–1 |
| Pitch page 11 | `pitch.octave`, `semitone`, `fine` | 0–255 (logical ranges in spec notes, not all 0–127) |
| | `pitch.table` | 0–2 |
| Voice page 38 | `voice.status0` … `voice.status5` | 0–2 each |
| Legacy / UI-only (998) | `wave.coarse`, `wave.fine`, `wave.octave`, `wave.level`, `wave.velocity`, `wave.keytrack`, `wave.pan`, `voice.status` | Various; marked unknown/inferred where applicable |

**Result:** The old “8 × 0–127 wave knobs” description is **obsolete**. Ranges follow **`ParameterMap`** per key. Optional: tighten display scaling for pitch fields once encoding is fully verified.

---

## 2. Motion tab (map-driven)

| Group | Keys (summary) | Map range / notes |
|-------|----------------|-------------------|
| Pitch mod page 12 | `pitch.modSrc` | 0–15 (mod source enum) |
| | `pitch.modAmt` | 0–255 |
| | `pitch.glideMode` | 0–4 (enum) |
| | `pitch.env1Mod`, `pitch.lfoMod` | 0–255 |
| LFO pages 18–19 | `lfo.rate`, `lfo.delay` | 0–99 |
| | `lfo.depth` | 0–127 |
| | `lfo.rateModSrc`, `lfo.depthModSrc` | 0–15 |
| | `lfo.rateModAmt` | 0–255 |
| | `lfo.waveshape` | 0–6 (enum) |
| | `lfo.restart` | 0–1 |
| | `lfo.noiseRate` | 0–127 |
| Legacy / aliases (998) | `motion.*`, `lfo1.rate` / `lfo1.depth` (aliases), `lfo2.rate`, `modwheel.depth`, `aftertouch.depth` | See map status flags |

**Hardware note:** VFX-SD is **one LFO per voice** in normal programming; the UI exposes the **canonical** `lfo.*` block from the spec. **`lfo1.*`** entries are **aliases** for macros/compatibility; **`lfo2.rate`** remains legacy/unknown for direct hardware mapping.

**Result:** Not “8 motion knobs at 0–127”. Enum-like parameters use pickers where labels exist; continuous params use encoders with correct spans.

---

## 3. Filter tab (map-driven)

| Group | Keys (summary) | Map range / notes |
|-------|----------------|-------------------|
| Filter #1 page 13 | `filter.type`, `cutoff`, `keytrack`, `modSrc`, `env`, `modAmt` | Mix of 0–1, 0–127, 0–255, 0–15 |
| Filter #2 page 14 | `filter2.type` | 0–3 |
| | `filter2.cutoff`, `keytrack`, `modSrc`, `modAmt`, `env` | Same pattern as F1 |
| Legacy (998) | `filter.resonance`, `velocity`, `mode`, `source`, `alt` | 0–127; no direct live SysEx table |

**Result:** Old “8 × filter at 0–127” grid is obsolete; verified rows match **pages 13–14** in the map.

---

## 4. Amp tab

Envelope and output parameters are spread across **pages 15–17, 20–28** (`output.*`, `env1/2/3.*`, amp aliases on 998). **`ParameterDefinitionsPage`** lists them under **Amp** with per-key ranges from the map (e.g. env times 0–99, releases 0–255, levels 0–127).

**Result:** Aligns with map; no fixed “8 amp sliders” assumption.

---

## 5. Mod (routing + global amounts)

| Item | Current implementation | VFX-SD rule | Audit result |
|------|------------------------|-------------|--------------|
| Routing | **2 slots** (`ModTwoSlotView`): `mod.src1`, `mod.dest1`, `mod.depth1`, `mod.src2`, `mod.dest2`, `mod.depth2`; sources 0–15, dest 0–9, scaler/shape 0–15. | **2 slots** per spec mixer page. | **OK.** |
| Pedal / pressure (UI) | `mod.pedal`, `mod.pressure` | Patch/UI placeholders | OK as unknown until live table |

**Result:** Unchanged from prior audit; matrix doc should stay aligned with **2 slots**.

---

## 6. Performance tab

`perf.*` keys (split, zones, velocity, transpose, etc.) at **0–127** where defined; section **Performance (patch / UI only)** in `ParameterCatalog`. Some use **enum-style labels** (e.g. MIDI note names) when `ParameterEnumLabels` provides them.

**Result:** OK; optional hard limits (e.g. 3-layer performance) remain documentation-only.

---

## 7. Sequencer (sub-pages)

| Parameter / key   | UI range / type      | Doc range (VFX_SEQUENCER_SYSEX) | Audit note |
|------------------|----------------------|----------------------------------|------------|
| seq.tempo        | 1–300 (TextField)    | 1–300                            | OK. |
| seq.clockSource  | 0–127 (placeholder)  | Internal/MIDI                    | Still placeholder range in map. |
| seq.song         | 1–60 (Picker)        | 1–60                             | `loadPatch` normalizes invalid defaults to 1 (see `EditorState`). |
| seq.sequence     | 1–60 (Picker)        | 1–60                             | Same. |
| seq.track        | 1–24 (Picker)        | 1–24                             | Same. |
| seq.quant        | 0–6 (Picker)         | preset list                      | OK. |
| Other seq.*      | See `ParameterMap`   |                                  | Many still unknown placeholders. |

**Result:** Sequencer doc ranges OK where verified; several keys remain **unknown** in the map.

---

## 8. FX tab (map-driven)

| Group | Keys | Map notes |
|-------|------|-----------|
| Pages 29–31 | `fx.type` (0–21), `fx.reverbMix` (0–99), `fx.fx1Mix`, `fx.fx2Mix` (0–127) | Verified block |
| Legacy (998) | `fx.mix`, `time`, `feedback`, `depth`, `rate`, `tone`, `alt` | 0–127; not in live SysEx table |

**Result:** Old “fx.type 0–127 / 15 effects” line is wrong: **`fx.type` is 0–21 (22 types)** per map; UI uses enum labels.

---

## 9. Macro (8 controls)

| Key             | UI range | Audit note |
|-----------------|----------|------------|
| macro.* (8)     | 0–127    | OK. Maps via `MacroEngine` to real params. |

**Result:** Consistent.

---

## Cross-cutting

| Item | Audit note |
|------|------------|
| **Parameter UI** | **`LabeledParameterCell`** + **`ParameterEnumLabels`** for discrete params; **`VirtualEncoder`** otherwise — each uses **`definition.minValue`…`maxValue`**. |
| **PageGrid / fixed 0…127** | **No longer the primary model** for Wave/Motion/Filter/Amp/FX tabs; audit rows above replace old PageGrid assumptions. |
| **EditorState `loadPatch`** | Normalizes sequencer keys and other defaults (e.g. `seq.song` 1…60). |
| **Docs** | `VFX_MODULATION_MATRIX.md` should state **2 slots** only, matching Mod UI. |

---

## Summary

| Page    | Status | Notes |
|---------|--------|--------|
| Wave    | **OK** | Map-driven; wave index 0–147; legacy keys isolated on sysexPage 998. |
| Motion  | **OK** | Canonical `lfo.*` + pitch mod page; aliases/legacy on 998. |
| Filter  | **OK** | Two filters with per-spec ranges. |
| Amp     | **OK** | Multi-page env + output in one tab. |
| **Mod** | **OK** | 2-slot UI. |
| Perf    | **OK** | Patch/UI performance keys. |
| Seq     | **OK** | Mix of verified and placeholder keys. |
| FX      | **OK** | 22 effect types + legacy row. |
| Macro   | **OK** | — |

*Audit refreshed for `ParameterDefinitionsPage` + `ParameterMap` (Phase 6.10).*
