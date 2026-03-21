import SwiftUI
import UniformTypeIdentifiers

struct LibrarySidebar: View {
    @EnvironmentObject private var editor: EditorState
    @EnvironmentObject private var library: LibraryDB
    @State private var showImportSingle = false
    @State private var showImportMulti = false
    @State private var duplicateIncoming: VFXPatch?
    @State private var duplicateExisting: VFXPatch?
    @State private var bulkSummary: BulkSysExImportSummary?
    @State private var showBulkSummary = false
    private let tagEngine = TagEngine()

    var body: some View {
        libraryList
            .scrollContentBackground(.hidden)
            .background(VFXTheme.panelBackground)
            .foregroundStyle(VFXTheme.textPrimary)
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu("Import") {
                        Button("SysEx File…") { showImportSingle = true }
                        Button("Multiple SysEx Files…") { showImportMulti = true }
                        Button("Folder of .syx…") { runFolderImport() }
                    }
                }
            }
            .fileImporter(
                isPresented: $showImportSingle,
                allowedContentTypes: VFXSysExTypes.importContentTypes,
                allowsMultipleSelection: false
            ) { result in
                handleSingleImportResult(result)
            }
            .fileImporter(
                isPresented: $showImportMulti,
                allowedContentTypes: VFXSysExTypes.importContentTypes,
                allowsMultipleSelection: true
            ) { result in
                handleMultiImportResult(result)
            }
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
                Button("Skip", role: .cancel) {
                    clearDuplicateState()
                }
            } message: {
                Text(duplicateAlertMessage)
            }
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

    @ViewBuilder
    private var libraryList: some View {
        List {
            favoritesSection
            librarySection
            snapshotsSection
            liveSetsSection
        }
    }

    @ViewBuilder
    private var favoritesSection: some View {
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
    }

    @ViewBuilder
    private var librarySection: some View {
        Section("Library") {
            ForEach(library.patches) { patch in
                let suggested = tagEngine.suggestTags(for: patch)
                Button {
                    editor.loadPatch(patch)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(patch.name)
                            .lineLimit(1)
                        if let src = patch.sourceFileName, !src.isEmpty {
                            Text(src)
                                .font(.caption2)
                                .foregroundStyle(VFXTheme.textSecondary)
                                .lineLimit(1)
                        }
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
    }

    @ViewBuilder
    private var snapshotsSection: some View {
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
    }

    @ViewBuilder
    private var liveSetsSection: some View {
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
}
