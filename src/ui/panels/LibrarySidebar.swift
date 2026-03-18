import SwiftUI
import UniformTypeIdentifiers

struct LibrarySidebar: View {
    @EnvironmentObject private var editor: EditorState
    @EnvironmentObject private var library: LibraryDB
    @State private var showImport = false

    var body: some View {
        List {
            Section("Favorites") {
                ForEach(library.favoritePatches) { patch in
                    Button(patch.name) {
                        editor.loadPatch(patch)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(VFXTheme.textPrimary)
                    .lineLimit(1)
                    .contextMenu {
                        Button("Remove from Favorites") {
                            library.toggleFavorite(patch.id)
                        }
                    }
                }
            }

            Section("Library") {
                ForEach(library.patches) { patch in
                    let suggested = TagEngine().suggestTags(for: patch)
                    Button {
                        editor.loadPatch(patch)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(patch.name)
                                .lineLimit(1)
                            if !suggested.isEmpty {
                                Text("Suggested: \(suggested.joined(separator: ", "))")
                                    .font(.caption2)
                                    .foregroundStyle(VFXTheme.textSecondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(VFXTheme.textPrimary)
                    .contextMenu {
                        Button(library.favoriteIds.contains(patch.id) ? "Remove from Favorites" : "Add to Favorites") {
                            library.toggleFavorite(patch.id)
                        }
                        if !library.liveSets.isEmpty {
                            Menu("Add to Set") {
                                ForEach(library.liveSets) { set in
                                    Button(set.name) {
                                        library.addPatch(patch.id, toSet: set.id)
                                    }
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: library.removePatches)
            }

            Section("Snapshots") {
                Button("Take Snapshot") {
                    editor.addSnapshot()
                }
                .foregroundStyle(VFXTheme.vfdGreen)
                ForEach(editor.snapshots) { patch in
                    Button(patch.name) {
                        editor.restoreSnapshot(patch)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(VFXTheme.textPrimary)
                    .lineLimit(1)
                }
                .onDelete(perform: editor.removeSnapshot)
            }

            Section("Live Sets") {
                Button("New Live Set") {
                    library.addLiveSet()
                }
                .foregroundStyle(VFXTheme.vfdGreen)
                ForEach(library.liveSets) { set in
                    DisclosureGroup(set.name) {
                        ForEach(set.patchIds, id: \.self) { id in
                            if let patch = library.patch(byId: id) {
                                Button(patch.name) {
                                    editor.loadPatch(patch)
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(VFXTheme.textPrimary)
                                .lineLimit(1)
                            }
                        }
                        .onDelete { offsets in
                            library.removePatch(at: offsets, fromSet: set.id)
                        }
                        .onMove { from, to in
                            library.movePatch(in: set, from: from, to: to)
                        }
                    }
                }
                .onDelete(perform: library.removeLiveSet)
            }
        }
        .scrollContentBackground(.hidden)
        .background(VFXTheme.panelBackground)
        .foregroundStyle(VFXTheme.textPrimary)
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
