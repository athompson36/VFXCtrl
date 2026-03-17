import Foundation

final class LibraryDB: ObservableObject {
    @Published var patches: [VFXPatch] = [] {
        didSet { save() }
    }

    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        let dir: URL
        if let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            dir = appSupport.appendingPathComponent("VFXCtrl", isDirectory: true)
        } else {
            dir = FileManager.default.temporaryDirectory.appendingPathComponent("VFXCtrl", isDirectory: true)
        }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("library.json")
        load()
    }

    func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let decoded = try? decoder.decode([VFXPatch].self, from: data) else { return }
        patches = decoded
    }

    private func save() {
        guard let data = try? encoder.encode(patches) else { return }
        try? data.write(to: fileURL)
    }

    /// Parse SysEx and add to library. Uses patch name from dump when possible.
    func importSysEx(_ data: Data) {
        let patch = (try? PatchParser().parseProgramDump(data)) ?? VFXPatch(name: "Imported", rawSysEx: data)
        patches.append(patch)
    }

    func removePatches(at offsets: IndexSet) {
        patches.remove(atOffsets: offsets)
    }
}
