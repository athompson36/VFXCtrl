import SwiftUI
import UniformTypeIdentifiers

struct LibrarySidebar: View {
    @EnvironmentObject private var editor: EditorState
    @EnvironmentObject private var library: LibraryDB
    @State private var showImport = false

    var body: some View {
        List {
            Section("Library") {
                ForEach(library.patches) { patch in
                    Button(patch.name) {
                        editor.loadPatch(patch)
                    }
                    .buttonStyle(.plain)
                    .lineLimit(1)
                }
                .onDelete(perform: library.removePatches)
            }
        }
        .navigationTitle("Library")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Import SysEx…") { showImport = true }
            }
        }
        .fileImporter(
            isPresented: $showImport,
            allowedContentTypes: [.data],
            allowsMultipleSelection: false
        ) { result in
            guard case .success(let urls) = result, let url = urls.first,
                  url.startAccessingSecurityScopedResource(),
                  let data = try? Data(contentsOf: url) else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            library.importSysEx(data)
        }
    }
}
