import Foundation

struct CompareEngine {
    func changedKeys(current: VFXPatch, compare: VFXPatch) -> [String] {
        let keys = Set(current.parameters.keys).union(compare.parameters.keys)
        return keys.filter { current.parameters[$0] != compare.parameters[$0] }.sorted()
    }
}
