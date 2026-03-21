# Phase 5 — Sequencer & FX (verification deferred to hardware)

Items **5.1** and **5.3** in [`TODO.md`](../TODO.md) need a **real VFX-SD** and captures; this doc ties spec sections to code so you can close them methodically.

## 5.1 Sequencer SysEx

| Topic | In code today | Verify on hardware |
|-------|----------------|---------------------|
| Transport | `LiveSysExBuilder` virtual buttons `seq.play` (91), `seq.stop` (92), `seq.record` (89); `MIDIDeviceManager.sequencerPlay/Stop/Record` | Confirm numbers vs front panel / spec §3.1.1 (OCR table in `Ensoniq VFX-SD MIDI Implementation Specification v2.00.md`) |
| Tap tempo | `sequencerTap()` — **not mapped** (shows notice) | Assign virtual button # when confirmed |
| Tempo / song / track UI | `ParameterMap` keys `seq.tempo`, `seq.song`, … (sysexPage 997) — **not** in `LiveSysExBuilder` | Map to real parameter-change pages/slots or leave patch-only |
| Track/song dump | [`SeqDumpLoadView`](../src/ui/pages/sequencer/SeqDumpLoadView.swift) — buttons show **TBD notice** | After §3.1.x dump messages verified, wire `MIDIDeviceManager` + parse |

## 5.3 FX SysEx

| Topic | In code today | Verify on hardware |
|-------|----------------|---------------------|
| FX program params | `fx.*` in `ParameterMap` + `LiveSysExBuilder` for pages 29–31 | Audition each control with **Live** on |
| Global vs per-patch | Document in `PARAMETER_MAP.md` if any FX is global-only | Compare spec §5 effect pages vs single-voice dumps |

## Related

- [`LIVE_COVERAGE_AUDIT.md`](./LIVE_COVERAGE_AUDIT.md) — map vs live table (997-page seq keys intentionally not live).
- [`HARDWARE_REGRESSION_MATRIX.md`](./HARDWARE_REGRESSION_MATRIX.md) — log pass/fail as you test.
