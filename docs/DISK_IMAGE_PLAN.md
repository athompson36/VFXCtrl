# Disk Image / Gotek Plan

## Goals

- import existing SysEx collections and bank files
- later support disk-image inspection and export
- avoid destructive write assumptions early

## Phase plan

### Phase 1
SysEx only.

### Phase 2
Read-only disk-image metadata extractor.
- list files
- identify names/types
- map banks/program files if format is understood

### Phase 3
Curated export pipeline.
- assemble bank sets
- validate layout
- write disk artifacts only after format verification

## Notes
Public Ensoniq floppy format references exist, but this starter does not claim a finished VFX-SD disk writer yet.
