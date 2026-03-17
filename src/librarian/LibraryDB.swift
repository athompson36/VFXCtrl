import Foundation

final class LibraryDB: ObservableObject {
    @Published var patches: [VFXPatch] = []

    func importSysEx(_ data: Data) {
        patches.append(VFXPatch(name: "Imported", rawSysEx: data))
    }
}
