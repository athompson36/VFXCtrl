# Gotek / Floppy Workflow — Full Project Audit

**Audit pass:** project documentation + source review (update this file when repeating the audit).  
**Scope:** Documentation scan + codebase review for compatibility between the VFX-CTRL **library editor** and a **Gotek** (or USB stick) workflow using floppy images and loose SysEx files.

---

## 1. What “Gotek compatibility” means here

| Layer | Gotek / hardware reality | App role today |
|-------|---------------------------|----------------|
| **Physical / FlashFloppy** | Images often **HFE** (or indexed `.img`); shallow USB folders; short volume labels | Docs only (`VFX_SD_Context.md`); **no image I/O in code** |
| **Musical workflow** | User copies **files** the synth can load (via sequencer/OS) or uses **MIDI SysEx** from a host | **SysEx import/export** is the supported bridge |
| **Bank semantics** | VFX-SD **60 programs per internal bank**; presets/banks per manual | **Partial:** `VFXBankLimits`, export “first 60”, optional `bank.json`; live sets not hard-capped at 60 in UI |
| **Naming** | OLED ~**16 characters**; avoid huge flat lists | **Optional** ≤16 stems, numeric prefix, collision-safe names; full names still supported |

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
- **`VFXPatch`:** `id`, `name`, `category`, `notes`, `rawSysEx`, `parameters`, plus **provenance:** `sourceFileName`, `importedAt`, optional `sourceSynthOS`, `sysexSHA256` (SHA256 hex of raw SysEx).
- **On load:** legacy patches without `sysexSHA256` get the field **backfilled** from `rawSysEx` when present.
- **Still missing vs broader librarian spec:** `diskImageId` / `bankSlot`, `confidence` flags, etc.
- **`VFXBank` / `BankManager`:** `VFXBankLimits.programsPerInternalBank` (60), `BankExportManifest` + optional **`bank.json`** on live-set export; **Live Set** remains the ordered slot list (no separate bank editor UI yet).

### 3.2 Import (`LibrarySidebar` + `PatchParser`)

- **Import:** **Menu** — single file, **multi-select**, or **folder** (top-level `.syx` only). `fileImporter` uses **`VFXSysExTypes`** (`.syx` + `.data` fallback). Bulk path **skips duplicates** silently and shows a summary alert.
- **`evaluateSysExImport` / `commitImportedPatch`:** Parses with `PatchParser` or stores raw blob; sets **`sourceFileName`**, **`importedAt`**, **`sysexSHA256`**; if digest matches an existing patch (or raw bytes match), shows **duplicate alert** (Skip / Import Anyway).
- **`PatchParser`:** Header `F0 0F 05`; name extraction **heuristic**; `raw.*` nibbles not full logical model; checksum **stub**.

### 3.3 Export (`ExportHelper`, `ExportNaming`, `MainView`, `ExportLiveSetSheet`)

- **Current patch / live set → folder of `.syx`** (raw bytes). This matches a common Gotek workflow (copy folder to USB).
- **Gotek-oriented options (Live Set sheet, persisted via App Storage):**  
  - Short names (≤16 chars before `.syx`).  
  - Numeric prefix `01_` … `99_`, then `100_` … for large sets.  
  - **Collision-safe:** existing files never overwritten (`name_2.syx`, …).  
  - Optional **category subfolders** (`00_FACTORY`, `03_PAD`, …) per `VFX_SD_Context.md`.  
- **Current patch menu:** normal save, or **“Gotek ≤16 chars”** default filename (`VFXSysExTypes` on save panel).  
- **Live set export:** optional **`bank.json`** manifest (slot index, relative path, patch id/name, SHA256); toggle **export first 60 only** for one RAM bank; warning when set > 60 without truncate.

### 3.4 MIDI / SysEx (compatibility with hardware after load)

- Throttled send, live parameter map — **orthogonal** to Gotek file format but required when pushing library patches to synth.
- **Bulk bank send** from librarian not implemented as a first-class flow.

### 3.5 Tests

- `PatchParserTests`, `CompareEngineTests`, `MacroEngineTests`, `PatchProvenanceTests`, `ExportNamingTests` (includes **`bank.json`** decode) — **no** UI test for live-set cap-at-60 in the sidebar.

---

## 4. Compatibility matrix

| Requirement | Status |
|-------------|--------|
| Import single program `.syx` / SysEx blob | **Yes** |
| Persist library locally | **Yes** |
| Export patch / live set as `.syx` files | **Yes** |
| Gotek HFE / `.img` read (in app) | **No** — **manual pipeline documented** (`DISK_IMAGE_PLAN.md` Phase 2: external tool / MIDI → `.syx` → Import) |
| Gotek HFE / `.img` write | **No** (by design until format verified — see `DISK_IMAGE_PLAN.md`) |
| 60-program bank modeling & export | **Partial** (export “first 60”, manifest, `VFXBankLimits`; live set not hard-capped at 60 in UI) |
| Filename rules for FlashFloppy (short names) | **Partial** (≤16 option + numeric prefix + collision-safe) |
| Duplicate detection (hash) | **Yes** (SHA256 on import + alert; legacy library backfilled on load) |
| Source file / disk metadata | **Partial** (import filename, date, optional `sourceSynthOS`; no disk image ID yet) |
| Bulk multi-file import | **Yes** (multi-select + folder, duplicate skip + summary) |
| Align export folder layout with `VFX_SD_Context.md` | **Partial** (optional category subfolders) |
| `.syx` UTType in import/export panels | **Yes** (`VFXSysExTypes` + `.data` fallback) |

---

## 5. Recommended priority order (for TODO)

1. ~~**Metadata + import provenance**~~ — **Done (Phase 6.1–6.2):** `VFXPatch` fields + `evaluateSysExImport` / duplicate alert; **remaining:** disk image / bank-slot IDs if desired.
2. ~~**Export options for Gotek**~~ — **Largely done (6.3–6.4):** `ExportNaming` + Live Set toggles + single-patch Gotek menu item. **Remaining:** OLED-length presets beyond 16 if needed, export manifest.
3. ~~**Bank (60) modeling**~~ — **Partially done:** live-set export + **first 60** + **`bank.json`**; optional: hard-cap live sets at 60 in UI, dedicated bank editor.
4. ~~**Multi-select SysEx import**~~ — **Done** (multi file + folder, duplicate skip summary).
5. **Disk image Phase 2** — **Doc done:** manual `.img`→`.syx` pipeline in `DISK_IMAGE_PLAN.md` + **README** (HFE/FlashFloppy). **Code:** read-only extractor still **TBD** after verified layout.
6. ~~**UTType**~~ — **Done** (`VFXSysExTypes` for importers + save panel).

---

## 6. References

- `docs/DISK_IMAGE_PLAN.md`
- `docs/VFX_CAPABILITY_AUDIT.md` (UI vs `ParameterMap`)
- `docs/VFX_SD_Context.md`
- `docs/CURSOR_CONTEXT.md` (Librarian Design Requirements)
- `docs/VFX_SD_GOTEK_CATALOG.csv`
