# Parameter Catalog and Address Map

Human-readable mirror of **`src/patch/ParameterMap.swift`** (`initialParameterMap`). When this file and Swift disagree, **trust Swift** for app behavior and update this doc.

Derived from the **Ensoniq VFX-SD MIDI Implementation Specification v2.00** (section 5), aligned with `LiveSysExBuilder` for live edits.

## Legend

- **status** (in Swift: `VerificationStatus`): `verified` | `inferred` | `unknown`
- **UI range** — values stored in patches / editor: `minValue`…`maxValue` in `ParameterDefinition`.
- **Logical range** — meaning on hardware per spec (e.g. signed pitch); may use unsigned byte encoding in SysEx (see spec).

## Parameter Change Protocol (verified)

- **Message Type:** `00` (Command Message)
- **Command Type:** `01` (Parameter Change)
- **Addressing:** Voice [0..5], Page [0..31], Slot [0..5], Value [Hi+Lo bytes]
- **Encoding:** All data bytes nibblized (see spec section 2.3)
- **Per spec:** When multiple slots are listed, use the **highest** slot number.

## Pseudo-pages (not SysEx page indices)

| sysexPage | Meaning |
|-----------|---------|
| 900 | UI grouping only; **sys.masterVol** sent as **MIDI CC 7**, not Parameter Change SysEx. |
| 997 | Sequencer UI placeholders (not wired to live SysEx table yet). |
| 998 | Legacy / patch-only keys (no row in `LiveSysExBuilder` for many). |
| 999 | Performance / macro patch workflow keys. |

## System / master (pages 0–2 + CC)

| Key | Page | Slot | UI range | Status | Note |
|-----|------|------|----------|--------|------|
| sys.masterVol | 900 | 0 | 0–127 | verified | MIDI CC 7 only |
| sys.tune | 0 | 0 | 0–255 | verified | Logical −128…+127 as unsigned byte (see spec) |
| sys.touch | 0 | 1 | 0–4 | verified | |
| sys.bendRange | 0 | 2 | 0–12 | verified | Semitones |
| sys.fs1 | 0 | 4 | 0–3 | verified | |
| sys.fs2 | 0 | 5 | 0–1 | verified | |
| sys.sliderMode | 1 | 0 | 0–1 | verified | |
| sys.cvPedal | 1 | 1 | 0–1 | verified | |
| sys.pitchTable | 1 | 3 | 0–1 | verified | CUSTOM,NORMAL |
| sys.maxVelocity | 1 | 4 | 0–127 | verified | |
| sys.voiceMuting | 2 | 2 | 0–1 | verified | |
| sys.diskType | 2 | 4 | 0–127 | unknown | UI / patch |
| sys.xposEnable | 2 | 5 | 0–1 | unknown | Verify in spec |

## MIDI control (pages 3–4)

| Key | Page | Slot | UI range | Status | Note |
|-----|------|------|----------|--------|------|
| sys.midiBaseCh | 3 | 0 | 0–15 | verified | 0-based channel |
| sys.midiLoop | 3 | 1 | 0–1 | verified | |
| sys.midiSendCh | 3 | 2 | 0–1 | verified | BASE,TRACK |
| sys.midiInMode | 3 | 3 | 0–4 | verified | OMNI…MONO B |
| sys.midiTranspose | 3 | 4 | 0–2 | verified | SEND,RECV,BOTH |
| sys.midiExtCtrl | 3 | 5 | 0–95 | verified | External CC # |
| sys.localControl | 4 | 0 | 0–1 | verified | |
| sys.songSelect | 4 | 1 | 0–1 | verified | |
| sys.sendStartStop | 4 | 2 | 0–1 | verified | |
| sys.sysexRx | 4 | 3 | 0–1 | verified | |
| sys.midiStatus | 4 | 5 | 0–2 | verified | Local/MIDI/Both style mapping in UI |

## Program control (page 5)

| Key | Page | Slot | UI range | Status | Note |
|-----|------|------|----------|--------|------|
| prog.pitchTable | 5 | 0 | 0–1 | verified | |
| prog.bendRange | 5 | 1 | 0–13 | verified | 13 = global |
| prog.delayMult | 5 | 2 | 0–3 | verified | ×1,×2,×4,×8 |
| prog.restrike | 5 | 4 | 0–99 | verified | |
| prog.glide | 5 | 5 | 0–99 | verified | |

## Performance (patch / editor — sysexPage 999)

