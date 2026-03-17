import Foundation

struct VFXPatch: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var category: String
    var notes: String
    var rawSysEx: Data?
    var parameters: [String: Int]

    init(
        id: UUID = UUID(),
        name: String = "Init Patch",
        category: String = "Unsorted",
        notes: String = "",
        rawSysEx: Data? = nil,
        parameters: [String: Int] = [:]
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.notes = notes
        self.rawSysEx = rawSysEx
        self.parameters = parameters
    }
}
