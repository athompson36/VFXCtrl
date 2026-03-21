# Parameter Catalog and Address Map

This file is the master reference for VFX-SD parameter addressing, derived from the
**official MIDI Implementation Specification v2.00** (section 5).

## Legend

- status = `verified` — from official spec
- status = `inferred` — plausible but not spec-confirmed
- status = `unknown` — placeholder

## Parameter Change Protocol (verified)

- **Message Type:** `00` (Command Message)
- **Command Type:** `01` (Parameter Change)
- **Addressing:** Voice [0..5], Page [0..31], Slot [0..5], Value [Hi+Lo bytes]
- **Encoding:** All data bytes nibblized (see spec section 2.3)
- **Per spec:** When multiple slots are listed, use the **highest** slot number.

## System Parameters (Pages 0–4)

| Key | Label | Page | Slot | Range | Status | Note |
|-----|-------|------|------|-------|--------|------|
| sys.masterVol | Master Volume | — | — | 0–127 | verified | **MIDI CC 7** (not SysEx) |
| sys.tune | Master Tune | 0 | 0 | -128..+127 | verified | |
| sys.touch | Touch | 0 | 1 | 0–4 | verified | SOFT,MED,FIRM,HARD 1-4 |
| sys.bendRange | System Bend Range | 0 | 2 | 0–12 | verified | Semitones |
| sys.fs1 | FS1 Footswitch | 0 | 4 | 0–3 | verified | UNUSED,SOSTENU,PATCH L,ADVANCE |
| sys.fs2 | FS2 Footswitch | 0 | 5 | 0–1 | verified | SUSTAIN,PATCH R |
| sys.sliderMode | Slider Mode | 1 | 0 | 0–1 | verified | NORMAL,TIMBRE |
| sys.cvPedal | CV Pedal Config | 1 | 1 | 0–1 | verified | VOL,MOD |
| sys.midiBaseCh | MIDI Base Channel | 3 | 0 | 0–15 | verified | 0-indexed |
| sys.midiInMode | MIDI Mode | 3 | 3 | 0–4 | verified | OMNI,POLY,MULTI,MONO A/B |
| sys.sysexRx | SysEx Enable | 4 | 3 | 0–1 | verified | OFF,ON |
| sys.localControl | Controllers Enable | 4 | 0 | 0–1 | verified | OFF,ON |
| sys.midiStatus | Program Change | 4 | 5 | 0–2 | verified | OFF,ON,NEW |

## Voice Parameters (repeat for each voice 0–5)

### Wave (Pages 7–10)

| Key | Label | Page | Slot | Range | Status |
|-----|-------|------|------|-------|--------|
| wave.select | Wave Name | 7 | 0 | 0–147 | verified |
| wave.class | Wave Class | 7 | 1 | 0–12 | verified |
| wave.delay | Delay Time | 7 | 2 | 0–251 | verified |
| wave.start | Start Index | 7 | 3 | 0–127 | verified |
| wave.velStart | Vel Start Mod | 7 | 4 | -127..+127 | verified |
| wave.direction | Direction | 7 | 5 | 0–1 | verified |

### Pitch (Page 11)

| Key | Label | Page | Slot | Range | Status |
|-----|-------|------|------|-------|--------|
| pitch.octave | Octave | 11 | 0 | -4..+4 | verified |
| pitch.semitone | Semitone | 11 | 1 | -12..+12 | verified |
| pitch.fine | Fine Tune | 11 | 2 | -127..+127 | verified |
| pitch.table | Pitch Table | 11 | 4 | 0–2 | verified |

### Pitch Mod (Page 12)

| Key | Label | Page | Slot | Range | Status |
|-----|-------|------|------|-------|--------|
| pitch.modSrc | Mod Source | 12 | 1 | 0–15 | verified |
| pitch.modAmt | Mod Amount | 12 | 2 | -99..+99 | verified |
| pitch.glideMode | Glide Mode | 12 | 3 | 0–4 | verified |
| pitch.env1Mod | Env1 Mod Amt | 12 | 4 | -127..+127 | verified |
| pitch.lfoMod | LFO Mod Amt | 12 | 5 | -127..+127 | verified |

### Filter #1 (Page 13)

| Key | Label | Page | Slot | Range | Status |
|-----|-------|------|------|-------|--------|
| filter.type | Type | 13 | 0 | 0–1 | verified |
| filter.cutoff | Cutoff | 13 | 1 | 0–127 | verified |
| filter.keytrack | Kbd Tracking | 13 | 2 | -127..+127 | verified |
| filter.modSrc | Mod Source | 13 | 3 | 0–15 | verified |
| filter.env | Env2 Mod | 13 | 4 | -127..+127 | verified |
| filter.modAmt | Mod Amount | 13 | 5 | -127..+127 | verified |

### Filter #2 (Page 14)

| Key | Label | Page | Slot | Range | Status |
|-----|-------|------|------|-------|--------|
| filter2.type | Type | 14 | 0 | 0–3 | verified |
| filter2.cutoff | Cutoff | 14 | 1 | 0–127 | verified |
| filter2.keytrack | Kbd Tracking | 14 | 2 | -127..+127 | verified |
| filter2.modSrc | Mod Source | 14 | 3 | 0–15 | verified |
| filter2.modAmt | Mod Amount | 14 | 4 | -127..+127 | verified |
| filter2.env | Env2 Mod | 14 | 5 | -127..+127 | verified |

