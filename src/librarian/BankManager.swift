import Foundation

// MARK: - Live set → ordered patches (editor model)

struct VFXBank: Identifiable, Codable {
    let id: UUID
    var name: String
    var patches: [VFXPatch]

    init(id: UUID = UUID(), name: String, patches: [VFXPatch] = []) {
        self.id = id
        self.name = name
        self.patches = patches
    }
}

// MARK: - VFX-SD hardware limits

enum VFXBankLimits {
    /// Internal RAM bank size (programs per bank) on VFX-SD — export / Gotek workflows.
    static let programsPerInternalBank = 60
}

// MARK: - `bank.json` next to exported `.syx` files (Phase 6.5)

struct BankExportManifest: Codable {
    static let currentFormat = "vfxctrl-bank-manifest-v1"

    /// Schema identifier.
    var format: String
    /// Export time (ISO8601 in JSON).
    var exportedAt: Date
    /// Source live set name in VFX-CTRL.
    var liveSetName: String
    /// VFX-SD programs per bank (reference).
    var maxProgramsPerBank: Int
    /// Number of `.syx` files written in this export.
    var exportedProgramCount: Int
    /// True if the set was sliced to `maxProgramsPerBank` before export.
    var truncatedToBankSize: Bool
    var slots: [Slot]

    struct Slot: Codable {
        /// 1-based order in this export folder.
        var index: Int
        /// Path relative to the export root (may include category subfolder).
        var file: String
        var patchName: String
        var patchId: String
        var sysexSHA256: String?
    }
}

/// Options for writing `bank.json` beside exported `.syx` files (`ExportHelper.writePatches`).
struct BankManifestWriteOptions: Equatable {
    var liveSetName: String
    var truncatedToBankSize: Bool
}