| Key | Slot | UI range | Status |
|-----|------|----------|--------|
| perf.split … perf.transpose | 0–7 | 0–127 (each) | unknown |

## Mod mixer (page 6 + UI)

| Key | Page | Slot | UI range | Status | Note |
|-----|------|------|----------|--------|------|
| mod.src1 | 6 | 1 | 0–15 | verified | |
| mod.src2 | 6 | 2 | 0–15 | verified | |
| mod.depth1 | 6 | 4 | 0–15 | verified | Mixer scaler |
| mod.depth2 | 6 | 5 | 0–15 | verified | Mixer shape |
| mod.dest1 | 998 | 0 | 0–9 | inferred | Not in live SysEx table |
| mod.dest2 | 998 | 1 | 0–9 | inferred | |
| mod.pedal | 998 | 2 | 0–127 | unknown | |
| mod.pressure | 998 | 3 | 0–127 | unknown | |

## Voice parameters (repeat per voice 0–5)

### Wave (page 7)

| Key | Slot | UI range | Logical (spec) | Status |
|-----|------|----------|----------------|--------|
| wave.select | 0 | 0–147 | — | verified |
| wave.class | 1 | 0–12 | — | verified |
| wave.delay | 2 | 0–251 | 251=key up | verified |
| wave.start | 3 | 0–127 | — | verified |
| wave.velStart | 4 | 0–255 | −127…+127 | verified |
| wave.direction | 5 | 0–1 | — | verified |

### Pitch (page 11)

| Key | Slot | UI range | Logical (spec) | Status |
|-----|------|----------|----------------|--------|
| pitch.octave | 0 | 0–255 | −4…+4 | verified |
| pitch.semitone | 1 | 0–255 | −12…+12 | verified |
| pitch.fine | 2 | 0–255 | −127…+127 | verified |
| pitch.table | 4 | 0–2 | — | verified |

### Pitch mod (page 12)

| Key | Slot | UI range | Logical (spec) | Status |
|-----|------|----------|----------------|--------|
| pitch.modSrc | 1 | 0–15 | — | verified |
| pitch.modAmt | 2 | 0–255 | −99…+99 | verified |
| pitch.glideMode | 3 | 0–4 | — | verified |
| pitch.env1Mod | 4 | 0–255 | −127…+127 | verified |
| pitch.lfoMod | 5 | 0–255 | −127…+127 | verified |

### Filter #1 (page 13)

| Key | Slot | UI range | Logical | Status |
|-----|------|----------|---------|--------|
| filter.type | 0 | 0–1 | — | verified |
| filter.cutoff | 1 | 0–127 | — | verified |
| filter.keytrack | 2 | 0–255 | −127…+127 | verified |
| filter.modSrc | 3 | 0–15 | — | verified |
| filter.env | 4 | 0–255 | −127…+127 | verified |
| filter.modAmt | 5 | 0–255 | −127…+127 | verified |

### Filter #2 (page 14)

| Key | Slot | UI range | Logical | Status |
|-----|------|----------|---------|--------|
| filter2.type | 0 | 0–3 | — | verified |
| filter2.cutoff | 1 | 0–127 | — | verified |
| filter2.keytrack | 2 | 0–255 | −127…+127 | verified |
| filter2.modSrc | 3 | 0–15 | — | verified |
| filter2.modAmt | 4 | 0–255 | −127…+127 | verified |
| filter2.env | 5 | 0–255 | −127…+127 | verified |

### Output / routing (pages 15–17)

| Key | Page | Slot | UI range | Logical | Status |
|-----|------|------|----------|---------|--------|
| output.volume | 15 | 0 | 0–127 | — | verified |
| output.volModSrc | 15 | 1 | 0–15 | — | verified |
| output.volModAmt | 15 | 2 | 0–255 | −127…+127 | verified |
| output.keyScale | 15 | 3 | 0–255 | −128…+127 | verified |
| output.dest | 16 | 1 | 0–3 | — | verified |
| output.pan | 16 | 2 | 0–127 | — | verified |
| output.panModSrc | 16 | 3 | 0–15 | — | verified |
| output.panModAmt | 16 | 4 | 0–255 | −127…+127 | verified |
| output.preGain | 16 | 5 | 0–1 | — | verified |
| output.priority | 17 | 2 | 0–2 | — | verified |
| output.velThresh | 17 | 4 | 0–255 | −127…+127 | verified |

### LFO (pages 18–19)

