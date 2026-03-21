# Hardware regression matrix (template)

Fill this in as you run **Phase 0** and **Phase 7** checks. Store synth OS version and interface details in `sysex/notes.md` as well.

| Date | macOS | Xcode | MIDI interface | VFX-SD OS | Request patch | Send patch | Live edit (sample) | Notes |
|------|-------|-------|----------------|-----------|---------------|------------|--------------------|-------|
| | | | | | ☐ | ☐ | ☐ | |

## Live edit spot-check (minimum)

| Tab | Parameter (key) | Expected on synth | Pass |
|-----|-------------------|-------------------|------|
| Wave | `wave.select` | | ☐ |
| Filter | `filter.cutoff` | | ☐ |
| Amp | `env1.attack` | | ☐ |
| System | `sys.sysexRx` | | ☐ |

Add rows until comfortable for your release bar.

## References

- [`TODO.md`](../TODO.md) Phase 0 / Phase 7  
- [`PRODUCTION_CHECKLIST.md`](./PRODUCTION_CHECKLIST.md)  
- [`LIVE_COVERAGE_AUDIT.md`](./LIVE_COVERAGE_AUDIT.md) (map vs live builder gaps)
