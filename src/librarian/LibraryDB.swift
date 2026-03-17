import Foundation

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
        patches = decoded
    }

    private func savePatches() {
        guard let data = try? encoder.encode(patches) else { return }
        try? data.write(to: patchesURL)
    }

    /// Parse SysEx and add to library. Uses patch name from dump when possible.
    func importSysEx(_ data: Data) {
        let patch = (try? PatchParser().parseProgramDump(data)) ?? VFXPatch(name: "Imported", rawSysEx: data)
        patches.append(patch)
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
