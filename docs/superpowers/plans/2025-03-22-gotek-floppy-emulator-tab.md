# Gotek / Floppy Emulator Tab — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a dedicated **Floppy Emulator** area to VFX-CTRL that unifies Gotek-oriented workflows with the existing librarian, and supports **FlashFloppy firmware maintenance** (USB-stick `.upd` updates as the primary path; DFU “full reflash” as an optional advanced path).

**Architecture:** Introduce a **top-level mode switch** (tab or sidebar segment) so the current synth editor + library split remains unchanged in “Synth” mode, while “Floppy Emulator” mode hosts Gotek documentation, library-driven export to a **user-chosen USB volume**, optional catalog-driven organization hints, and a **firmware assistant** that downloads official FlashFloppy release artifacts and stages them on the stick per upstream docs. Heavy lifting for `.syx` stays in `ExportHelper` / `ExportNaming` / `LibraryDB`; new modules own release download, `.upd` staging, and DFU command generation.

**Tech Stack:** SwiftUI, `Foundation` (`URLSession`, `Process` if needed), AppKit panels (`NSOpenPanel` / `NSSavePanel` patterns already in `ExportHelper`), GitHub REST API (`GET /repos/keirf/flashfloppy/releases/latest` or tagged release). Optional: ZIP unzip via `Foundation` (`FileManager` + `Process` and `/usr/bin/unzip`) or Swift ZIP library if you avoid shelling out.

---

## 0. Repository reality check (scan results)

- **There is no `gotek/` folder** in this workspace. Gotek-related material is:
  - **Docs:** `docs/GOTEK_COMPATIBILITY_AUDIT.md`, `docs/DISK_IMAGE_PLAN.md`, `docs/VFX_SD_Context.md`, `docs/VFX_SD_GOTEK_CATALOG.csv`, `README.md` (Gotek / HFE section).
  - **Code:** `ExportHelper`, `ExportNaming`, `ExportLiveSetSheet`, `MainView` (export menu), `LibrarySidebar` (import), `LibraryDB`, `BankManager` / `BankExportManifest`, `SysExFolderPicker` (shallow folder listing).
- **App shell:** `VFXCtrlApp` → `MainView` → `NavigationSplitView(LibrarySidebar | PatchListView | editor detail)`. Editor sub-pages are `EditorPage` (Wave…System), not separate product tabs.
- **HFE / raw disk I/O:** Explicitly **out of scope** for this feature unless you extend `DISK_IMAGE_PLAN.md` Phase 2; the audit still applies.

---

## 1. FlashFloppy / Gotek — research summary (for product decisions)

### 1.1 Firmware update when FlashFloppy is already installed (recommended in-app path)

