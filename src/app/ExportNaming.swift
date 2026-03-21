import Foundation

/// File / folder naming for Gotek-oriented SysEx export (see `docs/VFX_SD_Context.md`).
enum ExportNaming {

    struct Options: Equatable {
        /// Truncate patch name stem to this length (excluding `.syx`). `nil` = no limit.
        var maxBaseNameLength: Int?
        /// Prefix `01_`, `02_`, … by export order (2-digit, up to 99).
        var numericPrefix: Bool = false
        /// Place files under `00_FACTORY`, `03_PAD`, … based on `VFXPatch.category`.
        var categorySubfolders: Bool = false
    }

    /// Map editor/library category strings to shallow Gotek-style folders.
    static func categoryFolder(for category: String) -> String {
        let key = category.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if key.isEmpty { return "99_UNSORTED" }
        if let mapped = folderTable[key] { return mapped }
        for (needle, folder) in folderPrefixes {
            if key.contains(needle) { return folder }
        }
        return "99_" + sanitizeFolderSegment(category)
    }

    /// Removes path/hostile chars; collapses whitespace.
    static func sanitizeFilenameStem(_ s: String) -> String {
        let invalid = CharacterSet(charactersIn: ":/\\?*\"<>|")
        let t = s.components(separatedBy: invalid).joined(separator: "_")
            .components(separatedBy: .newlines).joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
        let collapsed = t.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return collapsed.isEmpty ? "patch" : collapsed
    }

    /// Final filename stem (no extension): optional `01_` prefix + sanitized/truncated name.
    static func exportStem(
        patch: VFXPatch,
        index: Int,
        options: Options
    ) -> String {
        var stem = sanitizeFilenameStem(patch.name)
        if let maxL = options.maxBaseNameLength, maxL > 0 {
            stem = String(stem.prefix(maxL))
            if stem.isEmpty { stem = "patch" }
        }
        if options.numericPrefix {
            return orderPrefix(for: index) + stem
        }
        return stem
    }

    /// `01_` … `99_`, then `100_` … (3-digit) for large live sets.
    static func orderPrefix(for index: Int) -> String {
        let n = index + 1
        if n < 100 { return String(format: "%02d_", n) }
        return String(format: "%03d_", n)
    }

    /// Full filename `stem.syx` that does not collide with existing files in `directory`.
    static func uniqueSyxURL(directory: URL, stem: String) -> URL {
        let ext = "syx"
        func url(for base: String) -> URL {
            directory.appendingPathComponent(base).appendingPathExtension(ext)
        }
        var candidate = url(for: stem)
        var suffix = 2
        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = url(for: "\(stem)_\(suffix)")
            suffix += 1
        }
        return candidate
    }

    // MARK: - Private

    private static let folderTable: [String: String] = [
        "unsorted": "99_UNSORTED",
        "factory": "00_FACTORY",
        "rom": "01_ROM",
        "transwave": "02_TRANSWAVE",
        "pad": "03_PAD",
        "pads": "03_PAD",
        "keys": "04_KEYS",
        "key": "04_KEYS",
        "bass": "05_BASS",
        "lead": "06_LEAD",
        "split": "07_SPLIT",
        "splits": "07_SPLIT",
        "performance": "07_SPLIT",
        "fx": "08_FX",
        "commercial": "09_COMMERCIAL",
        "archive": "10_ARCHIVE",
    ]

    /// (substring, folder) — first match wins after exact table lookup.
    private static let folderPrefixes: [(String, String)] = [
        ("factory", "00_FACTORY"),
        ("transwave", "02_TRANSWAVE"),
        ("pad", "03_PAD"),
        ("key", "04_KEYS"),
        ("bass", "05_BASS"),
        ("lead", "06_LEAD"),
        ("split", "07_SPLIT"),
        ("perform", "07_SPLIT"),
        ("commercial", "09_COMMERCIAL"),
        ("archive", "10_ARCHIVE"),
    ]

    private static func sanitizeFolderSegment(_ s: String) -> String {
        let invalid = CharacterSet.alphanumerics.inverted
        let parts = s.uppercased().components(separatedBy: invalid).filter { !$0.isEmpty }
        let slug = parts.prefix(4).joined(separator: "_")
        return slug.isEmpty ? "CUSTOM" : slug
    }
}
