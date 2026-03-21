# Support & feedback (template)

Fill this in when you publish builds.

| | |
|--|--|
| **Project** | VFX-CTRL — macOS editor/librarian for Ensoniq VFX-SD |
| **Issue tracker** | *(e.g. GitHub Issues URL)* |
| **Contact** | *(email or forum)* |
| **Docs** | [`README.md`](../README.md), [`ROADMAP.md`](./ROADMAP.md), [`GOTEK_COMPATIBILITY_AUDIT.md`](./GOTEK_COMPATIBILITY_AUDIT.md) |

## What to include in a bug report

- macOS version, Mac model (Apple Silicon / Intel)
- MIDI interface and whether SysEx is enabled on the VFX-SD
- VFX-SD OS version if known (`sysex/notes.md` style)
- Steps to reproduce; attach `.syx` only if non-private
- Relevant lines from **SysEx Log** (with delay setting)

## Known limitations (typical)

- Program dump **checksum** not validated until algorithm is confirmed.
- **Tap tempo** SysEx virtual button number TBD on hardware.
- **Disk / HFE** image I/O not implemented; use `.syx` import/export.
