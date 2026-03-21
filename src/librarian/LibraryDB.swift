import Foundation

/// Result of evaluating a SysEx blob before adding to the library.
struct SysExImportEvaluation {
    var patch: VFXPatch
    /// Existing library patch with identical SysEx bytes (by hash or raw equality).
    var duplicateOf: VFXPatch?
}

struct BulkSysExImportSummary: Equatable {
    var imported: Int = 0
    var skippedDuplicate: Int = 0
    var skippedUnreadable: Int = 0
}

enum BulkImportDuplicatePolicy {
    /// Skip blobs that match an existing library patch (by hash or raw data).
    case skipDuplicates
    /// Add every file (allows duplicate SysEx in the library).
    case importAll
}

final class LibraryDB: ObservableObject {
    @Published var patches: [VFXPatch] = [] {
        didSet { savePatches() }
    }
    @Published var favoriteIds: Set<UUID> = [] {
        didSet { saveFavorites() }
    }
    @Published var liveSets: [LiveSet] = [] {
        didSet { saveLiveSets() }
    }

    private let dir: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        if let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            dir = appSupport.appendingPathComponent("VFXCtrl", isDirectory: true)
        } else {
            dir = FileManager.default.temporaryDirectory.appendingPathComponent("VFXCtrl", isDirectory: true)
        }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        loadPatches()
        loadFavorites()
        loadLiveSets()
    }

    // MARK: - Patches
    private var patchesURL: URL { dir.appendingPathComponent("library.json") }

    func loadPatches() {
        guard FileManager.default.fileExists(atPath: patchesURL.path),
              let data = try? Data(contentsOf: patchesURL),
              let decoded = try? decoder.decode([VFXPatch].self, from: data) else { return }
        patches = decoded.map(Self.migrateProvenance)
    }

    /// Backfill `sysexSHA256` for patches saved before provenance existed.
    private static func migrateProvenance(_ patch: VFXPatch) -> VFXPatch {
        var p = patch
        if p.sysexSHA256 == nil, let raw = p.rawSysEx, !raw.isEmpty {
            p.sysexSHA256 = SysExDigest.sha256Hex(of: raw)
        }
        return p
    }

    private func savePatches() {
        guard let data = try? encoder.encode(patches) else { return }
        try? data.write(to: patchesURL)
    }

    /// Parse SysEx, attach import metadata + SHA256 digest. Does **not** append until `commitImportedPatch` (after duplicate check in UI).
    func evaluateSysExImport(_ data: Data, sourceFileName: String?, sourceSynthOS: String? = nil) -> SysExImportEvaluation {
        var patch: VFXPatch
        if let parsed = try? PatchParser().parseProgramDump(data) {
            patch = parsed
        } else {
            var raw = VFXPatch(name: "Imported", rawSysEx: data)
            raw.importIntegrityNote = "Not parsed as a VFX-SD program dump; stored as raw SysEx."
            patch = raw
        }
        let digest = SysExDigest.sha256Hex(of: data)
        patch.sourceFileName = sourceFileName
        patch.importedAt = Date()
        patch.sourceSynthOS = sourceSynthOS
        patch.sysexSHA256 = digest

        let dup = patches.first { existing in
            if let h = existing.sysexSHA256, h == digest { return true }
            if let r = existing.rawSysEx, r == data { return true }
            return false
        }
        return SysExImportEvaluation(patch: patch, duplicateOf: dup)
    }

    func commitImportedPatch(_ patch: VFXPatch) {
        patches.append(patch)
    }

    /// Import many `.syx` / SysEx files. Each URL should be security-scoped if required by the picker.
    @discardableResult
    func importSysExBulk(urls: [URL], policy: BulkImportDuplicatePolicy = .skipDuplicates) -> BulkSysExImportSummary {
        var summary = BulkSysExImportSummary()
        for url in urls {
            let accessed = url.startAccessingSecurityScopedResource()
            defer {
                if accessed { url.stopAccessingSecurityScopedResource() }
            }
            guard let data = try? Data(contentsOf: url) else {
                summary.skippedUnreadable += 1
                continue
            }
            let ev = evaluateSysExImport(data, sourceFileName: url.lastPathComponent)
            switch policy {
            case .skipDuplicates:
                if ev.duplicateOf != nil {
                    summary.skippedDuplicate += 1
                    continue
                }
                commitImportedPatch(ev.patch)
                summary.imported += 1
            case .importAll:
                commitImportedPatch(ev.patch)
                summary.imported += 1
            }
        }
        return summary
    }

    func removePatches(at offsets: IndexSet) {
        patches.remove(atOffsets: offsets)
    }

    func toggleFavorite(_ id: UUID) {
        if favoriteIds.contains(id) { favoriteIds.remove(id) }
        else { favoriteIds.insert(id) }
    }

    var favoritePatches: [VFXPatch] {
        patches.filter { favoriteIds.contains($0.id) }
    }

    // MARK: - Favorites
    private var favoritesURL: URL { dir.appendingPathComponent("favorites.json") }

    func loadFavorites() {
        guard FileManager.default.fileExists(atPath: favoritesURL.path),
              let data = try? Data(contentsOf: favoritesURL),
              let decoded = try? decoder.decode([String].self, from: data) else { return }
        favoriteIds = Set(decoded.compactMap { UUID(uuidString: $0) })
    }

    private func saveFavorites() {
        let strings = favoriteIds.map { $0.uuidString }
        try? encoder.encode(strings).write(to: favoritesURL)
    }

    // MARK: - Live sets
    private var liveSetsURL: URL { dir.appendingPathComponent("live_sets.json") }

    func loadLiveSets() {
        guard FileManager.default.fileExists(atPath: liveSetsURL.path),
              let data = try? Data(contentsOf: liveSetsURL),
              let decoded = try? decoder.decode([LiveSet].self, from: data) else { return }
        liveSets = decoded
    }

    private func saveLiveSets() {
        guard let data = try? encoder.encode(liveSets) else { return }
        try? data.write(to: liveSetsURL)
    }

    func addLiveSet(name: String = "New Set") {
        liveSets.append(LiveSet(name: name))
    }

    func removeLiveSet(at offsets: IndexSet) {
        liveSets.remove(atOffsets: offsets)
    }

    func addPatch(_ patchId: UUID, toSet setId: UUID) {
        guard let i = liveSets.firstIndex(where: { $0.id == setId }) else { return }
        var updated = liveSets
        updated[i].patchIds.append(patchId)
        liveSets = updated
    }

    func removePatch(at offsets: IndexSet, fromSet setId: UUID) {
        guard let i = liveSets.firstIndex(where: { $0.id == setId }) else { return }
        var updated = liveSets
        updated[i].patchIds.remove(atOffsets: offsets)
        liveSets = updated
    }

    func movePatch(in set: LiveSet, from: IndexSet, to: Int) {
        guard let i = liveSets.firstIndex(where: { $0.id == set.id }) else { return }
        var updated = liveSets
        updated[i].patchIds.move(fromOffsets: from, toOffset: to)
        liveSets = updated
    }

    func patch(byId id: UUID) -> VFXPatch? {
        patches.first { $0.id == id }
    }
}
