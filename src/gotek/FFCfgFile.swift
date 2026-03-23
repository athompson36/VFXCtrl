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
            "pin02", "pin34", "write-protect",
            "ejected-on-startup", "image-on-startup",
            "display-type", "oled-font", "display-order",
            "display-off-secs", "display-on-activity",
            "display-scroll-rate", "display-scroll-pause",
            "nav-scroll-rate", "nav-scroll-pause",
            "folder-sort", "sort-priority", "nav-loop",
            "autoselect-file-secs", "autoselect-folder-secs",
            "twobutton-action", "rotary",
            "motor-delay", "track-change", "write-drain", "head-settle-ms",
            "step-volume", "extend-image",
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

    /// SamplerZone-style **128×64** OLED: `0d,7,1` = **double-height** image name (32 px), blank 16 px band, status on the **bottom** 16 px.
    /// FlashFloppy cannot split the FAT name at an underscore (one string → row 0 only); see `docs/GOTEK_OLED_LAYOUT_LIMITS.md`.
    static func recommendedOLEDDisplayOrderHints() -> [String: String] {
        [
            "display-type": "oled-128x64",
            "display-order": "0d,7,1",
            "oled-font": "8x16",
        ]
    }

    /// Baseline for **Ensoniq VFX-SD** + **SamplerZone Gotek Extended** (34×19 mm OLED, rotary) + FlashFloppy **3.44** indexed rack.
    ///
    /// Uses only options documented in the [FF.CFG wiki](https://github.com/keirf/FlashFloppy/wiki/FF.CFG-Configuration-File): there is no `display-nav-name` / `autoselect-file` key — use `display-order` and `autoselect-*-secs`.
    /// - **128×64 OLED:** `display-type = oled-128x64` and `display-order = 0d,7,1` — **`0d`** = double-height **filename** (top half, 8×16 font), **`7`** = spacer, **`1`** = slot/type line on the **lowest** 16 px. (`0,7,1` leaves a padded blank row *below* status so the slot line is not on the physical bottom.) Stock FlashFloppy cannot put “before/after last `_`” on two name rows; see `docs/GOTEK_OLED_LAYOUT_LIMITS.md`.
    /// - **Manual mount while browsing:** `autoselect-file-secs` / `autoselect-folder-secs` = `0`. `ejected-on-startup = no` + `image-on-startup = init` starts on the **normal** nav screen with the first image selected so the **disk name** is visible (not stuck in eject-menu layout); eject with buttons when you want no disk.
    /// - **Readability:** `oled-font = 8x16` (bolder / less “dot-matrix” than 6×13; fewer characters per line). Slower filename scroll in ms; `display-off-secs = 255` keeps the panel on.
    /// - **Rotary:** `rotary = full,reverse` — full Gray-code stepping with **direction swapped** so clockwise advances slot number (use plain `full` if your wiring is already correct).
    ///
    /// Use `indexedPrefix: ""` for numeric rack files (`0000_*`). **Verify** jumpers: [Host Platforms: Ensoniq](https://github.com/keirf/FlashFloppy/wiki/Host-Platforms#ensoniq).
    static func recommendedEntries(indexedPrefix: String) -> [String: String] {
        let prefix = ExportNaming.normalizedIndexedPrefix(indexedPrefix)
        let quotedPrefix = prefix.isEmpty ? "\"\"" : "\"\(prefix)\""
        return [
            "nav-mode": "indexed",
            "indexed-prefix": quotedPrefix,
            "host": "ensoniq",
            "interface": "shugart",
            "pin02": "auto",
            "pin34": "ready",
            "write-protect": "no",
            "ejected-on-startup": "no",
            "image-on-startup": "init",
            "display-type": "oled-128x64",
            "oled-font": "8x16",
            "display-order": "0d,7,1",
            "display-off-secs": "255",
            "display-on-activity": "yes",
            "autoselect-file-secs": "0",
            "autoselect-folder-secs": "0",
            "folder-sort": "always",
            "sort-priority": "files",
            "nav-loop": "yes",
            "twobutton-action": "zero",
            "rotary": "full,reverse",
            "motor-delay": "200",
            "track-change": "instant",
            "write-drain": "instant",
            "head-settle-ms": "12",
            "chgrst": "delay-3",
            "display-scroll-rate": "400",
            "display-scroll-pause": "1800",
            "nav-scroll-rate": "180",
            "nav-scroll-pause": "800",
            "step-volume": "10",
            "extend-image": "yes",
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