| Key | Page | Slot | UI range | Status |
|-----|------|------|----------|--------|
| lfo.rate | 18 | 0 | 0–99 | verified |
| lfo.rateModSrc | 18 | 1 | 0–15 | verified |
| lfo.rateModAmt | 18 | 2 | 0–255 | verified |
| lfo.depth | 18 | 3 | 0–127 | verified |
| lfo.depthModSrc | 18 | 4 | 0–15 | verified |
| lfo.delay | 18 | 5 | 0–99 | verified |
| lfo.waveshape | 19 | 1 | 0–6 | verified |
| lfo.restart | 19 | 2 | 0–1 | verified |
| lfo.noiseRate | 19 | 5 | 0–127 | verified |

### Env1 (pages 20–22) — amplitude

| Key | Page | Slot | UI range | Logical (spec) | Status |
|-----|------|------|----------|----------------|--------|
| env1.initLevel … env1.susLevel | 20 | 1–5 | 0–127 each | — | verified |
| env1.attack … env1.decay3 | 21 | 1–4 | 0–99 each | — | verified |
| env1.release | 21 | 5 | 0–255 | −100…+99 | verified |
| env1.kbdTrack | 22 | 0 | 0–255 | (see spec) | verified |
| env1.velCurve | 22 | 2 | 0–9 | — | verified |
| env1.mode | 22 | 3 | 0–2 | — | verified |
| env1.lvlVelSens, env1.atkVelSens | 22 | 4–5 | 0–127 | — | verified |

### Env2 (23–25) and Env3 (26–28)

Same slot layout as env1 on pages 23–25 and 26–28 respectively (`env2.*`, `env3.*`). **env2.release** / **env3.release**: UI 0–255 (see `ParameterMap.swift` notes).

### Effects (page 29 primary)

| Key | Slot | UI range | Status | Note |
|-----|------|----------|--------|------|
| fx.type | 1 | 0–21 | verified | 22 types |
| fx.reverbMix | 2 | 0–99 | verified | FX2 mix/decay; type-dependent |
| fx.fx1Mix | 4 | 0–127 | verified | |
| fx.fx2Mix | 5 | 0–127 | verified | |

Pages 30–31: additional effect parameters are type-dependent (spec §5).

### Voice Select (Page 38)

| Key | Label | Page | Slot | Range | Status |
|-----|-------|------|------|-------|--------|
| voice.status[0-5] | Voice Status | 38 | 0–5 | 0–2 | verified |

Values: 0=OFF, 1=ON, 2=SOLO

## Sequencer (sysexPage 997 — UI placeholders)

| Key | Slot | UI range | Status |
|-----|------|----------|--------|
| seq.tempo | 0 | 1–300 | unknown |
| seq.song | 1 | 1–60 | unknown |
| seq.sequence | 2 | 1–60 | unknown |
| seq.track | 3 | 1–24 | unknown |
| seq.loop … seq.punchOut | 4–11 | mostly 0–127 | unknown |

## Macro (sysexPage 999)

| Keys | Slots | UI range | Status | Note |
|------|-------|----------|--------|------|
| macro.brightness … macro.animate | 0–7 | 0–127 each | unknown | Editor-only; `MacroEngine` maps to real parameters |

## Legacy keys (sysexPage 998)

Filter, wave, motion, fx, amp, and mod UI-only rows live on **998** — see `ParameterMap.swift` for keys (`filter.resonance`, `lfo1.rate`, `fx.mix`, etc.). Treat as **not** in `LiveSysExBuilder` unless noted.

## Maintenance

When adding or changing a parameter:

1. Update **`ParameterMap.swift`** (`initialParameterMap`).
2. Update **`LiveSysExBuilder`** if the parameter should participate in live SysEx.
3. Update **`ParameterEnumLabels.swift`** if the control should use a text picker.
4. Refresh **this file** and, if needed, **`docs/VFX_CAPABILITY_AUDIT.md`**.

## Mod Sources (0–15)

From the spec (used for filter mod, pitch mod, LFO mod, pan mod, volume mod, etc.):

| Index | Source |
|-------|--------|
| 0 | OFF |
| 1 | LFO |
| 2 | Noise |
| 3 | Env1 |
| 4 | Env2 |
| 5 | Env3 |
| 6 | Velocity |
| 7 | Vel × Pressure |
| 8 | Keyboard |
| 9 | Pressure |
| 10 | Pedal |
| 11 | Mod Wheel |
| 12 | Ext Controller |
| 13 | Mod Mixer |
| 14 | Pitch Wheel |
| 15 | MIDI Key Number |
