import AppKit
import SwiftUI

private enum FloppyExportSource: String, CaseIterable, Identifiable {
    case liveSet = "Live set"
    case fullLibrary = "Full library"

    var id: String { rawValue }
}

/// Export patches to a USB stick with FlashFloppy indexed naming, optional FF.CFG, optional latest `.upd`.
struct FloppyUSBExportSheet: View {
    @ObservedObject var library: LibraryDB
    @Binding var ffCfgDraft: String

    var onDismiss: () -> Void

    @State private var source: FloppyExportSource = .liveSet
    @State private var selectedSetId: UUID?
    @State private var indexedMode = true
    @State private var indexedPrefix = "DSKA"
    @State private var shortNames = true
    @State private var writeBankManifest = true
    @State private var limitToBankSize = true
    @State private var categoryFoldersNative = false
    @State private var includeFFCfg = true
    @State private var includeLatestUpd = false

    @State private var resultMessage: String?
    @State private var errorMessage: String?
    @State private var isWorking = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Export to USB / SD")
                .font(.headline)
                .foregroundStyle(VFXTheme.vfdGreen)

            Text(
                "Writes patches in list order (live set order or library list order). FlashFloppy indexed mode uses names like DSKA0000_name.syx at the stick root; match indexed-prefix in FF.CFG. Confirm your firmware treats .syx as a navigable type for your host, or use disk images per FlashFloppy docs."
            )
            .font(.caption)
            .foregroundStyle(VFXTheme.textSecondary)
            .fixedSize(horizontal: false, vertical: true)

            Picker("Source", selection: $source) {
                ForEach(FloppyExportSource.allCases) { s in
                    Text(s.rawValue).tag(s)
                }
            }
            .pickerStyle(.segmented)

            if source == .liveSet {
                Picker("Live set", selection: $selectedSetId) {
                    Text("Choose…").tag(nil as UUID?)
                    ForEach(library.liveSets) { set in
                        Text(set.name).tag(set.id as UUID?)
                    }
                }
                .disabled(library.liveSets.isEmpty)
            } else {
                Text("Exports all patches in the order shown in the Library sidebar (\(library.patches.count) patches).")
                    .font(.caption)
                    .foregroundStyle(VFXTheme.textSecondary)
            }

            Group {
                Toggle("FlashFloppy indexed filenames (PREFIX0000_name.syx)", isOn: $indexedMode)
                HStack {
                    Text("Indexed prefix")
                    TextField("DSKA", text: $indexedPrefix)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                        .font(.body.monospaced())
                }
                Toggle("Short name suffix (≤16 chars before .syx)", isOn: $shortNames)
                Toggle("Write bank.json manifest", isOn: $writeBankManifest)
                Toggle("Limit to \(VFXBankLimits.programsPerInternalBank) programs (one RAM bank)", isOn: $limitToBankSize)
                if !indexedMode {
                    Toggle("Category subfolders (native layout only)", isOn: $categoryFoldersNative)
                }
                Toggle("Write FF.CFG (use editor below or Floppy tab)", isOn: $includeFFCfg)
                Toggle("Include latest FlashFloppy firmware (.upd from GitHub)", isOn: $includeLatestUpd)
            }
            .font(.callout)

            Button("Choose USB stick folder…") {
                Task { await runExport() }
            }
            .buttonStyle(VFXButtonStyle())
            .disabled(isWorking || !canExport)