### Output (Pages 15–17)

| Key | Label | Page | Slot | Range | Status |
|-----|-------|------|------|-------|--------|
| output.volume | Volume | 15 | 0 | 0–127 | verified |
| output.volModSrc | Vol Mod Src | 15 | 1 | 0–15 | verified |
| output.volModAmt | Vol Mod Amt | 15 | 2 | -127..+127 | verified |
| output.keyScale | Key Scaling | 15 | 3 | -128..+127 | verified |
| output.dest | Destination | 16 | 1 | 0–3 | verified |
| output.pan | Pan | 16 | 2 | 0–127 | verified |
| output.panModSrc | Pan Mod Src | 16 | 3 | 0–15 | verified |
| output.panModAmt | Pan Mod Amt | 16 | 4 | -127..+127 | verified |
| output.preGain | Pre-Gain | 16 | 5 | 0–1 | verified |
| output.priority | Voice Priority | 17 | 2 | 0–2 | verified |
| output.velThresh | Vel Threshold | 17 | 4 | -127..+127 | verified |

### LFO (Pages 18–19)

| Key | Label | Page | Slot | Range | Status |
|-----|-------|------|------|-------|--------|
| lfo.rate | Rate | 18 | 0 | 0–99 | verified |
| lfo.rateModSrc | Rate Mod Src | 18 | 1 | 0–15 | verified |
| lfo.rateModAmt | Rate Mod Amt | 18 | 2 | -127..+127 | verified |
| lfo.depth | Depth | 18 | 3 | 0–127 | verified |
| lfo.delay | Delay | 18 | 5 | 0–99 | verified |
| lfo.waveshape | Waveshape | 19 | 1 | 0–6 | verified |
| lfo.restart | Restart | 19 | 2 | 0–1 | verified |
| lfo.noiseRate | Noise Rate | 19 | 5 | 0–127 | verified |

### Env1 (Pages 20–22) — Amplitude Envelope

| Key | Label | Page | Slot | Range | Status |
|-----|-------|------|------|-------|--------|
| env1.initLevel | Init Level | 20 | 1 | 0–127 | verified |
| env1.peakLevel | Peak Level | 20 | 2 | 0–127 | verified |
| env1.bp1Level | BP1 Level | 20 | 3 | 0–127 | verified |
| env1.bp2Level | BP2 Level | 20 | 4 | 0–127 | verified |
| env1.susLevel | Sustain Level | 20 | 5 | 0–127 | verified |
| env1.attack | Attack Time | 21 | 1 | 0–99 | verified |
| env1.decay1 | Decay 1 | 21 | 2 | 0–99 | verified |
| env1.decay2 | Decay 2 | 21 | 3 | 0–99 | verified |
| env1.decay3 | Decay 3 | 21 | 4 | 0–99 | verified |
| env1.release | Release | 21 | 5 | -100..+99 | verified |
| env1.kbdTrack | Kbd Tracking | 22 | 0 | -127..+127 | verified |
| env1.velCurve | Vel Curve | 22 | 2 | 0–9 | verified |
| env1.mode | Mode | 22 | 3 | 0–2 | verified |
| env1.lvlVelSens | Level Vel Sens | 22 | 4 | 0–127 | verified |
| env1.atkVelSens | Atk Vel Sens | 22 | 5 | 0–127 | verified |

### Env2 (Pages 23–25) and Env3 (Pages 26–28)

Same structure as Env1 with offset pages. See `ParameterMap.swift` for full listings.

### Effects (Pages 29–31)

| Key | Label | Page | Slot | Range | Status | Note |
|-----|-------|------|------|-------|--------|------|
| fx.type | Effect Type | 29 | 1 | 0–21 | verified | 22 effect types |
| fx.fx1Mix | FX1 Mix | 29 | 4 | 0–127 | verified | |
| fx.fx2Mix | FX2 Mix | 29 | 5 | 0–127 | verified | |

Effect parameters on pages 30–31 are type-dependent. See spec section 5 for per-effect parameter layouts.

### Voice Select (Page 38)

| Key | Label | Page | Slot | Range | Status |
|-----|-------|------|------|-------|--------|
| voice.status[0-5] | Voice Status | 38 | 0–5 | 0–2 | verified |

Values: 0=OFF, 1=ON, 2=SOLO

## Parameter Ranges (UI)

Additional ranges for non-voice parameters:

| Page | Key | Range | Notes |
|------|-----|-------|-------|
| Seq | seq.tempo | 1–300 | BPM |
| Seq | seq.song | 1–60 | Song number |
| Seq | seq.sequence | 1–60 | Sequence number |
| Seq | seq.track | 1–24 | Track number |
| Mod | mod.src1, mod.src2 | 0–14 | Index into 15 mod sources |
| Mod | mod.dest1, mod.dest2 | 0–9 | Index into 10 mod destinations |

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
