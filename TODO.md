# VFX-CTRL Todo List

Prioritized tasks derived from the development plan. Check off as completed.

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

- [ ] **3.1** Add verified parameter addresses for Wave, Filter, Amp to `ParameterMap.swift` and `PARAMETER_MAP.md`
- [x] **3.2** Sync page controls with `currentPatch.parameters` and verified parameter definitions
- [ ] **3.3** Send real-time SysEx parameter edit on control change (with delay)
- [x] **3.4** “Compare” button: copy current patch to `comparePatch`; show diff
- [x] **3.5** Compare UI: show changed keys (e.g. `CompareEngine.changedKeys`) and values
- [x] **3.6** Snapshots: save/restore current state (named list; restore loads and optionally sends)
- [x] **3.7** “Send” button: serialize current patch and send program dump to synth

---

## Phase 4 – Motion, Mod, Perf + Macros + Favorites / Live Sets

- [ ] **4.1** Verify and add parameter addresses for Motion, Mod, Performance
- [ ] **4.2** Wire Motion, Mod, Perf to real-time SysEx (needs addresses)
- [x] **4.3** MacroEngine: all 8 macros map to params; docs/MACRO_MAP.md
- [x] **4.4** Favorites: toggle in context menu; Favorites section in sidebar
- [x] **4.5** Live sets: New Set, add patch (context menu), reorder/delete, tap to load
- [x] **4.6** TagEngine suggestions shown under patch name in Library

---

## Phase 5 – Sequencer + FX + Export + Hardware

- [ ] **5.1** Verify sequencer SysEx (transport, tempo, etc.) per manual/captures
- [x] **5.2** Transport Play/Stop/Record/Tap wired to placeholder methods (fill when SysEx verified)
- [ ] **5.3** Verify FX SysEx (patch vs global)
- [ ] **5.4** FX page real-time control when verified
- [x] **5.5** Export: Current Patch + Live Set to .syx (Gotek workflow)
- [x] **5.6** Disk image: doc updated; read-only extractor when format confirmed
- [x] **5.7** Hardware mirror note in HARDWARE_FUTURE.md

---

## Phase 6 – Gotek / librarian full compatibility

*Goal:* Close gaps in [docs/GOTEK_COMPATIBILITY_AUDIT.md](./docs/GOTEK_COMPATIBILITY_AUDIT.md) so the library editor matches documented Gotek + `CURSOR_CONTEXT` librarian requirements.*

- [ ] **6.1** Extend `VFXPatch` (or sidecar metadata): `sourceFileName`, `importedAt`, optional `sourceSynthOS`, `sysexSHA256` (or hash) for duplicate detection
- [ ] **6.2** On SysEx import, persist provenance; warn or merge when hash matches existing patch
- [ ] **6.3** Export presets for Gotek UX: optional **short filename** (e.g. ≤16 chars), numeric prefix (`01_`…`60_`), **collision-safe** names (never overwrite silently)
- [ ] **6.4** Optional export layout: category subfolders per `docs/VFX_SD_Context.md` (`00_FACTORY`, `03_PAD`, …)
- [ ] **6.5** **60-program bank** model: wire `VFXBank` (or extend Live Set) with max 60 ordered slots; validate on export; optional `bank.json` manifest
- [ ] **6.6** **Bulk import**: multi-select `.syx` or “import folder” in `LibrarySidebar`
- [ ] **6.7** **UTType**: register/use `.syx` in file importer and export where supported
- [ ] **6.8** Disk image **Phase 2**: confirm Ensoniq/VFX-SD sector layout or integrate external tool; read-only **metadata / file list** OR document manual pipeline from `.img` → `.syx`
- [ ] **6.9** **HFE** strategy: document FlashFloppy constraints in README; no binary HFE writer until **Phase 3** of `DISK_IMAGE_PLAN.md` + verified layout
- [ ] **6.10** Update `VFX_CAPABILITY_AUDIT.md` (Wave/Motion sections still describe old 8-knob grids — sync with `ParameterDefinitionsPage` + map-driven UI)

---

## Ongoing / Maintenance

- [ ] Update `PARAMETER_MAP.md` and `ParameterMap.swift` for every new verified parameter
- [x] Add unit tests for PatchParser, CompareEngine, MacroEngine (Tests/VFXCtrlTests)
- [x] Store MIDI delay and last input/output names (UserDefaults)
- [x] VirtualEncoder: accessibilityLabel, accessibilityValue, accessibilityHint

---

## Quick reference: where things live

| Topic | Primary files |
|-------|----------------|
| MIDI I/O | `src/midi/MIDIDeviceManager.swift`, SysExSender, SysExReceiver |
| Patch model | `src/patch/VFXPatch.swift`, PatchParser, PatchSerializer, ParameterMap |
| Editor state | `src/editor/EditorState.swift`, CompareEngine, MacroEngine |
| Library | `src/librarian/LibraryDB.swift`, BankManager, TagEngine |
| UI | `src/app/MainView.swift`, `src/ui/pages/*`, `src/ui/panels/*`, `src/ui/components/*` |
| Docs | `docs/` (see DEVELOPMENT_PLAN.md “Doc Index”; Gotek audit: `GOTEK_COMPATIBILITY_AUDIT.md`) |
| Captures | `sysex/` — put .syx dumps and notes here |
| Tools | `tools/vfx_sysex_inspector.py`, `tools/build_parameter_csv.py` |
