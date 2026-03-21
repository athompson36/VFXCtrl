# Production checklist (VFX-CTRL 1.0)

Use this with [`TODO.md`](../TODO.md) Phase 7 and [`docs/ROADMAP.md`](./ROADMAP.md). Check items off as you complete them; add dates and owner in git history.

---

## 1. Hardware truth

- [ ] Baseline program dump(s) in `sysex/` per `sysex/notes.md`
- [ ] Synth OS version recorded; quirks logged
- [ ] MIDI interface(s) tested; SysEx receive without drops at default delay
- [ ] **Live edit matrix:** for each editor tab, spot-check parameters on hardware (document pass/fail in `PARAMETER_MAP.md` or a small `docs/HARDWARE_QA.md`)
- [ ] Request-current-program and send-program flows verified against spec
- [ ] Sequencer transport (play/stop/record virtual buttons) verified or marked experimental in UI

---

## 2. Data integrity

- [ ] Checksum: implement per `VFX_SYSEX_SPEC.md` **or** ship with explicit “checksum not validated” in UI + docs *(integrity note on parsed patches + Patch list — done)*
- [ ] Golden-file test: known `.syx` → parse → serialize → compare (allowing documented normalization)
- [ ] Audit: run `python3 tools/audit_live_coverage.py` → [`LIVE_COVERAGE_AUDIT.md`](./LIVE_COVERAGE_AUDIT.md); CI `LiveCoverageTests` for live keys ⊆ `ParameterMap`

---

## 3. Quality & stability

- [x] `swift test` in CI — [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) *(toggle checklist if you use another host)*
- [ ] Stress: import folder with 200+ files; library save/load; export 60-slot live set *(see `ExportNamingTests.testWritePatches_sixtyPatches_numericPrefix_noOverwrite` for 60-file export uniqueness)*
- [ ] Memory / UI: scroll large patch list; rapid live tweaking without blocking main thread
- [ ] No critical force-quit paths on common errors (bad file, MIDI disconnected mid-send)

---

## 4. Release engineering (macOS)

- [ ] Xcode archive scheme; Debug vs Release configuration documented
- [ ] App icon, bundle ID, version (`CFBundleShortVersionString` / `CFBundleVersion`) policy
- [ ] Hardened Runtime + minimum OS aligned with `Package.swift` / README
- [ ] Code signing (Developer ID Application)
- [ ] Notarization + stapling (or documented manual steps)
- [ ] Entitlements review (network if any, MIDI/USB as needed)

---

## 5. User-facing deliverables

- [ ] README: install, first launch, MIDI device selection, Live toggle, import/export
- [ ] Gotek workflow: link to `GOTEK_COMPATIBILITY_AUDIT.md` + short “how to export”
- [ ] Known limitations: disk images, unverified params, sequencer scope
- [ ] License / third-party notices if applicable
- [ ] Support / feedback channel (email, issue tracker, etc.)

---

## 6. Optional before 1.0

- [ ] Sparkle or other update channel
- [ ] Minimal analytics/crash reporting (with privacy disclosure) or explicit “none”
- [ ] Localized strings (if targeting non–English-speaking users)

---

## Sign-off

| Role | Name | Date |
|------|------|------|
| Build / signing | | |
| Hardware QA | | |
| Docs | | |
