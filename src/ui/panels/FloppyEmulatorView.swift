import AppKit
import SwiftUI
import UniformTypeIdentifiers

private let floppyFFCfgDefaultsKey = "VFXCtrl.floppyFFCfgDraft"
private let floppyGotekFamilyKey = "VFXCtrl.floppyGotekFamilyId"
private let floppyEnsoniqHostKey = "VFXCtrl.floppyEnsoniqHostId"
private let floppyReplaceHostKeysKey = "VFXCtrl.floppyReplaceHostKeysWhenMerging"

/// Gotek / FlashFloppy workflows and library export entry points.
struct FloppyEmulatorView: View {
    @EnvironmentObject private var editor: EditorState
    @EnvironmentObject private var library: LibraryDB

    @State private var showUSBExportSheet = false
    @State private var ffCfgDraft = ""
    @State private var showCatalogForFriendlyRenameScript = false
    @State private var renameScriptMessage: String?
    @State private var showImportSingle = false
    @State private var showImportMulti = false
    @State private var duplicateIncoming: VFXPatch?
    @State private var duplicateExisting: VFXPatch?
    @State private var bulkSummary: BulkSysExImportSummary?
    @State private var showBulkSummary = false

    @State private var catalogSearch = ""
    @State private var selectedGotekFamilyId = GotekUnitFamily.all.first?.id ?? "classic_3digit"
    @State private var selectedEnsoniqHostId = "vfx_sd_sd1"
    @State private var replaceHostKeysWhenMerging = false
    @State private var rackFolderPathCache = ""
    @State private var rackDeployError: String?
    @State private var rackDeployMessage: String?
    private var catalogEntries: [GotekDiskCatalogEntry] {
        let all = GotekDiskCatalog.loadFromBundle()
        let q = catalogSearch.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return all }
        return all.filter { e in
            e.diskName.lowercased().contains(q)
                || e.soundCategory.lowercased().contains(q)
                || e.compatibility.lowercased().contains(q)
                || e.notes.lowercased().contains(q)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Floppy Emulator")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(VFXTheme.vfdGreen)

                Text("Prepare USB media for a Gotek running FlashFloppy: short names, shallow folders, and .syx exports from your library.")
                    .font(.subheadline)
                    .foregroundStyle(VFXTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                gotekHardwareSetupSection

                sectionTitle("Library")
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Button("Export current patch…") { exportCurrentPatch(gotekShortName: false) }
                            .disabled(editor.currentPatch.rawSysEx == nil)
                        Button("Export (Gotek ≤16 chars)…") { exportCurrentPatch(gotekShortName: true) }
                            .disabled(editor.currentPatch.rawSysEx == nil)
                    }
                    Button("Export to USB / SD (indexed + FF.CFG)…") { showUSBExportSheet = true }
                        .disabled(library.liveSets.isEmpty && library.patches.isEmpty)

                    Menu("Import SysEx") {
                        Button("Single file…") { showImportSingle = true }
                        Button("Multiple files…") { showImportMulti = true }
                        Button("Folder (top-level .syx)…") { runFolderImport() }
                    }
                }
                .font(.callout)

