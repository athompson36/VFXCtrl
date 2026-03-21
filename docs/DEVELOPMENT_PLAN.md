# VFX-CTRL Development Plan

This plan aligns the codebase with `ROADMAP.md`, `VFX_PROJECT_SPEC.md`, and supporting docs. It defines phases, dependencies, and implementation targets.

---

## Current State Summary

*Last aligned with codebase audit: 2026-03. For product milestones see [`ROADMAP.md`](./ROADMAP.md) and [`PRODUCTION_CHECKLIST.md`](./PRODUCTION_CHECKLIST.md).*

### Implemented

| Area | Status | Notes |
|------|--------|--------|
| **App shell** | Done | SwiftUI `VFXCtrlApp`, `MainView`, `NavigationSplitView` |
| **Editor state** | Done | `EditorState`: pages, `currentPatch` / `comparePatch`, snapshots, live-send throttling |
| **Page model** | Done | 9 pages (`EditorPage`), `PageSelector` |
| **UI pages** | Done | Most tabs: **`ParameterDefinitionsPage`** driven by `ParameterMap` (~100 defs), grouped by SysEx page; **Mod**, **System**, **Sequencer** use custom views — [`UI_PAGES.md`](./UI_PAGES.md) |
| **VirtualEncoder** | Done | Used in map-driven rows; accessibility labels/values |
| **Patch model** | Done | `VFXPatch` + provenance (`sourceFileName`, `importedAt`, `sysexSHA256`, optional `sourceSynthOS`) |
| **Compare engine** | Done | `CompareEngine.changedKeys`; compare UI |
| **Macro engine** | Done | Eight macros map to multiple params (`MacroEngine`, `docs/MACRO_MAP.md`) |
| **Parameter map** | Substantial | `ParameterMap.swift` + `PARAMETER_MAP.md`; per-key verification ongoing |
| **Library** | Done | `LibraryDB` persistence, favorites, live sets, bulk import, duplicate detection, `TagEngine` |
| **MIDI** | Done | CoreMIDI in/out in `MIDIDeviceManager`, device refresh, paced `SysExSender`, `SysExReceiver`, user delay + stop |
| **Live parameter MIDI** | Done | `LiveSysExBuilder`: SysEx nibbles + CC (e.g. master vol) + sequencer virtual buttons; gated by Live preference |
| **Patch I/O** | Partial | `PatchParser` / `PatchSerializer` for program dumps; **checksum stub** |
| **Transport / export** | Partial | Send / request / compare / transport wired per current spec; **hardware confirmation** still Phase 0 / 7 |
| **SysEx console** | Done | Log + delay; reflects real traffic when connected |
| **Gotek / export** | Done (scoped) | Folder export, naming options, optional `bank.json`, 60-slot awareness — [`GOTEK_COMPATIBILITY_AUDIT.md`](./GOTEK_COMPATIBILITY_AUDIT.md) |
| **Tests** | Growing | `swift test`: parser, compare, macros, export naming, provenance, enum labels |
| **Tools** | Done | `vfx_sysex_inspector.py`, `build_parameter_csv.py` |

### Still open / verification

- Phase **0** captures and synth OS notes (`sysex/`)
- **Checksum** algorithm and strict validation (or explicit “not validated” UX)
- **Hardware proof** of live edits, request patch, and full program send
- **Coverage:** keep `ParameterMap` keys and `LiveSysExBuilder.supportedLiveKeys` in sync; document “patch-only” controls
- **Sequencer / FX:** protocol limits vs UI (see `TODO.md` Phase 5)
- **Disk image** in-app read: still manual / TBD per `DISK_IMAGE_PLAN.md`
- **Production:** signing, notarization, CI, QA matrix (`PRODUCTION_CHECKLIST.md`)

---

## Phase 0: Verification Foundation (pre-dev)

**Goal:** Confirm hardware, OS, and capture path before committing to byte layouts.

| # | Task | Owner | Doc ref |
|---|------|--------|---------|
| 0.1 | Capture real VFX-SD dumps (Current Program) into `sysex/` | User | README, PARAMETER_RESEARCH_WORKFLOW |
| 0.2 | Verify MIDI path and timing (interface, SysEx on, no drops) | User | MIDI_TIMING |
| 0.3 | Confirm VFX-SD OS version and SysEx behavior from manual | User | VFX_SYSEX_SPEC |

**Exit criteria:** At least one baseline program dump saved; naming per `sysex/notes.md`.

---

## Phase 1: App Shell + MIDI Transport *(implemented)*

**Goal:** App talks to the synth over CoreMIDI; raw SysEx send/receive with safe timing.

