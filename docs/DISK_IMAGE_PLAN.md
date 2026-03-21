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
**In-app read-only extractor:** *not implemented yet.* Blocked on a **verified** Ensoniq VFX-SD (or family) sector/track layout for the specific `.img` / raw dumps you use.

Until then, use the **manual pipeline** below and keep importing **loose `.syx`** (supported today).

#### Manual pipeline: disk image → patches in VFX-CTRL

1. **Obtain a raw image** (e.g. `.img` from backup hardware, archives, or conversion from HFE via external tools — see README *Gotek / HFE*).
2. **Extract or convert to SysEx** using a path appropriate to your image source:
   - Trusted **external** tools / scripts that understand Ensoniq floppy layout (document the tool name and version in `sysex/notes.md` when you establish a workflow).
   - **MIDI bulk dump** from the synth (when available) remains the gold standard for byte-accurate program data.
3. **Import** the resulting `.syx` files via **Library → Import** (single, multi, or folder).

When Phase 2 lands in code, targets will include:

- List “files” or logical objects on a verified layout
- Optional metadata sidecar (names, bank/slot hints) without claiming full filesystem semantics until validated
- Still **no write** until Phase 3

### Phase 3
Curated export pipeline.
- assemble bank sets
- validate layout
- write disk artifacts only after format verification
- **HFE or raw image writer** only after layout checks match real hardware (see README)

## Notes
Public Ensoniq floppy format references exist, but this starter does not claim a finished VFX-SD disk writer yet. **Do not assume** all `.img` files in the wild share one layout — verify against your OS version and capture source.