            if isWorking {
                ProgressView()
                    .scaleEffect(0.8)
            }
            if let e = errorMessage {
                Text(e)
                    .font(.caption)
                    .foregroundStyle(VFXTheme.vfdAmber)
            }
            if let r = resultMessage {
                Text(r)
                    .font(.caption)
                    .foregroundStyle(VFXTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text("FF.CFG text is taken from the FF.CFG editor on the Floppy Emulator tab (scroll up after closing this sheet to edit).")
                .font(.caption2)
                .foregroundStyle(VFXTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
            Button("Done") { onDismiss() }
                .buttonStyle(VFXButtonStyle())
        }
        .padding(24)
        .frame(minWidth: 420, minHeight: 560)
        .background(VFXTheme.panelBackground)
        .foregroundStyle(VFXTheme.textPrimary)
        .onAppear {
            if selectedSetId == nil {
                selectedSetId = library.liveSets.first?.id
            }
        }
    }

    private var canExport: Bool {
        switch source {
        case .liveSet:
            return selectedSetId != nil && !library.liveSets.isEmpty
        case .fullLibrary:
            return !library.patches.isEmpty
        }
    }

    private func patchesToExport() -> (patches: [VFXPatch], liveSetName: String, truncated: Bool) {
        switch source {
        case .liveSet:
            guard let id = selectedSetId,
                  let set = library.liveSets.first(where: { $0.id == id }) else {
                return ([], "", false)
            }
            var patches = set.patchIds.compactMap { library.patch(byId: $0) }
            let truncated = limitToBankSize && patches.count > VFXBankLimits.programsPerInternalBank
            if limitToBankSize {
                patches = Array(patches.prefix(VFXBankLimits.programsPerInternalBank))
            }
            return (patches, set.name, truncated)
        case .fullLibrary:
            var patches = library.patches
            let truncated = limitToBankSize && patches.count > VFXBankLimits.programsPerInternalBank
            if limitToBankSize {
                patches = Array(patches.prefix(VFXBankLimits.programsPerInternalBank))
            }
            return (patches, "Library", truncated)
        }
    }

    @MainActor
    private func runExport() async {
        errorMessage = nil
        resultMessage = nil
        let (patches, setName, truncated) = patchesToExport()
        guard !patches.isEmpty else {
            errorMessage = "Nothing to export."
            return
        }

        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Export Here"
        panel.title = "USB / SD root"
        panel.message = "Select the root folder of your USB stick (where DSKA0000… and FF.CFG should go)."

        guard panel.runModal() == .OK, let root = panel.url else { return }
        guard root.startAccessingSecurityScopedResource() else {
            errorMessage = "Could not access the selected folder."
            return
        }
        defer { root.stopAccessingSecurityScopedResource() }

        let prefix = ExportNaming.normalizedIndexedPrefix(indexedPrefix)
        let opts = ExportNaming.Options(
            maxBaseNameLength: shortNames ? 16 : nil,
            numericPrefix: !indexedMode,
            categorySubfolders: indexedMode ? false : categoryFoldersNative,
            flashFloppyIndexedMode: indexedMode,
            indexedPrefix: prefix
        )

        isWorking = true
        defer { isWorking = false }

        var parts: [String] = []
        do {
            if includeFFCfg {
                var entries = FFCfgFile.parse(ffCfgDraft)
                entries["indexed-prefix"] = "\"\(prefix)\""
                if indexedMode {
                    entries["nav-mode"] = entries["nav-mode"] ?? "indexed"
                }
                let body = FFCfgFile.encode(
                    entries: entries,
                    headerComment: "Written by VFX-CTRL. Match indexed-prefix to exported filenames."
                )
                let cfgURL = root.appendingPathComponent("FF.CFG")
                guard let data = body.data(using: .utf8) else {
                    throw FFCfgEncodeError.utf8
                }
                try data.write(to: cfgURL)
                parts.append("Wrote FF.CFG.")
            }

            let manifest: BankManifestWriteOptions? = writeBankManifest
                ? BankManifestWriteOptions(liveSetName: setName, truncatedToBankSize: truncated)
                : nil
            let count = ExportHelper.writePatches(patches, to: root, options: opts, manifest: manifest)
            if count == 0 {
                errorMessage = "No patches contained SysEx data."
                return
            }
            parts.append("Exported \(count) .syx file(s)\(indexedMode ? " (indexed)" : "").")
            if writeBankManifest { parts.append("Wrote bank.json.") }
            if truncated { parts.append("Truncated to \(VFXBankLimits.programsPerInternalBank).") }

            if includeLatestUpd {
                let svc = FlashFloppyReleaseService()
                try await svc.stageLatestFirmwareUpds(to: root)
                parts.append("Copied latest FlashFloppy .upd file(s) to stick root.")
            }

            resultMessage = parts.joined(separator: " ")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private enum FFCfgEncodeError: LocalizedError {
    case utf8
    var errorDescription: String? { "Could not encode FF.CFG as UTF-8." }
}
