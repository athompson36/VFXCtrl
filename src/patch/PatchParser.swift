import Foundation

enum PatchParserError: Error {
    case unsupported
}

struct PatchParser {
    func parseProgramDump(_ data: Data) throws -> VFXPatch {
        // TODO: replace with verified VFX-SD program dump parsing.
        return VFXPatch(name: "Captured Program", rawSysEx: data)
    }
}