Per [FlashFloppy Firmware Update](https://github.com/keirf/FlashFloppy/wiki/Firmware-Update):

- Use **exactly one** `.upd` file on the **root** of a FAT-formatted USB stick (multiple files → **E02**).
- Remove old `.upd` files before copying a new one.
- Two families of update files:
  - **`FF_Gotek-*.upd`** — legacy, STM32F105 / AT32F415.
  - **`flashfloppy-*.upd`** — universal for AT32F435; also STM32F105/AT32F415 **with recent bootloader**.
- User can copy **both** types if unsure; bootloader picks the compatible one. If **E01**, try the other type.
- Procedure: insert USB into Gotek, **power on with both buttons pressed** (or Select / rotary per hardware), display shows **UPD** / **FF Update Flash**, release buttons, wait for reboot.
- **Bootloader** updates use files under `alt/bootloader/` in the release ZIP — same mechanics, with extra caution (failed bootloader update may require full reflash).

**Implication for the app:** The highest-value “upgrade firmware” feature is a **guided USB staging** flow: download release ZIP → extract the right `.upd` (or both) → user selects **the USB stick’s mount point** → app deletes `*.upd` in root → copies new file(s) → shows the hardware steps.

### 1.2 Initial programming / “bricked” recovery (optional, advanced)

Per [FlashFloppy Firmware Programming](https://github.com/keirf/FlashFloppy/wiki/Firmware-Programming):

- **STM32 USB:** jumper wiring on programming header, USB-A–to–A (or via hub), **`dfu-util`** on Linux/macOS. May need `:unprotect:force` then flash `.dfu` from release `dfu/` folder. Wiki notes **macOS DFU connection issues** (sometimes fixed via **external USB hub**).
- **Artery MCUs:** vendor ISP tool (Windows-centric in wiki); different file types (`.hex`).
- **Serial:** `stm32flash` on Linux example in wiki.

**Implication for the app:** Treat DFU as **“Advanced”**: generate or display exact commands, link to wiki, optionally run `dfu-util` via `Process` **if** the user has it installed (Homebrew) and grants permissions — do **not** assume this works on all Macs without documentation. Bundling `dfu-util` is possible but adds signing, architecture (arm64/x64), and support burden.

### 1.3 Licensing / redistribution

FlashFloppy is open source ([keirf/flashfloppy](https://github.com/keirf/flashfloppy)). If the app **ships** firmware binaries, comply with the project’s license (typically GPL-3.0 for FF) — include **copyright notice**, offer **source** or link, and document versions. Prefer **downloading from GitHub at runtime** to avoid shipping blobs unless legal review says otherwise.

### 1.4 Library / disk workflow (existing app)

Already aligned for **loose `.syx` on USB**: short names, numeric prefixes, category folders, `bank.json`, 60-slot awareness (`GOTEK_COMPATIBILITY_AUDIT.md`). The new tab should **surface and orchestrate** these flows instead of duplicating logic.

---

## 2. UX / navigation design

### 2.1 Where the “tab” lives

**Recommendation:** Add a **root-level picker** above or beside the split view, e.g. `Picker` with `Synth` vs `Floppy Emulator`, backed by `@State` or a tiny `AppMode` observable:

- **Synth:** current `MainView` body unchanged.
- **Floppy Emulator:** new `FloppyEmulatorView` (multi-section layout: Workflow, Library export, Firmware, Reference).

**Alternatives (document tradeoffs):**

- New `EditorPage` case — **avoid**; conflates synth parameter pages with hardware workflow.
- Separate `WindowGroup` — valid for power users; optional phase 2.

### 2.2 Floppy Emulator page sections (suggested)

1. **Quick actions (library-linked)**  
   - Export **current patch** (reuse `exportCurrentPatch` options).  
   - Export **live set** (present `ExportLiveSetSheet` or navigate to a compact duplicate with same `LibraryDB` binding).  
   - **Import** shortcut (same as Library → Import; can deep-link to sidebar focus in a later iteration).

2. **USB layout checklist**  
   - Condensed bullets from `VFX_SD_Context.md` (shallow folders, ~16-char names, optional category roots). Link “full detail” to docs in repo or bundled copy.

3. **Firmware**  
   - “Update FlashFloppy (USB `.upd`)” wizard.  
   - “Bootloader update” sub-wizard (strong warnings + link to wiki).  
   - “Advanced: DFU / initial programming” collapsible with commands + external links.

4. **Disk catalog (optional)**  
   - Parse `docs/VFX_SD_GOTEK_CATALOG.csv` (read-only resource) into a searchable table: disk name, category, compatibility — helps users **name** USB folders or live sets; does not import patches by itself.

---

## 3. File / module map (planned)

| Area | Create | Modify |
|------|--------|--------|
| Root mode switch | `src/app/AppMode.swift` (enum + `ObservableObject` if shared) | `VFXCtrlApp.swift`, new wrapper view e.g. `RootContainerView.swift` |
| Floppy UI | `src/ui/panels/FloppyEmulatorView.swift`, subviews as needed (`FirmwareUpdateWizardView.swift`, `GotekWorkflowTipsView.swift`) | — |
| GitHub / ZIP | `src/gotek/FlashFloppyReleaseService.swift` (fetch latest, parse assets, download ZIP to cache dir) | — |
| USB staging | `src/gotek/UpdStagingService.swift` (enumerate/delete `*.upd` in root, copy selected `.upd`) | — |
| Catalog | `src/gotek/GotekDiskCatalog.swift` (parse bundled CSV) | Add CSV to app bundle resources in Xcode if not only loaded from disk |
| Tests | `Tests/.../FlashFloppyReleaseServiceTests.swift` (mock `URLProtocol` or inject session) | — |
| Docs | Update `GOTEK_COMPATIBILITY_AUDIT.md` matrix when features ship | — |

*(Adjust paths to match your Xcode group structure; a real `src/gotek/` package is appropriate now.)*

---

## 4. Tasks (bite-sized)

### Task 1: App mode shell

**Files:**

- Create: `src/app/RootContainerView.swift`
- Modify: `VFXCtrlApp.swift` (use `RootContainerView` instead of raw `MainView`)
- Modify: `src/app/MainView.swift` only if you need to extract the split view for clarity (optional)

- [ ] **Step 1:** Add `enum AppWorkspace { case synth, floppy }` and `@State private var workspace` in `RootContainerView`.
- [ ] **Step 2:** `Picker("Workspace", selection: $workspace) { Text("Synth"); Text("Floppy Emulator") }` above `MainView` / `FloppyEmulatorView`.
- [ ] **Step 3:** Verify existing synth UI is pixel-unchanged when `synth` selected.

**Manual test:** Launch app, flip workspace, return to synth — library and editor still work.

---

### Task 2: Floppy Emulator shell UI

**Files:**

- Create: `src/ui/panels/FloppyEmulatorView.swift`

- [ ] **Step 1:** Build scrollable `VStack` with sections and `VFXTheme` styling consistent with `ExportLiveSetSheet`.
- [ ] **Step 2:** Wire buttons: “Export current patch…” / “Export live set…” calling existing `ExportHelper` / sheet presentation (pass `@EnvironmentObject var library` / `editor`).
- [ ] **Step 3:** Empty placeholder for firmware wizard (next task).

**Manual test:** From Floppy tab, export a patch and a live set; files appear on disk as today.

---

### Task 3: FlashFloppy release download (latest stable)

**Files:**

- Create: `src/gotek/FlashFloppyReleaseService.swift`
- Test: `Tests/.../FlashFloppyReleaseServiceTests.swift`

- [ ] **Step 1:** Implement `fetchLatestRelease()` using `URLSession` → `https://api.github.com/repos/keirf/flashfloppy/releases/latest` (set `Accept: application/vnd.github+json`, optional `User-Agent` per GitHub API etiquette).
- [ ] **Step 2:** Parse JSON for `tag_name` and `assets` → find `browser_download_url` for `flashfloppy-*.zip` (regex or suffix match).
- [ ] **Step 3:** Download ZIP to `FileManager.default.urls(for: .cachesDirectory, ...)/VFXCtrl/flashfloppy/...` with version in filename.
- [ ] **Step 4:** Unit test with mocked HTTP response (fixture JSON + fake ZIP optional).

**Note:** Handle API rate limits and offline errors with user-visible messages.

---

### Task 4: ZIP extraction and `.upd` discovery

**Files:**

- Modify: `src/gotek/FlashFloppyReleaseService.swift` or add `FlashFloppyArtifactExtractor.swift`

- [ ] **Step 1:** Unzip to a versioned subdirectory (shell `unzip` or Swift-native).
- [ ] **Step 2:** Locate `flashfloppy-*.upd`, `FF_Gotek-*.upd`, and optional `alt/bootloader/*.upd`.
- [ ] **Step 3:** Return structured `UpdCandidate` list (name, path, kind: main / legacy / bootloader).

**Manual test:** Download real 3.x release, confirm files found on disk.

---

### Task 5: USB root picker + `.upd` staging

**Files:**

- Create: `src/gotek/UpdStagingService.swift`
- Modify: `FloppyEmulatorView.swift` (wizard UI)

- [ ] **Step 1:** `NSOpenPanel` — `canChooseDirectories = true`, `canChooseFiles = false`, prompt “Choose USB stick root”.
- [ ] **Step 2:** List `*.upd` in **root only** (not recursive); show user what will be deleted.
- [ ] **Step 3:** On confirm, delete existing `*.upd` in root, copy selected new `.upd` (user toggle: include both main types, default on).
- [ ] **Step 4:** Show post-copy checklist (power + buttons, E01–E05 meanings from wiki).

**Safety:** Require explicit confirmation before deleting anything; optionally dry-run preview.

---

### Task 6: Firmware wizard UX polish

**Files:**

- Create: `src/ui/panels/FirmwareUpdateWizardView.swift`

- [ ] **Step 1:** Stepper UI: Choose version (latest default) → Download → Select USB → Stage → Done.
- [ ] **Step 2:** Sub-flow for bootloader update with **prominent** risk text and link to [Firmware Update](https://github.com/keirf/FlashFloppy/wiki/Firmware-Update).
- [ ] **Step 3:** “Advanced: DFU” section — static text + `TextField` read-only with `dfu-util` example from wiki; “Copy command” button.

---

### Task 7: Optional — Gotek disk catalog browser

**Files:**

- Create: `src/gotek/GotekDiskCatalog.swift`
- Add: bundle `VFX_SD_GOTEK_CATALOG.csv` copy under `Resources/` (or load from `docs/` in debug only — release should bundle)
- Modify: `FloppyEmulatorView.swift`

- [ ] **Step 1:** Parse CSV rows (disk number, name, category, compatibility).
- [ ] **Step 2:** `Table` or `List` with search; tap row copies suggested **short folder name** to pasteboard.

---

### Task 8: Documentation + audit matrix

**Files:**

- Modify: `docs/GOTEK_COMPATIBILITY_AUDIT.md`

- [ ] **Step 1:** Add rows for “In-app `.upd` staging”, “Release download helper”, “Catalog browser (if implemented)”.
- [ ] **Step 2:** Cross-link from `README.md` Gotek section to the new tab (one sentence).

---

## 5. Non-goals (for this plan)

- Writing **HFE** or Ensoniq **raw disk images** in-app (`DISK_IMAGE_PLAN.md` Phase 3).
- Auto-detecting Gotek hardware over USB from macOS (no standard MIDI identity for Gotek).
- Replacing official FlashFloppy docs — always link out for recovery edge cases.

---

## 6. Risks & mitigations

| Risk | Mitigation |
|------|------------|
| User selects wrong volume in open panel | Strong copy + show volume name; optional “only removable” heuristic is fragile on Mac — prefer clear labeling |
| E02 / multiple `.upd` | Enforce single-file mode when user picks one variant; if “both types”, document that FF allows both **types** but not duplicates of same type |
| GitHub API / network | Cached ZIP + retry; offline message |
| GPL / binary distribution | Prefer runtime download; attribute Keir Fraser / FlashFloppy |
| DFU on macOS | Document hub workaround; don’t promise one-click success |

---

## 7. Verification commands (before claiming done)

- Build: your usual `xcodebuild` scheme (project-specific).
- Tests: run unit tests for `FlashFloppyReleaseService` with mocks.
- Manual: full wizard with a **test USB stick** (FAT32), verify single `.upd` at root; **then** test on real Gotek when available.

---

**Plan complete.** Two execution options:

1. **Subagent-driven (recommended)** — fresh subagent per task with review between tasks (`superpowers:subagent-driven-development`).
2. **Inline execution** — batch tasks in this session with checkpoints (`superpowers:executing-plans`).

Which approach do you want for implementation?