                sectionTitle("Indexed disk rack (HFE / IMG)")
                Text(
                    "Choose the folder that contains your **indexed rack** at its root (for example `gotek/ensoniq-vfx-sd/VFX-RACK-BUILD-FF344`). Copy to SD/USB writes **only** `0000_*.HFE` / `0000_*.IMG` … and `FF.CFG`. Does **not** copy `IMG.CFG`, `IMAGE_A.CFG`, catalogs, README, `.upd`, or macOS metadata (`._*`)."
                )
                .font(.caption)
                .foregroundStyle(VFXTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

                Text(rackFolderPathCache.isEmpty ? "No rack folder selected." : rackFolderPathCache)
                    .font(.caption.monospaced())
                    .foregroundStyle(VFXTheme.textSecondary)
                    .lineLimit(4)
                    .textSelection(.enabled)

                HStack(spacing: 12) {
                    Button("Choose rack folder…") { chooseIndexedRackFolder() }
                    Button("Show in Finder") { revealIndexedRackFolder() }
                        .disabled(GotekIndexedRackDeploy.FolderPreferences.savedFolderURL() == nil)
                    Button("Copy deployables to SD/USB…") { copyRackDeployablesToUSB() }
                        .disabled(GotekIndexedRackDeploy.FolderPreferences.savedFolderURL() == nil)
                }
                .font(.callout)

                if let e = rackDeployError {
                    Text(e)
                        .font(.caption)
                        .foregroundStyle(VFXTheme.vfdAmber)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let m = rackDeployMessage {
                    Text(m)
                        .font(.caption)
                        .foregroundStyle(VFXTheme.vfdGreen)
                        .fixedSize(horizontal: false, vertical: true)
                }

                sectionTitle("USB layout tips")
                VStack(alignment: .leading, spacing: 6) {
                    tipRow("Disk rack (FF 3.44): `indexed-prefix = \"\"` → files `0000_*.*`, `0001_*.*`. Library `.syx` export can still use prefix DSKA if you set it in the USB export sheet.")
                    tipRow("Prefer HFE for classic disk workflows; loose .syx suits librarian / MIDI load paths when FlashFloppy lists them.")
                    tipRow("Keep folder depth shallow; native mode can use category folders (00_FACTORY, 03_PAD, … per docs/VFX_SD_Context.md).")
                    tipRow("OLED shows the full FAT name; with numeric slots the visible name is mostly your friendly suffix (no DSKA letters).")
                }
                .font(.caption)
                .foregroundStyle(VFXTheme.textSecondary)

                sectionTitle("OLED / indexed display names")
                Text(
                    "`VFX-RACK-BUILD-FF344` uses FlashFloppy 3.44 with **empty** `indexed-prefix` and files like `0027_ATW_Colorado_Demos.HFE`. Slot = first four digits; keep suffixes short for the 34×19 mm OLED. **Do not** deploy `IMG.CFG` (see docs/GOTEK_INDEXED_RACK.md)."
                )
                .font(.caption)
                .foregroundStyle(VFXTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                Text(
                    "Regenerate rack + FF.CFG: python3 tools/apply_vfx_rack_friendly_indexed_names.py gotek/ensoniq-vfx-sd/VFX-RACK-BUILD-FF344"
                )
                .font(.caption2)
                .foregroundStyle(VFXTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                Button("Save bash script: plain ####.* → catalog friendly names…") {
                    showCatalogForFriendlyRenameScript = true
                }
                .font(.callout)
                if let m = renameScriptMessage {
                    Text(m)
                        .font(.caption)
                        .foregroundStyle(VFXTheme.vfdGreen)
                }

                sectionTitle("FF.CFG")
                FFCfgEditorView(cfgText: $ffCfgDraft)

                FirmwareUpdateWizardView()

                sectionTitle("Disk name catalog")
                Text("Reference names from the project backup catalog (copy a disk name for USB folders).")
                    .font(.caption)
                    .foregroundStyle(VFXTheme.textSecondary)
                TextField("Search", text: $catalogSearch)
                    .textFieldStyle(.roundedBorder)

                if catalogEntries.isEmpty {
                    Text(catalogSearch.isEmpty ? "No catalog loaded (ensure VFX_SD_GOTEK_CATALOG.csv is in the app bundle)." : "No matches.")
                        .font(.caption)
                        .foregroundStyle(VFXTheme.textSecondary)
                } else {
                    catalogTable
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(VFXTheme.panelBackground)
        .foregroundStyle(VFXTheme.textPrimary)
        .sheet(isPresented: $showUSBExportSheet) {
            FloppyUSBExportSheet(library: library, ffCfgDraft: $ffCfgDraft) {
                showUSBExportSheet = false
            }
        }
        .onAppear {
            loadFloppyHardwarePreferences()
            refreshRackFolderPathCache()
            if ffCfgDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                if let s = UserDefaults.standard.string(forKey: floppyFFCfgDefaultsKey), !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    ffCfgDraft = s
                } else {
                    ffCfgDraft = FFCfgFile.encode(
                        entries: FFCfgFile.recommendedEntries(indexedPrefix: ""),
                        headerComment: "VFX-CTRL defaults: VFX-RACK-BUILD-FF344 — oled-128x64, display-order 0d,7,1, font 8x16, rotary full,reverse, autoselect 0. For .syx-only sticks set indexed-prefix = \"DSKA\" in the editor or USB export sheet."
                    )
                }
            }
        }
        .onChange(of: ffCfgDraft) { _, new in
            UserDefaults.standard.set(new, forKey: floppyFFCfgDefaultsKey)
        }
        .onChange(of: selectedGotekFamilyId) { _, new in
            UserDefaults.standard.set(new, forKey: floppyGotekFamilyKey)
        }
        .onChange(of: selectedEnsoniqHostId) { _, new in
            UserDefaults.standard.set(new, forKey: floppyEnsoniqHostKey)
        }
        .onChange(of: replaceHostKeysWhenMerging) { _, new in
            UserDefaults.standard.set(new, forKey: floppyReplaceHostKeysKey)
        }
        .fileImporter(
            isPresented: $showCatalogForFriendlyRenameScript,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleCatalogForFriendlyRenameScript(result)
        }
        .fileImporter(
            isPresented: $showImportSingle,
            allowedContentTypes: VFXSysExTypes.importContentTypes,
            allowsMultipleSelection: false
        ) { handleSingleImportResult($0) }
        .fileImporter(
            isPresented: $showImportMulti,
            allowedContentTypes: VFXSysExTypes.importContentTypes,
            allowsMultipleSelection: true
        ) { handleMultiImportResult($0) }
        .alert("Import finished", isPresented: $showBulkSummary) {
            Button("OK", role: .cancel) { bulkSummary = nil }
        } message: {
            Text(bulkSummaryMessage)
        }
        .alert("Duplicate SysEx", isPresented: duplicateAlertPresented) {
            Button("Import Anyway") {
                if let p = duplicateIncoming {
                    library.commitImportedPatch(p)
                }
                clearDuplicateState()
            }
            Button("Skip", role: .cancel) { clearDuplicateState() }
        } message: {
            Text(duplicateAlertMessage)
        }
    }

    private var selectedGotekFamily: GotekUnitFamily {
        GotekUnitFamily.all.first { $0.id == selectedGotekFamilyId } ?? GotekUnitFamily.all[0]
    }

    private var selectedEnsoniqHost: EnsoniqHostProfile {
        EnsoniqHostProfile.profile(id: selectedEnsoniqHostId) ?? EnsoniqHostProfile.all[0]
    }

    @ViewBuilder
    private var gotekHardwareSetupSection: some View {
        sectionTitle("Gotek model + Ensoniq host")
        Text(
            "Icons are stand-ins for each Gotek style (see FlashFloppy Gotek Models for photos). The rack FF.CFG targets the SamplerZone Extended **128×64** OLED: `display-type = oled-128x64`, `display-order = 0d,7,1` (double-height disk name / spacer / status on the bottom 16 px). `ejected-on-startup = no` avoids a half-screen EjectMenu with no filename; autoselect stays off for deliberate mounts. Apply below merges only host/interface/pin/chgrst — use FF.CFG editor for the full baseline."
        )
        .font(.caption)
        .foregroundStyle(VFXTheme.textSecondary)
        .fixedSize(horizontal: false, vertical: true)

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(GotekUnitFamily.all) { fam in
                    let on = fam.id == selectedGotekFamilyId
                    Button {
                        selectedGotekFamilyId = fam.id
                    } label: {
                        VStack(alignment: .center, spacing: 8) {
                            Image(systemName: fam.symbolName)
                                .font(.system(size: 36))
                                .foregroundStyle(on ? VFXTheme.vfdGreen : VFXTheme.textSecondary)
                            Text(fam.title)
                                .font(.caption.weight(.semibold))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(VFXTheme.textPrimary)
                            Text(fam.typicalModels)
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(VFXTheme.textSecondary)
                                .lineLimit(3)
                        }
                        .padding(12)
                        .frame(width: 168, alignment: .top)
                        .background(VFXTheme.surface.opacity(on ? 0.95 : 0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(on ? VFXTheme.vfdGreen : VFXTheme.textSecondary.opacity(0.25), lineWidth: on ? 2 : 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }

        HStack {
            Text("Ensoniq instrument")
                .font(.callout)
                .foregroundStyle(VFXTheme.textPrimary)
            Spacer(minLength: 8)
            Picker("Ensoniq instrument", selection: $selectedEnsoniqHostId) {
                ForEach(EnsoniqHostProfile.all) { p in
                    Text(p.displayName).tag(p.id)
                }
            }
            .labelsHidden()
            .frame(minWidth: 220, alignment: .trailing)
            .pickerStyle(.menu)
        }

        HStack(spacing: 16) {
            Link("Host Platforms: Ensoniq", destination: URL(string: "https://github.com/keirf/FlashFloppy/wiki/Host-Platforms#ensoniq")!)
            Link("Gotek models", destination: URL(string: "https://github.com/keirf/FlashFloppy/wiki/Gotek-Models")!)
            Link("Hardware mods", destination: URL(string: "https://github.com/keirf/FlashFloppy/wiki/Hardware-Mods")!)
        }
        .font(.caption)

        if let vendor = selectedGotekFamily.vendorProductURL, let vendorURL = URL(string: vendor) {
            Link("SamplerZone: Gotek Extended (34×19 mm OLED)", destination: vendorURL)
                .font(.caption)
        }

        if selectedGotekFamily.id == "oled_kc30_415",
           selectedEnsoniqHost.ffCfgEntries["interface"] == "ibmpc-hdout" {
            Text(
                "SFRKC30.AT2 often has no JC pad — ibmpc-hdout in FF.CFG is the usual way to satisfy ASR-10 / TS-style hosts on that PCB."
            )
            .font(.caption)
            .foregroundStyle(VFXTheme.vfdAmber)
            .fixedSize(horizontal: false, vertical: true)
        }

        DisclosureGroup("Jumpers + Gotek PCB notes") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Instrument (FlashFloppy wiki)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(VFXTheme.textPrimary)
                ForEach(Array(selectedEnsoniqHost.jumperSteps.enumerated()), id: \.offset) { _, line in
                    hardwareBullet(line)
                }
                ForEach(Array(selectedEnsoniqHost.wikiNotes.enumerated()), id: \.offset) { _, line in
                    hardwareBullet(line)
                }
                Divider().padding(.vertical, 4)
                Text("Gotek: \(selectedGotekFamily.title)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(VFXTheme.textPrimary)
                ForEach(Array(selectedGotekFamily.notes.enumerated()), id: \.offset) { _, line in
                    hardwareBullet(line)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
        }
        .font(.callout)

        DisclosureGroup("Library backup / restore (this app)") {
            Text(selectedEnsoniqHost.libraryBackupHints)
                .font(.caption)
                .foregroundStyle(VFXTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(
                "VFX-SD internal bank size used in exports: \(VFXBankLimits.programsPerInternalBank) programs. Truncation and bank.json metadata are set during USB export when you enable those options."
            )
            .font(.caption2)
            .foregroundStyle(VFXTheme.textSecondary)
            .padding(.top, 4)
            .fixedSize(horizontal: false, vertical: true)
        }
        .font(.callout)

        Toggle("Replace existing host / interface / pin / chgrst keys when applying", isOn: $replaceHostKeysWhenMerging)
            .font(.caption)

        Button("Apply Ensoniq host profile to FF.CFG draft") {
            applyEnsoniqHostProfileToFFCfgDraft()
        }
        .font(.callout)
    }

    private func hardwareBullet(_ line: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(line)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.caption)
        .foregroundStyle(VFXTheme.textSecondary)
    }

    private func loadFloppyHardwarePreferences() {
        let d = UserDefaults.standard
        if let s = d.string(forKey: floppyGotekFamilyKey),
           GotekUnitFamily.all.contains(where: { $0.id == s }) {
            selectedGotekFamilyId = s
        }
        if let s = d.string(forKey: floppyEnsoniqHostKey),
           EnsoniqHostProfile.profile(id: s) != nil {
            selectedEnsoniqHostId = s
        }
        if d.object(forKey: floppyReplaceHostKeysKey) != nil {
            replaceHostKeysWhenMerging = d.bool(forKey: floppyReplaceHostKeysKey)
        }
    }

    private func applyEnsoniqHostProfileToFFCfgDraft() {
        var parsed = FFCfgFile.parse(ffCfgDraft)
        parsed = GotekEnsoniqSetupMerge.mergeHostProfile(
            into: parsed,
            profile: selectedEnsoniqHost,
            replace: replaceHostKeysWhenMerging
        )
        let header =
            "Merged Ensoniq host profile: \(selectedEnsoniqHost.displayName). Gotek family: \(selectedGotekFamily.title). Verify jumpers on hardware."
        ffCfgDraft = FFCfgFile.encode(entries: parsed, headerComment: header)
    }

    private func refreshRackFolderPathCache() {
        rackFolderPathCache = GotekIndexedRackDeploy.FolderPreferences.savedFolderURL()?.path ?? ""
    }

    private func chooseIndexedRackFolder() {
        rackDeployError = nil
        rackDeployMessage = nil
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Select"
        panel.title = "Indexed rack folder"
        panel.message = "Select the folder whose root contains 000*_*.HFE / .IMG and FF.CFG (e.g. VFX-RACK-BUILD-FF344)."
        if panel.runModal() == .OK, let url = panel.url {
            GotekIndexedRackDeploy.FolderPreferences.setSavedFolderURL(url)
            refreshRackFolderPathCache()
        }
    }

    private func revealIndexedRackFolder() {
        guard let url = GotekIndexedRackDeploy.FolderPreferences.savedFolderURL() else { return }
        NSWorkspace.shared.open(url)
    }

    private func copyRackDeployablesToUSB() {
        rackDeployError = nil
        rackDeployMessage = nil
        guard let source = GotekIndexedRackDeploy.FolderPreferences.savedFolderURL() else {
            rackDeployError = "Choose a rack folder first."
            return
        }

        let destPanel = NSOpenPanel()
        destPanel.canChooseDirectories = true
        destPanel.canChooseFiles = false
        destPanel.allowsMultipleSelection = false
        destPanel.prompt = "Copy Here"
        destPanel.title = "SD / USB stick root"
        destPanel.message = "Select the **root** of your FAT32 USB stick (000* disk files + FF.CFG). Existing same-named files will be replaced."

        guard destPanel.runModal() == .OK, let dest = destPanel.url else { return }

        let srcOK = source.startAccessingSecurityScopedResource()
        let dstOK = dest.startAccessingSecurityScopedResource()
        defer {
            if srcOK { source.stopAccessingSecurityScopedResource() }
            if dstOK { dest.stopAccessingSecurityScopedResource() }
        }
        guard dstOK else {
            rackDeployError = "Could not access the destination folder."
            return
        }

        do {
            let result = try GotekIndexedRackDeploy.copyDeployableFiles(from: source, to: dest)
            let skipNote = result.skippedOtherFileCount > 0
                ? " Left \(result.skippedOtherFileCount) other item(s) in the rack folder uncopied."
                : ""
            rackDeployMessage =
                "Copied \(result.copiedFileNames.count) file(s) to \(dest.lastPathComponent).\(skipNote) Eject safely when done."
        } catch {
            rackDeployError = error.localizedDescription
        }
    }

    private func sectionTitle(_ s: String) -> some View {
        Text(s)
            .font(.headline)
            .foregroundStyle(VFXTheme.vfdGreen)
    }

    private func tipRow(_ s: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(s)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var catalogTable: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("#").frame(width: 28, alignment: .leading)
                Text("Disk").frame(minWidth: 100, alignment: .leading)
                Text("Category").frame(minWidth: 80, alignment: .leading)
                Text("Compat").frame(width: 72, alignment: .leading)
                Spacer(minLength: 8)
                Text("Copy")
            }
            .font(.caption2.weight(.semibold))
            .foregroundStyle(VFXTheme.textSecondary)
            .padding(.vertical, 4)

            Divider().background(VFXTheme.textSecondary.opacity(0.3))

            ForEach(catalogEntries.prefix(200)) { row in
                HStack(alignment: .firstTextBaseline) {
                    Text("\(row.diskNumber)").frame(width: 28, alignment: .leading)
                    Text(row.diskName).frame(minWidth: 100, alignment: .leading).lineLimit(1)
                    Text(row.soundCategory).frame(minWidth: 80, alignment: .leading).lineLimit(1)
                    Text(row.compatibility).frame(width: 72, alignment: .leading).lineLimit(1)
                    Spacer(minLength: 8)
                    Button("Name") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(row.diskName, forType: .string)
                    }
                    .buttonStyle(.borderless)
                    .font(.caption2)
                }
                .font(.caption)
                .padding(.vertical, 3)
            }
            if catalogEntries.count > 200 {
                Text("Showing first 200 rows — refine search.")
                    .font(.caption2)
                    .foregroundStyle(VFXTheme.textSecondary)
                    .padding(.top, 4)
            }
        }
        .padding(8)
        .background(VFXTheme.surface.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var duplicateAlertPresented: Binding<Bool> {
        Binding(
            get: { duplicateIncoming != nil },
            set: { if !$0 { clearDuplicateState() } }
        )
    }

    private var duplicateAlertMessage: String {
        guard let e = duplicateExisting else {
            return "This file matches a patch already in the library."
        }
        return "Same SysEx as “\(e.name)”. Import a second copy anyway?"
    }

    private var bulkSummaryMessage: String {
        guard let s = bulkSummary else { return "" }
        return "Imported \(s.imported). Skipped \(s.skippedDuplicate) duplicate(s). Unreadable: \(s.skippedUnreadable)."
    }

    private func clearDuplicateState() {
        duplicateIncoming = nil
        duplicateExisting = nil
    }

    private func exportCurrentPatch(gotekShortName: Bool) {
        guard let data = editor.currentPatch.rawSysEx else { return }
        if gotekShortName {
            _ = ExportHelper.saveSysExGotek(data, patchName: editor.currentPatch.name, maxBaseNameLength: 16)
        } else {
            _ = ExportHelper.saveSysEx(data, defaultName: editor.currentPatch.name + ".syx")
        }
    }

    private func handleSingleImportResult(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result, let url = urls.first else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let data = try? Data(contentsOf: url) else { return }
        let name = url.lastPathComponent
        let ev = library.evaluateSysExImport(data, sourceFileName: name)
        if let dup = ev.duplicateOf {
            duplicateIncoming = ev.patch
            duplicateExisting = dup
        } else {
            library.commitImportedPatch(ev.patch)
        }
    }

    private func handleMultiImportResult(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result, !urls.isEmpty else { return }
        bulkSummary = library.importSysExBulk(urls: urls, policy: .skipDuplicates)
        showBulkSummary = true
    }

    private func runFolderImport() {
        SysExFolderPicker.presentAndCollectSyx { urls in
            bulkSummary = library.importSysExBulk(urls: urls, policy: .skipDuplicates)
            showBulkSummary = true
        }
    }

    private func handleCatalogForFriendlyRenameScript(_ result: Result<[URL], Error>) {
        renameScriptMessage = nil
        guard case .success(let urls) = result, let url = urls.first else { return }
        guard url.startAccessingSecurityScopedResource() else {
            renameScriptMessage = "Could not read catalog file."
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let data = try? Data(contentsOf: url),
              let cat = try? JSONDecoder().decode(VFXRackCatalogFile.self, from: data) else {
            renameScriptMessage = "Could not parse VFX_RACK_CATALOG-style JSON."
            return
        }
        let script = VFXRackFriendlyIndexedRenameScript.bashScript(catalog: cat, indexedPrefix: "")
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "apply_friendly_indexed_names.sh"
        panel.title = "Save rename script"
        guard panel.runModal() == .OK, let out = panel.url else { return }
        guard out.startAccessingSecurityScopedResource() else {
            renameScriptMessage = "Could not write script."
            return
        }
        defer { out.stopAccessingSecurityScopedResource() }
        guard let outData = script.data(using: .utf8) else {
            renameScriptMessage = "Failed to encode script."
            return
        }
        do {
            try outData.write(to: out)
            renameScriptMessage = "Saved \(out.lastPathComponent). chmod +x, run from USB root if files are still plain ####.* (no friendly suffix)."
        } catch {
            renameScriptMessage = "Failed to write script."
        }
    }
}
