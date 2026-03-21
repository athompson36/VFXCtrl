# VFX-CTRL Todo List

Prioritized tasks derived from the development plan and [docs/ROADMAP.md](./docs/ROADMAP.md). Check off as completed.

**Audit (2026-03):** Editor is **map-driven** (`ParameterDefinitionsPage` + `ParameterMap`, 200+ parameter rows). **Live MIDI** is implemented for keys in `LiveSysExBuilder.supportedLiveKeys` (SysEx nibbles + CC + sequencer virtual buttons) when the **Live** preference is on — see `EditorState` + `MainView`. Remaining work toward production is mostly **hardware verification**, **parser/checksum hardening**, **coverage audit** (map vs live table), and **release engineering** (Phase 7 + [docs/PRODUCTION_CHECKLIST.md](./docs/PRODUCTION_CHECKLIST.md)).

---

## Phase 0 – Verification (do first, no code)

- [ ] Capture at least one VFX-SD Current Program dump to `sysex/`
- [ ] Name files per `sysex/notes.md` (e.g. `baseline_current_program.syx`)
- [ ] Verify MIDI interface and SysEx receive enabled; confirm no drops
- [ ] Note VFX-SD OS version and any SysEx quirks in `sysex/notes.md`

---

## Phase 1 – MIDI Transport (immediate code work)

- [x] **1.1** Add Xcode project or Swift Package (macOS 14+, Swift 5.10+) if not present
- [x] **1.2** Implement CoreMIDI device enumeration in `MIDIDeviceManager.refreshDevices()`
- [x] **1.3** Wire CoreMIDI input → SysEx accumulation → `receiveSysEx` + log with timestamp
- [x] **1.4** Wire `sendSysEx` → paced send → CoreMIDI output (use `interMessageDelayMs`, max burst 1)
- [x] **1.5** Expose user-adjustable inter-message delay in UI (e.g. SysEx console or Transport)
- [x] **1.6** Add emergency stop to cancel queued sends
- [x] **1.7** Ensure all MIDI traffic logged with timestamps (optionally persist)

---

## Phase 2 – Parser + Library + Browser

- [x] **2.1** Use `tools/vfx_sysex_inspector.py` to diff captures; document one program dump layout in `docs/PARAMETER_MAP.md`
- [x] **2.2** Implement `PatchParser.parseProgramDump` for verified byte layout (F0 0F 05 … F7)
- [x] **2.3** Checksum validation stub (validateChecksum param; algorithm TBD)
- [x] **2.4** Placeholder for “Request Patch” (send VFX-SD current program request when format verified)
- [x] **2.5** On received program dump: parse and set `editorState.currentPatch` (and optionally “Incoming Captures”)
- [x] **2.6** Persist `LibraryDB` (save/load)
- [x] **2.7** Sidebar “All Patches”: list library; selecting loads into editor
- [x] **2.8** Import SysEx file (file picker → parse → add to library)
- [x] **2.9** Patch list: current and compare names

---

## Phase 3 – Wave, Filter, Amp + Compare + Snapshots

- [x] **3.1** Wave / Filter / Amp (and related) parameters in `ParameterMap.swift` + `PARAMETER_MAP.md` — *ongoing: mark per-key verification status in docs after Phase 0 hardware passes*
- [x] **3.2** Sync page controls with `currentPatch.parameters` and verified parameter definitions
- [x] **3.3** Real-time SysEx/CC on control change when **Live** is enabled (`EditorState` throttling + `LiveSysExBuilder`); *remaining: verify audibly on hardware + close any map/live key gaps*
- [x] **3.4** “Compare” button: copy current patch to `comparePatch`; show diff
- [x] **3.5** Compare UI: show changed keys (e.g. `CompareEngine.changedKeys`) and values
- [x] **3.6** Snapshots: save/restore current state (named list; restore loads and optionally sends)
- [x] **3.7** “Send” button: serialize current patch and send program dump to synth

---

