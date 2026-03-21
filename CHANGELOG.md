# Changelog

All notable changes to **VFX-CTRL** are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- `docs/PHASE5_SEQUENCER_FX.md` — sequencer/FX verification checklist vs code.
- Parser → serializer round-trip unit test for minimal program dumps.
- CI workflow (`.github/workflows/ci.yml`) running `swift test`.
- Live coverage audit script (`tools/audit_live_coverage.py`) and `docs/LIVE_COVERAGE_AUDIT.md`.
- `docs/RELEASE.md`, `docs/SUPPORT.md`, `docs/HARDWARE_REGRESSION_MATRIX.md`, `docs/PRODUCTION_CHECKLIST.md`.
- `VFXPatch.importIntegrityNote` for checksum disclosure until algorithm is implemented.
- `PatchSerializer` tests; bulk export uniqueness test (60 patches).

### Changed
- **Send** uses `PatchSerializer` and shows a transport notice if there is no program SysEx to send.
- Map-driven editor UI; `LabeledParameterCell` enum layout (single green parameter label + menu).
- SysEx send queue uses `OSAllocatedUnfairLock` instead of `NSLock` in async send loop.
- System page `sys.pitchTable` picker aligned to hardware range 0…1.

### Fixed
- Transport “Request Patch” wired to `requestCurrentProgram()` with timeout feedback.

---

## Versioning (planned)

Until a signed 1.0 app ships from Xcode, **Swift Package** / git tags can use `0.x.y`:

- **0.y.z** — pre-release; increment **z** for fixes, **y** for features.
- After notarized distribution: **1.0.0** per semantic versioning for the `.app` bundle (`CFBundleShortVersionString` / `CFBundleVersion`).

Record release dates and highlights in this file when you tag.
