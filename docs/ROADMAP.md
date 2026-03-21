# Roadmap — VFX-CTRL

High-level path from today’s codebase to a **production 1.0**. Detailed tasks live in [`TODO.md`](../TODO.md) and [`docs/PRODUCTION_CHECKLIST.md`](./PRODUCTION_CHECKLIST.md).

---

## Current state (code + docs aligned)

| Area | Status |
|------|--------|
| **MIDI** | CoreMIDI in/out, paced send, delay + stop, logging (`MIDIDeviceManager`, `SysExSender` / `SysExReceiver`) |
| **Patch I/O** | `PatchParser` / `PatchSerializer` for program dumps; checksum path stubbed |
| **Library** | `LibraryDB` persistence, favorites, live sets, tags, bulk import, duplicate detection (SHA256 + alert) |
| **Export / Gotek** | Folder export, optional short names, numeric prefix, category folders, collision-safe names, optional `bank.json`, 60-slot awareness — see [`GOTEK_COMPATIBILITY_AUDIT.md`](./GOTEK_COMPATIBILITY_AUDIT.md) |
| **Editor UI** | Map-driven tabs via `ParameterDefinitionsPage` + `ParameterMap` (~100 defs); Mod / System / Sequencer use custom layouts — [`UI_PAGES.md`](./UI_PAGES.md) |
| **Live editing** | When **Live** is on, `EditorState` throttles sends; `LiveSysExBuilder` maps keys to SysEx/CC/virtual buttons — [`LIVE_COVERAGE_AUDIT.md`](./LIVE_COVERAGE_AUDIT.md) + `LiveCoverageTests` |
| **Macros** | `MacroEngine` applies all eight macro keys to underlying params (`docs/MACRO_MAP.md`) |
| **Tests** | `swift test` — parser, compare, macros, export naming, provenance, enum labels (expand before 1.0) |

**Still dependent on hardware / captures:** Phase 0 items in `TODO.md`, checksum algorithm, “request current program” message fidelity, and end-to-end confirmation that live edits match the synth.

---

## Milestone A — **MVP (internal / dogfood)**

*Goal:* Trust the app with a real VFX-SD for day-to-day patch tweaks and library work.

- Complete **Phase 0** (baseline `.syx` in `sysex/`, OS notes, MIDI reliability).
- **Hardware-prove** live parameter path: sample keys per tab vs. OLED behavior.
- **Document gaps:** any `ParameterMap` key not in `LiveSysExBuilder.supportedLiveKeys` (patch-only edits until addressed).
- **Request / Send:** verify or adjust SysEx messages against [`VFX_SYSEX_SPEC.md`](./VFX_SYSEX_SPEC.md) and captures.
- **UX:** clear errors when MIDI unavailable, send fails, or parse rejects a file.

---

## Milestone B — **Public beta**

*Goal:* Wider testers; honest limits documented.

- Expand **automated tests** (golden dump round-trips, `LiveSysExBuilder` snapshot tests, export edge cases).
- **Sequencer / FX:** confirm or scope-reduce what the VFX-SD accepts; align UI labels with reality.
- **Checksum:** implement or explicitly document “bypass” behavior in UI and parser.
- **Performance:** large libraries (500+ patches), folder import stress.
- **Docs:** install, MIDI setup, Gotek export walkthrough, known issues list.

---

## Milestone C — **1.0 production**

*Goal:* Signed, notarized macOS app with support expectations.

- **Release engineering:** Apple Developer ID, Hardened Runtime, notarization, versioning scheme.
- **Distribution:** direct download and/or updates policy (document in README).
- **Compliance:** entitlements, privacy manifest if required, crash/analytics decision (on or explicitly off).
- **QA matrix:** OS versions × MIDI interfaces × documented synth OS — stored in repo (see production checklist).
- **Product:** README and in-app About; support channel; criteria for “verified” vs “experimental” parameters in `PARAMETER_MAP.md`.

---

## Historical phase labels (0–6)

Phases **0–5** in `TODO.md` / `DEVELOPMENT_PLAN.md` describe original build order. **Phase 6** (Gotek / librarian alignment) is **done** in code for the scoped items there. **Phase 7** in `TODO.md` tracks **production** work (milestones B–C above).

---

## Non-goals (unchanged)

Per [`VFX_PROJECT_SPEC.md`](./VFX_PROJECT_SPEC.md): no claiming a complete unverified SysEx map; no arbitrary floppy image writer until layout is proven; no replacing internal waveform ROM.
