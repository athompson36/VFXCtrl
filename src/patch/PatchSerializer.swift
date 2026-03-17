import Foundation

struct PatchSerializer {
    func serialize(_ patch: VFXPatch) throws -> Data {
        if let raw = patch.rawSysEx {
            return raw
        }
        throw NSError(domain: "VFXCtrl", code: -1)
    }
}
