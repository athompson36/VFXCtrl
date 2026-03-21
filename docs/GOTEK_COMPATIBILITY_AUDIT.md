# Gotek / Floppy Workflow — Full Project Audit

**Audit pass:** project documentation + source review (update this file when repeating the audit).  
**Scope:** Documentation scan + codebase review for compatibility between the VFX-CTRL **library editor** and a **Gotek** (or USB stick) workflow using floppy images and loose SysEx files.

---

## 1. What “Gotek compatibility” means here

| Layer | Gotek / hardware reality | App role today |
|-------|---------------------------|----------------|
| **Physical / FlashFloppy** | Images often **HFE** (or indexed `.img`); shallow USB folders; short volume labels | Docs only (`VFX_SD_Context.md`); **no image I/O in code** |
| **Musical workflow** | User copies **files** the synth can load (via sequencer/OS) or uses **MIDI SysEx** from a host | **SysEx import/export** is the supported bridge |
| **Bank semantics** | VFX-SD **60 programs per internal bank**; presets/banks per manual | **Not enforced** in export or library model |
| **Naming** | OLED ~**16 characters**; avoid huge flat lists | Export uses full sanitized names; **no length cap** for Gotek display |

So: the app is **compatible with a Gotek-assisted workflow** only in the sense of **producing/consuming `.syx` (raw SysEx) files** that you place on USB or send over MIDI. It is **not** yet compatible with **native floppy image formats** (HFE/RAW Ensoniq layout) for read/write.

---

## 2. Documentation inventory (relevant excerpts)

| Document | Gotek / disk relevance |
|----------|-------------------------|
| `docs/VFX_SD_Context.md` | HFE recommended; folder layout (`00_FACTORY` …); 60-patch banks; duplicate hash; LIVE_SET; **disk source metadata** — *requirements, partially unimplemented* |
| `docs/DISK_IMAGE_PLAN.md` | Phases: SysEx only → read-only image metadata → validated write; **Phase 2+ not implemented** |
| `docs/CURSOR_CONTEXT.md` | Librarian must import `.syx`, bulk dumps, preserve metadata, tags, **duplicate detection**, **source disk metadata** |
| `docs/VFX_PROJECT_SPEC.md` | Export for Gotek workflows; **no arbitrary floppy image writes** |
| `docs/VFX_SD_GOTEK_CATALOG.csv` | Catalog of backup `.img` sources; **reference only**, not parsed by app |
| `docs/DEVELOPMENT_PLAN.md` / `ROADMAP.md` | Gotek/export/disk items tracked at high level |
| `TODO.md` | 5.5 export marked done; 5.6 disk extractor “when format confirmed” |

**Gap:** Requirements in `CURSOR_CONTEXT.md` / `VFX_SD_Context.md` exceed current `VFXPatch` + `LibraryDB` fields and UI.

---

## 3. Codebase audit

### 3.1 Library & persistence (`LibraryDB`, `VFXPatch`)

- **Storage:** `~/Library/Application Support/VFXCtrl/library.json` (+ favorites, live_sets).
- **`VFXPatch`:** `id`, `name`, `category`, `notes`, `rawSysEx`, `parameters`.
- **Missing vs Gotek/librarian spec:**  
  - `sourceFileName`, `importedAt`, `sourceSynthOS`, `sysexHash` (duplicate detection), `diskImageId` / `bankSlot`, `confidence` flags.
- **`VFXBank` / `BankManager`:** Struct exists; **not wired** into `LibraryDB` or sidebar — no 60-slot bank editor.

### 3.2 Import (`LibrarySidebar` + `PatchParser`)

- **Single file** import via `fileImporter` with `UTType.data` (not a dedicated `.syx` type — may be OK on macOS but **less discoverable**).
- **`importSysEx`:** Parses with `PatchParser` or stores raw blob; **does not record original filename** from picker.
- **`PatchParser`:** Header `F0 0F 05`; name extraction **heuristic**; `raw.*` nibbles not full logical model; checksum **stub**.

### 3.3 Export (`ExportHelper`, `MainView`, `ExportLiveSetSheet`)

- **Current patch / live set → folder of `.syx`** (raw bytes). This matches a common Gotek workflow (copy folder to USB).
- **Risks for Gotek UX:**  
  - Long filenames / special characters (partially sanitized).  
  - **No 16-char alias** for OLED.  
  - **No collision handling** (two patches same name → second overwrite in `exportPatches`).  
  - **No “max 60 per export”** or bank ordering metadata.

### 3.4 MIDI / SysEx (compatibility with hardware after load)

- Throttled send, live parameter map — **orthogonal** to Gotek file format but required when pushing library patches to synth.
- **Bulk bank send** from librarian not implemented as a first-class flow.

### 3.5 Tests

- `PatchParserTests`, `CompareEngineTests`, `MacroEngineTests` — **no** tests for export naming, bank size, or metadata.

---

## 4. Compatibility matrix

| Requirement | Status |
|-------------|--------|
| Import single program `.syx` / SysEx blob | **Yes** |
| Persist library locally | **Yes** |
| Export patch / live set as `.syx` files | **Yes** |
| Gotek HFE / `.img` read | **No** |
| Gotek HFE / `.img` write | **No** (by design until format verified — see `DISK_IMAGE_PLAN.md`) |
| 60-program bank modeling & export | **No** |
| Filename rules for FlashFloppy (short names) | **No** |
| Duplicate detection (hash) | **No** |
| Source file / disk metadata | **No** |
| Bulk multi-file import | **No** |
| Align export folder layout with `VFX_SD_Context.md` | **No** |

---

## 5. Recommended priority order (for TODO)

1. **Metadata + import provenance** — store original filename, import date, optional notes; compute **SHA256 of `rawSysEx`** for duplicate warnings.
2. **Export options for Gotek** — optional max filename length, numeric prefix (`01_…`), collision-safe names, optional category subfolders matching doc layout.
3. **Bank (60) modeling** — `VFXBank` or live-set type = ordered list ≤ 60 with validation; export “bank folder” manifest.
4. **Multi-select SysEx import** — folder or multiple files.
5. **Disk image Phase 2** — external format research + read-only extractor (or link to trusted tool); document image→SysEx pipeline.
6. **UTType** — declare/import `.syx` where appropriate for macOS 11+.

---

## 6. References

- `docs/DISK_IMAGE_PLAN.md`
- `docs/VFX_SD_Context.md`
- `docs/CURSOR_CONTEXT.md` (Librarian Design Requirements)
- `docs/VFX_SD_GOTEK_CATALOG.csv`
