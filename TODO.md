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

- [ ] **2.1** Use `tools/vfx_sysex_inspector.py` to diff captures; document one program dump layout in `docs/PARAMETER_MAP.md`
- [ ] **2.2** Implement `PatchParser.parseProgramDump` for verified byte layout
- [ ] **2.3** Add checksum validation in parser (with optional bypass for raw-tool mode)
- [ ] **2.4** Implement “Request Patch” (send VFX-SD current program request when format verified)
- [ ] **2.5** On received program dump: parse and set `editorState.currentPatch` (and optionally “Incoming Captures”)
- [ ] **2.6** Persist `LibraryDB` (save/load)
- [ ] **2.7** Sidebar “All Patches”: list library; selecting loads into editor
- [ ] **2.8** Import SysEx file (file picker → parse → add to library)
- [ ] **2.9** Patch list: show current and compare patch names clearly

---

## Phase 3 – Wave, Filter, Amp + Compare + Snapshots

- [ ] **3.1** Add verified parameter addresses for Wave, Filter, Amp to `ParameterMap.swift` and `PARAMETER_MAP.md`
- [ ] **3.2** Sync page controls with `currentPatch.parameters` and verified parameter definitions
- [ ] **3.3** Send real-time SysEx parameter edit on control change (with delay)
- [ ] **3.4** “Compare” button: copy current patch to `comparePatch`; show diff
- [ ] **3.5** Compare UI: show changed keys (e.g. `CompareEngine.changedKeys`) and values
- [ ] **3.6** Snapshots: save/restore current state (named list; restore loads and optionally sends)
- [ ] **3.7** “Send” button: serialize current patch and send program dump to synth

---

## Phase 4 – Motion, Mod, Perf + Macros + Favorites / Live Sets

- [ ] **4.1** Verify and add parameter addresses for Motion, Mod, Performance
- [ ] **4.2** Wire Motion, Mod, Perf pages to parameters and real-time SysEx
- [ ] **4.3** Expand MacroEngine (all 8 macros); document mapping in docs
- [ ] **4.4** Favorites: mark patches; filter sidebar by favorite
- [ ] **4.5** Live sets: create/edit named sets; reorder; load set for performance
- [ ] **4.6** (Optional) Use TagEngine suggestions in library UI

---

## Phase 5 – Sequencer + FX + Export + Hardware

- [ ] **5.1** Verify sequencer SysEx (transport, tempo, etc.) per manual/captures
- [ ] **5.2** Wire Play, Stop, Record, Tap to sequencer when verified
- [ ] **5.3** Verify FX SysEx (patch vs global)
- [ ] **5.4** FX page real-time control when verified
- [ ] **5.5** Export curated bank/set to SysEx files (Gotek workflow)
- [ ] **5.6** Read-only disk image metadata extractor
- [ ] **5.7** Keep UI layout hardware-mirror-ready (per HARDWARE_FUTURE.md)

---

## Ongoing / Maintenance

- [ ] Update `PARAMETER_MAP.md` and `ParameterMap.swift` for every new verified parameter
- [ ] Add unit tests for PatchParser, CompareEngine, MacroEngine, serialization
- [ ] Store per-device or user MIDI delay profile
- [ ] Improve VirtualEncoder/value feedback for accessibility

---

## Quick reference: where things live

| Topic | Primary files |
|-------|----------------|
| MIDI I/O | `src/midi/MIDIDeviceManager.swift`, SysExSender, SysExReceiver |
| Patch model | `src/patch/VFXPatch.swift`, PatchParser, PatchSerializer, ParameterMap |
| Editor state | `src/editor/EditorState.swift`, CompareEngine, MacroEngine |
| Library | `src/librarian/LibraryDB.swift`, BankManager, TagEngine |
| UI | `src/app/MainView.swift`, `src/ui/pages/*`, `src/ui/panels/*`, `src/ui/components/*` |
| Docs | `docs/` (see DEVELOPMENT_PLAN.md “Doc Index”) |
| Captures | `sysex/` — put .syx dumps and notes here |
| Tools | `tools/vfx_sysex_inspector.py`, `tools/build_parameter_csv.py` |
