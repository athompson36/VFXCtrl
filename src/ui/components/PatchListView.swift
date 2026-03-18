import SwiftUI

struct PatchListView: View {
    @EnvironmentObject private var editor: EditorState

    private let compareEngine = CompareEngine()

    var body: some View {
        List {
            Section("Current") {
                Text(editor.currentPatch.name)
                    .font(.headline)
                    .foregroundStyle(VFXTheme.textPrimary)
            }
            .listRowBackground(VFXTheme.surface)
            Section("Compare") {
                if let compare = editor.comparePatch {
                    Text(compare.name)
                        .font(.headline)
                        .foregroundStyle(VFXTheme.textPrimary)
                } else {
                    Text("None")
                        .foregroundStyle(VFXTheme.textSecondary)
                }
            }
            .listRowBackground(VFXTheme.surface)
            if let compare = editor.comparePatch, !compareEngine.changedKeys(current: editor.currentPatch, compare: compare).isEmpty {
                Section("Differences") {
                    ForEach(compareEngine.changedKeys(current: editor.currentPatch, compare: compare), id: \.self) { key in
                        HStack {
                            Text(key)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(VFXTheme.textPrimary)
                            Spacer()
                            Text("\(editor.currentPatch.parameters[key] ?? 0)")
                                .foregroundStyle(VFXTheme.textSecondary)
                            Text("→")
                                .foregroundStyle(VFXTheme.textSecondary.opacity(0.7))
                            Text("\(compare.parameters[key] ?? 0)")
                                .foregroundStyle(VFXTheme.textSecondary)
                        }
                    }
                }
                .listRowBackground(VFXTheme.surface)
            }
        }
        .scrollContentBackground(.hidden)
        .background(VFXTheme.panelBackground)
        .navigationTitle("Patches")
        .foregroundStyle(VFXTheme.textPrimary)
    }
}
