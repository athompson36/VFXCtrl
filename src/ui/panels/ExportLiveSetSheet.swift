import SwiftUI

struct ExportLiveSetSheet: View {
    @ObservedObject var library: LibraryDB
    var onDismiss: () -> Void
    @State private var selectedSetId: UUID?
    @State private var exportResult: String?

    var body: some View {
        VStack(spacing: 16) {
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
                Button("Export to Folder…") {
                    exportSelectedSet()
                }
                .disabled(selectedSetId == nil)
                if let msg = exportResult {
                    Text(msg)
                        .font(.caption)
                        .foregroundStyle(VFXTheme.textSecondary)
                }
            }
            Spacer()
            Button("Done") { onDismiss() }
                .buttonStyle(VFXButtonStyle())
        }
        .padding(24)
        .frame(minWidth: 280, minHeight: 180)
        .background(VFXTheme.panelBackground)
        .foregroundStyle(VFXTheme.textPrimary)
        .onAppear {
            selectedSetId = library.liveSets.first?.id
        }
    }

    private func exportSelectedSet() {
        guard let setId = selectedSetId,
              let set = library.liveSets.first(where: { $0.id == setId }) else { return }
        let patches = set.patchIds.compactMap { library.patch(byId: $0) }
        let count = ExportHelper.exportPatches(patches)
        exportResult = count == 0 ? "No patches with SysEx data exported." : "Exported \(count) patch(es)."
    }
}
