# Disk Image / Gotek Plan

See also: **[GOTEK_COMPATIBILITY_AUDIT.md](./GOTEK_COMPATIBILITY_AUDIT.md)** for a full documentation + code audit and gap matrix.

## Goals

- import existing SysEx collections and bank files
- later support disk-image inspection and export
- avoid destructive write assumptions early

## Phase plan

### Phase 1
SysEx only.

### Phase 2
Read-only disk-image metadata extractor (to be implemented when format is confirmed).
- List files on disk image
- Identify names/types from Ensoniq floppy layout
- Map banks/program files if format is understood
- No write support; import into library via SysEx only for now

### Phase 3
Curated export pipeline.
- assemble bank sets
- validate layout
- write disk artifacts only after format verification

## Notes
Public Ensoniq floppy format references exist, but this starter does not claim a finished VFX-SD disk writer yet.
