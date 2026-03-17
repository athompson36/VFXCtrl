import SwiftUI

struct PatchListView: View {
    @EnvironmentObject private var editor: EditorState

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
        }
        .navigationTitle("Patches")
    }
}