| # | Task | Dependencies | Notes |
|---|------|--------------|--------|
| 1.1 | Add Xcode project or Swift Package for macOS 14+ | — | If not already in parent repo |
| 1.2 | Implement CoreMIDI enumeration in `MIDIDeviceManager` | — | List inputs/outputs; persist or pick default device |
| 1.3 | Wire CoreMIDI input → `SysExReceiver` → `MIDIDeviceManager.receiveSysEx` | 1.2 | Accumulate SysEx; log with timestamp |
| 1.4 | Wire `MIDIDeviceManager.sendSysEx` → paced send via `SysExSender` → CoreMIDI output | 1.2 | Use `interMessageDelayMs` (default 40 ms); max burst 1 |
| 1.5 | Add user-adjustable delay in UI (e.g. Transport or SysEx console) | 1.4 | Per MIDI_TIMING |
| 1.6 | Emergency stop for sends | 1.4 | Cancel in-flight queue |
| 1.7 | Log all MIDI traffic with timestamps | 1.3, 1.4 | Optional: persist to `MIDILogger`-style entries |

**Exit criteria:** User can select MIDI in/out, receive and log incoming SysEx, send raw SysEx with configurable delay and stop.

---

## Phase 2: Patch Parser + Library + Browser

**Goal:** Parse captured program dumps into `VFXPatch`; library DB and patch browser.

| # | Task | Dependencies | Notes |
|---|------|--------------|--------|
| 2.1 | Reverse-engineer one program dump format (with inspector + notes) | Phase 0 | Follow PARAMETER_RESEARCH_WORKFLOW; update PARAMETER_MAP.md |
| 2.2 | Implement `PatchParser.parseProgramDump` for verified layout | 2.1 | Extract name, category if present, and all mapped bytes into `parameters` |
| 2.3 | Implement checksum validation in parser (optional bypass for raw-tool mode) | 2.2 | Per VFX_SYSEX_SPEC |
| 2.4 | Wire Transport “Request Patch” to send VFX-SD “Current Program request” (when verified) | Phase 1, 2.1 | Only after message format verified |
| 2.5 | On receive: if program dump, parse and set `editorState.currentPatch` | 2.2, 1.3 | Optional: also push to “Incoming Captures” |
| 2.6 | Library: persist `LibraryDB` (e.g. UserDefaults, file, or SQLite) | — | Add save/load |
| 2.7 | Library sidebar: “All Patches” shows library list; select patch loads into editor | 2.6 | |
| 2.8 | Import SysEx file into library (file picker → parse if program dump) | 2.2, 2.6 | |
| 2.9 | Patch list / content view: show current patch name and compare patch name | 2.7 | Already partially in PatchListView |

**Exit criteria:** Request patch → receive → parse → show in editor; import file → library; browse and select from library.

---

## Phase 3: Wave, Filter, Amp Pages + Compare + Snapshots

**Goal:** Edit key sound parameters; A/B compare; snapshots.

| # | Task | Dependencies | Notes |
|---|------|--------------|--------|
| 3.1 | Extend parameter map with verified addresses for Wave, Filter, Amp (per page) | Phase 2, PARAMETER_RESEARCH_WORKFLOW | Update ParameterMap.swift and PARAMETER_MAP.md |
| 3.2 | Drive page controls from `currentPatch.parameters` | 3.1 | `ParameterDefinitionsPage` + map (replaces old fixed PageGrid model) |
| 3.3 | On control change: live SysEx/CC when key supported | 3.1, Phase 1 | `LiveSysExBuilder` + `EditorState` throttling; verify on hardware |
| 3.4 | “Compare” button: set `comparePatch = currentPatch` copy; show diff | CompareEngine exists | Highlight changed params in UI |
| 3.5 | Compare view: side-by-side or diff list using `CompareEngine.changedKeys` | 3.4 | |
| 3.6 | Snapshots: save current state to a list (in-memory or library); restore | 2.6 | Name snapshot; restore loads into currentPatch and optionally sends to synth |
| 3.7 | Transport “Send”: serialize current patch and send as program dump (if verified) | 2.2, PatchSerializer | Per timing rules |

**Exit criteria:** Edit Wave/Filter/Amp; see changes on synth; compare A/B; take and restore snapshots; send patch to synth.

---

## Phase 4: Motion, Mod, Performance + Macros + Favorites / Live Sets

**Goal:** Full sound-editing pages; macro knobs; favorites and live sets.

| # | Task | Dependencies | Notes |
|---|------|--------------|--------|
| 4.1 | Verify and add parameter addresses for Motion, Mod, Performance | PARAMETER_RESEARCH_WORKFLOW | |
| 4.2 | Motion, Mod, Perf live sends for supported keys | 4.1, Phase 3 | Mod matrix may need extra hardware validation |
| 4.3 | Macro page: map macro knobs to multiple parameters (MacroEngine) | 3.1, 4.1 | Implemented; document in `MACRO_MAP.md` |
| 4.4 | Favorites: mark patches as favorite; filter in sidebar | 2.6 | |
| 4.5 | Live sets: named sets of patches; reorder; load set into “slots” for performance | 2.6 | |
| 4.6 | TagEngine: integrate suggestions into library UI (optional auto-tag on import) | 2.8 | |

