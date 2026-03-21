# Live vs ParameterMap audit

**Regenerate:** `python3 tools/audit_live_coverage.py > docs/LIVE_COVERAGE_AUDIT.md`  
**CI:** `LiveCoverageTests` ensures `supportedLiveKeys` ⊆ `ParameterMap` (except `seq.play` / `seq.stop` / `seq.record`).

**Last full pass:** hardware-page map keys are all present in `LiveSysExBuilder` (system/MIDI gaps closed 2026-03).

---

- Parameter map keys (total): **203**
- Keys in `parameterAddressTable` + CC + virtual: **146**
- Map keys with sysexPage < 997 (intended hardware): **135**

## In ParameterMap (hardware page) but not in live builder

_None._

## In live builder but not in ParameterMap

- `seq.play`
- `seq.record`
- `seq.stop`

## Notes

- Rows with sysexPage **998** / **999** / **997** are UI, macro, or legacy aliases — they are excluded from the “hardware” bucket above.
- Add missing live rows to `LiveSysExBuilder.parameterAddressTable` or bump sysexPage to **998** with a note if intentionally patch-only.

