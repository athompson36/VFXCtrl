import UniformTypeIdentifiers

/// Shared UTType usage for SysEx / `.syx` (Phase 6.7).
enum VFXSysExTypes {
    /// Best-effort type for `.syx`; falls back to generic data.
    static var syx: UTType {
        UTType(filenameExtension: "syx") ?? .data
    }

    /// Importers should accept declared `.syx` and generic data (unknown extensions).
    static var importContentTypes: [UTType] { [syx, .data] }

    /// Save / export panels prefer `.syx` with data fallback.
    static var exportContentTypes: [UTType] { [syx, .data] }
}
