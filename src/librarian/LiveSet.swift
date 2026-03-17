import Foundation

struct LiveSet: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var patchIds: [UUID]

    init(id: UUID = UUID(), name: String = "New Set", patchIds: [UUID] = []) {
        self.id = id
        self.name = name
        self.patchIds = patchIds
    }
}
