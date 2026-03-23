import Foundation

/// FlashFloppy `FF.CFG` INI-style file (see https://github.com/keirf/FlashFloppy/wiki/FF.CFG-Configuration-File).
enum FFCfgFile {
    static let wikiURL = "https://github.com/keirf/FlashFloppy/wiki/FF.CFG-Configuration-File"

    /// Parse `key = value` lines; `#` / `;` start comments. Later duplicate keys override earlier.
    static func parse(_ text: String) -> [String: String] {
        var out: [String: String] = [:]
        for line in text.split(whereSeparator: \.isNewline) {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }
            if trimmed.hasPrefix("#") || trimmed.hasPrefix(";") { continue }
            guard let eq = trimmed.firstIndex(of: "=") else { continue }
            let key = String(trimmed[..<eq]).trimmingCharacters(in: .whitespacesAndNewlines)
            let val = String(trimmed[trimmed.index(after: eq)...]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !key.isEmpty {
                out[key] = val
            }
        }
        return out
    }

    /// Serializes entries with stable, readable ordering. Optional file header comment.
    static func encode(entries: [String: String], headerComment: String? = nil) -> String {
        let preferredOrder = [
            "nav-mode", "indexed-prefix", "host", "interface", "chgrst",
            "folder-sort", "sort-priority", "nav-loop",
            "autoselect-file-secs", "autoselect-folder-secs",
            "pin02", "pin34", "write-protect",
        ]
        var lines: [String] = []
        if let h = headerComment, !h.isEmpty {
            for l in h.split(separator: "\n", omittingEmptySubsequences: false) {
                let t = String(l).trimmingCharacters(in: .whitespaces)
                if t.isEmpty { continue }
                lines.append(t.hasPrefix("#") ? t : "# \(t)")
            }
        }
        var used = Set<String>()
        for k in preferredOrder {
            guard let v = entries[k] else { continue }
            lines.append("\(k) = \(v)")
            used.insert(k)
        }
        let rest = entries.keys.filter { !used.contains($0) }.sorted()
        for k in rest {
            if let v = entries[k] {
                lines.append("\(k) = \(v)")
            }
        }
        return lines.joined(separator: "\n") + "\n"
    }

    /// Optional OLED rows: filename (row 0) + status (row 1). Safe to merge into any FF.CFG draft.
    static func recommendedOLEDDisplayOrderHints() -> [String: String] {
        [
            "display-order": "0,1",
            "oled-font": "6x13",
        ]
    }

    /// Baseline for VFX-SD + indexed USB. Use `indexedPrefix: ""` for numeric rack files (`0000_*`). **Verify** jumpers: [Host Platforms: Ensoniq](https://github.com/keirf/FlashFloppy/wiki/Host-Platforms#ensoniq).
    static func recommendedEntries(indexedPrefix: String) -> [String: String] {
        let prefix = ExportNaming.normalizedIndexedPrefix(indexedPrefix)
        let quotedPrefix = prefix.isEmpty ? "\"\"" : "\"\(prefix)\""
        return [
            "nav-mode": "indexed",
            "indexed-prefix": quotedPrefix,
            "host": "ensoniq",
            "interface": "shugart",
            "folder-sort": "always",
            "sort-priority": "files",
            "nav-loop": "yes",
            "autoselect-file-secs": "0",
            "autoselect-folder-secs": "0",
        ]
    }

    /// Merges `recommendedEntries` into `existing` (recommended fills only missing keys unless `replaceRecommendedKeys`).
    static func mergeRecommended(
        into existing: [String: String],
        indexedPrefix: String,
        replaceRecommendedKeys: Bool
    ) -> [String: String] {
        let rec = recommendedEntries(indexedPrefix: indexedPrefix)
        var out = existing
        for (k, v) in rec {
            if replaceRecommendedKeys || out[k] == nil {
                out[k] = v
            }
        }
        return out
    }
}
