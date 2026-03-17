import Foundation

struct VFXBank: Identifiable, Codable {
    let id = UUID()
    var name: String
    var patches: [VFXPatch]
}
