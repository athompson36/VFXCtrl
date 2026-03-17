import Foundation

struct TagEngine {
    func suggestTags(for patch: VFXPatch) -> [String] {
        let name = patch.name.lowercased()
        var tags: [String] = []
        if name.contains("pad") { tags.append("pad") }
        if name.contains("bass") { tags.append("bass") }
        if name.contains("lead") { tags.append("lead") }
        return tags
    }
}