## Phase 4 – Motion, Mod, Perf + Macros + Favorites / Live Sets

- [x] **4.1** Motion / Mod / Performance parameters present in map + docs — *remaining: hardware-verify nibble behavior and enum ranges where marked inferred*
- [x] **4.2** Map-driven Motion / Filter / Amp / Performance / FX / Macro tabs send live when key is in `supportedLiveKeys`; Mod page uses same pipeline for encoded keys — *verify Mod matrix on hardware*
- [x] **4.3** MacroEngine: all 8 macros map to params; docs/MACRO_MAP.md
- [x] **4.4** Favorites: toggle in context menu; Favorites section in sidebar
- [x] **4.5** Live sets: New Set, add patch (context menu), reorder/delete, tap to load
- [x] **4.6** TagEngine suggestions shown under patch name in Library

---

## Phase 5 – Sequencer + FX + Export + Hardware

- [ ] **5.1** Verify sequencer SysEx (transport, tempo, song/track, etc.) per manual/captures — *progress doc:* [`docs/PHASE5_SEQUENCER_FX.md`](./docs/PHASE5_SEQUENCER_FX.md); Seq dump tab buttons surface TBD notices*
- [x] **5.2** Transport Play/Stop/Record: **virtual button** SysEx via `LiveSysExBuilder` when Live is on; Tap: user notice (virtual button # TBD on hardware) via `sequencerTap()`
- [ ] **5.3** Verify FX SysEx (patch vs global) — *same doc:* [`docs/PHASE5_SEQUENCER_FX.md`](./docs/PHASE5_SEQUENCER_FX.md)*
- [x] **5.4** FX tab: map-driven live sends for keys in live table — *remaining: 5.3 proof + any missing FX keys in `LiveSysExBuilder`*
- [x] **5.5** Export: Current Patch + Live Set to .syx (Gotek workflow)
- [x] **5.6** Disk image: doc updated; read-only extractor when format confirmed
- [x] **5.7** Hardware mirror note in HARDWARE_FUTURE.md

---

## Phase 6 – Gotek / librarian full compatibility

*Goal:* Close gaps in [docs/GOTEK_COMPATIBILITY_AUDIT.md](./docs/GOTEK_COMPATIBILITY_AUDIT.md) so the library editor matches documented Gotek + `CURSOR_CONTEXT` librarian requirements.*

- [x] **6.1** Extend `VFXPatch` (or sidecar metadata): `sourceFileName`, `importedAt`, optional `sourceSynthOS`, `sysexSHA256` (or hash) for duplicate detection
- [x] **6.2** On SysEx import, persist provenance; warn or merge when hash matches existing patch
- [x] **6.3** Export presets for Gotek UX: optional **short filename** (e.g. ≤16 chars), numeric prefix (`01_`…`60_`), **collision-safe** names (never overwrite silently)
- [x] **6.4** Optional export layout: category subfolders per `docs/VFX_SD_Context.md` (`00_FACTORY`, `03_PAD`, …)
- [x] **6.5** **60-program bank** model: wire `VFXBank` (or extend Live Set) with max 60 ordered slots; validate on export; optional `bank.json` manifest
- [x] **6.6** **Bulk import**: multi-select `.syx` or “import folder” in `LibrarySidebar`
- [x] **6.7** **UTType**: register/use `.syx` in file importer and export where supported
- [x] **6.8** Disk image **Phase 2**: confirm Ensoniq/VFX-SD sector layout or integrate external tool; read-only **metadata / file list** OR document manual pipeline from `.img` → `.syx`
- [x] **6.9** **HFE** strategy: document FlashFloppy constraints in README; no binary HFE writer until **Phase 3** of `DISK_IMAGE_PLAN.md` + verified layout
- [x] **6.10** Update `VFX_CAPABILITY_AUDIT.md` (Wave/Motion sections still describe old 8-knob grids — sync with `ParameterDefinitionsPage` + map-driven UI)

---

## Phase 7 – Production (release + QA)

*See [docs/PRODUCTION_CHECKLIST.md](./docs/PRODUCTION_CHECKLIST.md) for detail.*

- [ ] **7.1** Close **Phase 0** (captures, OS notes, MIDI reliability)
- [x] **7.2** **Live coverage audit:** `tools/audit_live_coverage.py` → [`docs/LIVE_COVERAGE_AUDIT.md`](./docs/LIVE_COVERAGE_AUDIT.md); `LiveCoverageTests` guards live keys ⊆ map; hardware-page rows match live table *(re-run script after map edits)*
- [x] **7.3** **Checksum:** `VFXPatch.importIntegrityNote` + parser + Patch list UI; algorithm still TBD
- [x] **7.4** **Request patch:** wired to `MIDIDeviceManager.requestCurrentProgram()`; output guard + 5s timeout notice; *remaining: confirm request bytes on hardware*
- [ ] **7.5** **Send patch:** full program dump acceptance test on target OS *(automated: `PatchSerializerTests` for raw round-trip; hardware acceptance still manual)*
- [x] **7.6** **CI:** [`.github/workflows/ci.yml`](./.github/workflows/ci.yml) — `swift test` on push/PR to `main`/`master` + manual **`workflow_dispatch`**
- [x] **7.7** **Stress QA:** partial automation — `ExportNamingTests.testWritePatches_sixtyPatches_numericPrefix_noOverwrite`; *still run large library + real bulk import on device when possible*
- [x] **7.8** **Signing + notarization:** draft workflow in [`docs/RELEASE.md`](./docs/RELEASE.md); *execute + verify on your Apple account when shipping*
- [x] **7.9** **Ship artifacts:** [`CHANGELOG.md`](./CHANGELOG.md), version notes in [`docs/RELEASE.md`](./docs/RELEASE.md), support template [`docs/SUPPORT.md`](./docs/SUPPORT.md) — *fill URLs/contact when you publish*
- [x] **7.10** **Regression matrix:** template [`docs/HARDWARE_REGRESSION_MATRIX.md`](./docs/HARDWARE_REGRESSION_MATRIX.md) — fill as you test

---

## Ongoing / Maintenance

- [ ] Update `PARAMETER_MAP.md` and `ParameterMap.swift` for every new verified parameter *(last doc sync: 2026-03-21 — expanded System/MIDI/Program/Mod/LFO/FX; UI vs logical ranges; maintenance checklist)*
- [x] Add unit tests for PatchParser, CompareEngine, MacroEngine, PatchProvenance (Tests/VFXCtrlTests)
- [x] Store MIDI delay and last input/output names (UserDefaults)
- [x] VirtualEncoder: accessibilityLabel, accessibilityValue, accessibilityHint

---

## Quick reference: where things live

| Topic | Primary files |
|-------|----------------|
| MIDI I/O | `src/midi/MIDIDeviceManager.swift`, `SysExSender`, `SysExReceiver`, `LiveSysExBuilder` |
| Patch model | `src/patch/VFXPatch.swift`, PatchParser, PatchSerializer, ParameterMap |
| Editor state | `src/editor/EditorState.swift`, CompareEngine, MacroEngine |
| Library | `src/librarian/LibraryDB.swift`, BankManager, TagEngine |
| UI | `src/app/MainView.swift`, `ExportHelper.swift`, `ExportNaming.swift`, `VFXSysExTypes.swift`, `SysExFolderPicker.swift`, `src/ui/pages/*`, `src/ui/panels/*`, `src/ui/components/*` |
| Docs | `docs/` (see DEVELOPMENT_PLAN.md “Doc Index”; Gotek audit: `GOTEK_COMPATIBILITY_AUDIT.md`) |
| Captures | `sysex/` — put .syx dumps and notes here |
| Tools | `tools/vfx_sysex_inspector.py`, `tools/build_parameter_csv.py`, `tools/audit_live_coverage.py` |
