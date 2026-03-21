import Foundation

struct VFXPatch: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var category: String
    var notes: String
    var rawSysEx: Data?
    var parameters: [String: Int]

    /// Original filename from import (e.g. `MyPatch.syx`).
    var sourceFileName: String?
    /// When this patch was imported into the library (nil for captures / hand-made).
    var importedAt: Date?
    /// Optional synth OS string when known (e.g. from sysex/notes or user).
    var sourceSynthOS: String?
    /// SHA256 hex digest of `rawSysEx`; used for duplicate detection. Nil if no raw blob.
    var sysexSHA256: String?

    /// Set when a patch was created from `PatchParser.parseProgramDump`: checksum is not validated until the VFX-SD algorithm is implemented.
    var importIntegrityNote: String?

    init(
        id: UUID = UUID(),
        name: String = "Init Patch",
        category: String = "Unsorted",
        notes: String = "",
        rawSysEx: Data? = nil,
        parameters: [String: Int] = [:],
        sourceFileName: String? = nil,
        importedAt: Date? = nil,
        sourceSynthOS: String? = nil,
        sysexSHA256: String? = nil,
        importIntegrityNote: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.notes = notes
        self.rawSysEx = rawSysEx
        self.parameters = parameters
        self.sourceFileName = sourceFileName
        self.importedAt = importedAt
        self.sourceSynthOS = sourceSynthOS
        self.sysexSHA256 = sysexSHA256
        self.importIntegrityNote = importIntegrityNote
    }
}
