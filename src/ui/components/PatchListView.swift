import SwiftUI

struct PatchListView: View {
    @EnvironmentObject private var editor: EditorState

    private let compareEngine = CompareEngine()

    var body: some View {
        List {
            Section("Current") {
                Text(editor.currentPatch.name)
                    .font(.headline)
            }
            Section("Compare") {
                if let compare = editor.comparePatch {
                    Text(compare.name)
                        .font(.headline)
                } else {
                    Text("None")
                        .foregroundStyle(.secondary)
                }
            }
            if let compare = editor.comparePatch, !compareEngine.changedKeys(current: editor.currentPatch, compare: compare).isEmpty {
                Section("Differences") {
                    ForEach(compareEngine.changedKeys(current: editor.currentPatch, compare: compare), id: \.self) { key in
                        HStack {
                            Text(key)
                                .font(.system(.caption, design: .monospaced))
                            Spacer()
                            Text("\(editor.currentPatch.parameters[key] ?? 0)")
                                .foregroundStyle(.secondary)
                            Text("→")
                                .foregroundStyle(.tertiary)
                            Text("\(compare.parameters[key] ?? 0)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Patches")
    }
}
