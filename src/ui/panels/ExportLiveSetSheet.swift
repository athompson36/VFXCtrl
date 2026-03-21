import SwiftUI

struct ExportLiveSetSheet: View {
    @ObservedObject var library: LibraryDB
    var onDismiss: () -> Void
    @State private var selectedSetId: UUID?
    @State private var exportResult: String?

    @AppStorage("exportLiveSetShortNames") private var shortNames = true
    @AppStorage("exportLiveSetNumericPrefix") private var numericPrefix = true
    @AppStorage("exportLiveSetCategoryFolders") private var categoryFolders = false
    @AppStorage("exportLiveSetWriteManifest") private var writeBankManifest = true
    @AppStorage("exportLiveSetLimit60") private var limitToBankSize = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Export Live Set")
                .font(.headline)
                .foregroundStyle(VFXTheme.vfdGreen)
            if library.liveSets.isEmpty {
                Text("No live sets.")
                    .foregroundStyle(VFXTheme.textSecondary)
            } else {
                Picker("Set", selection: $selectedSetId) {
                    Text("Choose one…").tag(nil as UUID?)
                    ForEach(library.liveSets) { set in
                        Text(set.name).tag(set.id as UUID?)
                    }
                }
                .pickerStyle(.menu)

                if let n = selectedPatchCount, n > VFXBankLimits.programsPerInternalBank {
                    Text(
                        limitToBankSize
                            ? "First \(VFXBankLimits.programsPerInternalBank) patches will export (hardware bank limit)."
                            : "This set has \(n) patches; VFX-SD holds \(VFXBankLimits.programsPerInternalBank) per bank. Enable “First 60 only” or trim the set for one hardware bank."
                    )
                    .font(.caption)
                    .foregroundStyle(VFXTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                }

                Group {
                    Text("Gotek / USB layout")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(VFXTheme.textPrimary)
                    Toggle("Short patch names (≤16 chars before .syx)", isOn: $shortNames)
                    Toggle("Numeric prefix (01_, 02_, …)", isOn: $numericPrefix)
                    Toggle("Category subfolders (00_FACTORY, 03_PAD, …)", isOn: $categoryFolders)
                    Toggle("Write bank.json manifest (slot order + hashes)", isOn: $writeBankManifest)
                    Toggle("Export first \(VFXBankLimits.programsPerInternalBank) only (one RAM bank)", isOn: $limitToBankSize)
                }
                .font(.callout)

                Button("Export to Folder…") {
                    exportSelectedSet()
                }
                .disabled(selectedSetId == nil)

                if let msg = exportResult {
                    Text(msg)
                        .font(.caption)
                        .foregroundStyle(VFXTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer()
            Button("Done") { onDismiss() }
                .buttonStyle(VFXButtonStyle())
        }
        .padding(24)
        .frame(minWidth: 320, minHeight: 320)
        .background(VFXTheme.panelBackground)
        .foregroundStyle(VFXTheme.textPrimary)
        .onAppear {
            selectedSetId = library.liveSets.first?.id
        }
    }

    private var selectedPatchCount: Int? {
        guard let setId = selectedSetId,
              let set = library.liveSets.first(where: { $0.id == setId }) else { return nil }
        return set.patchIds.count
    }

    private var exportOptions: ExportNaming.Options {
        ExportNaming.Options(
            maxBaseNameLength: shortNames ? 16 : nil,
            numericPrefix: numericPrefix,
            categorySubfolders: categoryFolders
        )
    }

    private func exportSelectedSet() {
        guard let setId = selectedSetId,
              let set = library.liveSets.first(where: { $0.id == setId }) else { return }
        var patches = set.patchIds.compactMap { library.patch(byId: $0) }
        let truncated = limitToBankSize && patches.count > VFXBankLimits.programsPerInternalBank
        if limitToBankSize {
            patches = Array(patches.prefix(VFXBankLimits.programsPerInternalBank))
        }
        let manifest: BankManifestWriteOptions? = writeBankManifest
            ? BankManifestWriteOptions(liveSetName: set.name, truncatedToBankSize: truncated)
            : nil
        let count = ExportHelper.exportPatches(patches, options: exportOptions, manifest: manifest)
        if count == 0 {
            exportResult = "No patches with SysEx data exported."
        } else {
            var parts = ["Exported \(count) patch(es)."]
            if writeBankManifest {
                parts.append("Wrote bank.json.")
            }
            if categoryFolders {
                parts.append("Used category subfolders.")
            }
            if numericPrefix {
                parts.append("Numeric filename prefixes.")
            }
            if truncated {
                parts.append("Truncated to \(VFXBankLimits.programsPerInternalBank) for one bank.")
            }
            exportResult = parts.joined(separator: " ")
        }
    }
}
