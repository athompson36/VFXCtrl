import SwiftUI

struct PatchListView: View {
    @EnvironmentObject private var editor: EditorState

    var body: some View {
        List {
            Section("Current") {
                Text(editor.currentPatch.name)
            }
        }
        .navigationTitle("Patches")
    }
}