**Exit criteria:** All 9 pages editable where verified; macros drive multi-param; favorites and live sets usable.

---

## Phase 5: Sequencer + FX + Export + Hardware Mirror

**Goal:** Sequencer and FX control (after protocol verification); Gotek/export; hardware mirror prep.

| # | Task | Dependencies | Notes |
|---|------|--------------|--------|
| 5.1 | Verify sequencer SysEx (transport, tempo, song/seq, track) | Phase 0, VFX_SYSEX_SPEC | May be limited on VFX-SD |
| 5.2 | Transport: virtual-button SysEx for play/stop/record when Live on; tap tempo per spec | 5.1, Phase 1 | Confirm on hardware |
| 5.3 | Verify FX parameter SysEx (patch vs global) | Phase 0 | |
| 5.4 | FX page: real-time control when verified | 5.3, 4.2 | |
| 5.5 | Export: curated bank/set to SysEx files for Gotek workflow | 2.6, DISK_IMAGE_PLAN | Phase 2 of disk plan |
| 5.6 | Disk image: read-only metadata extractor (list files, identify banks) | DISK_IMAGE_PLAN | Phase 2 |
| 5.7 | Hardware mirror mode: UI reflects “one knob per function” for future hardware | HARDWARE_FUTURE | No hardware yet; keep layout compatible |

**Exit criteria:** Sequencer/FX under app control where protocol allows; export to SysEx; disk read-only metadata; UI ready for hardware mirror.

---

## Phase 7: Production (see `TODO.md`)

**Goal:** Signed, notarized macOS build; documented QA; honest limits for users.

| # | Task | Notes |
|---|------|--------|
| 7.1–7.10 | Checklist items | [`PRODUCTION_CHECKLIST.md`](./PRODUCTION_CHECKLIST.md), [`ROADMAP.md`](./ROADMAP.md) |

---

## Cross-Cutting and Maintenance

- **Parameter research:** Ongoing; every new verified offset gets documented in `PARAMETER_MAP.md` and `ParameterMap.swift` with status.
- **Tests:** Expand golden dumps, `LiveSysExBuilder` snapshots, export edge cases before 1.0.
- **MIDI prefs:** Delay and last device names in UserDefaults (MIDI_TIMING).
- **Accessibility:** VirtualEncoder + map-driven cells include labels/values.

---

## Dependency Graph (high level)

```
Phase 0 (capture/verify) ─────────────────────┐
    ↓                                         │
Phase 1 (MIDI transport) ✓                    │
    ↓                                         │
Phase 2 (parser, library, browser) ✓          │  Hardware + checksum
    ↓                                         │  proof & release
Phase 3 (edit/compare/snapshots) ✓            │  engineering
    ↓                                         │
Phase 4 (Motion/Mod/Perf, macros, sets) ✓     │
    ↓                                         │
Phase 5 (Sequencer, FX, export, disk) partial  │
    ↓                                         │
Phase 6 (Gotek/librarian alignment) ✓         │
    ↓                                         ↓
Phase 7 (production) ←────────────────────────┘
```

---

## Doc Index

| Document | Purpose |
|----------|---------|
| README.md | Status, first test workflow, caution on parameter map |
| docs/VFX_PROJECT_SPEC.md | Product goals, app modes, UX, deliverables |
| docs/ROADMAP.md | Milestones MVP → 1.0 + current state |
| docs/PRODUCTION_CHECKLIST.md | Signing, QA, ship criteria |
| docs/RELEASE.md | Notarization / distribution draft steps |
| docs/PHASE5_SEQUENCER_FX.md | Sequencer/FX hardware verification vs code |
| CHANGELOG.md | Release notes (Keep a Changelog) |
| docs/SUPPORT.md | Support / bug report template |
| docs/UI_PAGES.md | Map-driven tabs + custom Mod/System/Seq |
| docs/PARAMETER_MAP.md | Inventory + address table (verified/inferred/unknown) |
| docs/PARAMETER_RESEARCH_WORKFLOW.md | Dump-based and real-time mapping steps |
| docs/MIDI_TIMING.md | Delays, coalescing, safety |
| docs/VFX_SYSEX_SPEC.md | What’s verified vs unknown |
| docs/HARDWARE_FUTURE.md | Controller concept |
| docs/DISK_IMAGE_PLAN.md | SysEx → read-only disk → export |
| docs/DEVELOPMENT_PLAN.md | This file |
| sysex/notes.md | Capture naming and notes |
