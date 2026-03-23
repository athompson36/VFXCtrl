import Foundation
import AppKit
import UniformTypeIdentifiers

enum ExportHelper {
    /// Presents a save panel and writes data to the chosen URL. Returns true if saved.
    static func saveSysEx(_ data: Data, defaultName: String) -> Bool {
        let panel = NSSavePanel()
        panel.allowedContentTypes = VFXSysExTypes.exportContentTypes
        panel.nameFieldStringValue = sanitizeFilename(defaultName)
        panel.title = "Export SysEx"
        guard panel.runModal() == .OK, let url = panel.url else { return false }
        do {
            try data.write(to: url)
            return true
        } catch {
            return false
        }
    }

    /// Single-patch export with optional Gotek-style stem (short name, no collision handling — user picks path).
    static func saveSysExGotek(
        _ data: Data,
        patchName: String,
        maxBaseNameLength: Int? = 16
    ) -> Bool {
        var stem = ExportNaming.sanitizeFilenameStem(patchName)
        if let maxL = maxBaseNameLength, maxL > 0 {
            stem = String(stem.prefix(maxL))
            if stem.isEmpty { stem = "patch" }
        }
        return saveSysEx(data, defaultName: stem + ".syx")
    }

    /// Presents a directory open panel; writes one `.syx` per patch. **Never overwrites** — colliding names get `_2`, `_3`, … before `.syx`.
    @discardableResult
    static func exportPatches(
        _ patches: [VFXPatch],
        options: ExportNaming.Options = ExportNaming.Options(),
        manifest: BankManifestWriteOptions? = nil,
        toFolderChoosingFrom window: NSWindow? = nil
    ) -> Int {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose Folder"
        panel.title = "Export Live Set"
        let result = panel.runModal()
        guard result == .OK, let dir = panel.url else { return 0 }
        return writePatches(patches, to: dir, options: options, manifest: manifest)
    }

    /// Writes patches into an existing directory (no panel). For tests / automation.
    /// When `manifest` is set, writes `bank.json` describing slot order, filenames, and hashes.
    @discardableResult
    static func writePatches(
        _ patches: [VFXPatch],
        to dir: URL,
        options: ExportNaming.Options,
        manifest: BankManifestWriteOptions? = nil
    ) -> Int {
        let root = dir.standardizedFileURL
        var records: [BankExportManifest.Slot] = []
        var count = 0
        /// Contiguous index among patches that actually wrote `.syx` (numeric prefix + manifest slots).
        var writeOrdinal = 0
        for patch in patches {
            guard let data = patch.rawSysEx else { continue }
            let baseDir: URL
            if options.flashFloppyIndexedMode {
                baseDir = dir
            } else if options.categorySubfolders {
                let sub = ExportNaming.categoryFolder(for: patch.category)
                baseDir = dir.appendingPathComponent(sub, isDirectory: true)
                try? FileManager.default.createDirectory(at: baseDir, withIntermediateDirectories: true)
            } else {
                baseDir = dir
            }
            let stem = ExportNaming.exportStem(patch: patch, index: writeOrdinal, options: options)
            let url: URL
            if options.flashFloppyIndexedMode {
                url = baseDir.appendingPathComponent(stem).appendingPathExtension("syx")
                if FileManager.default.fileExists(atPath: url.path) {
                    try? FileManager.default.removeItem(at: url)
                }
            } else {
                url = ExportNaming.uniqueSyxURL(directory: baseDir, stem: stem)
            }
            do {
                try data.write(to: url)
                count += 1
                writeOrdinal += 1
                let rel = relativePath(from: root, to: url.standardizedFileURL)
                let hash = patch.sysexSHA256 ?? SysExDigest.sha256Hex(of: data)
                records.append(
                    BankExportManifest.Slot(
                        index: writeOrdinal,
                        file: rel,
                        patchName: patch.name,
                        patchId: patch.id.uuidString,
                        sysexSHA256: hash
                    )
                )
            } catch { }
        }

        if let m = manifest, !records.isEmpty {
            let man = BankExportManifest(
                format: BankExportManifest.currentFormat,
                exportedAt: Date(),
                liveSetName: m.liveSetName,
                maxProgramsPerBank: VFXBankLimits.programsPerInternalBank,
                exportedProgramCount: records.count,
                truncatedToBankSize: m.truncatedToBankSize,
                slots: records
            )
            let enc = JSONEncoder()
            enc.outputFormatting = [.prettyPrinted, .sortedKeys]
            enc.dateEncodingStrategy = .iso8601
            if let data = try? enc.encode(man) {
                try? data.write(to: dir.appendingPathComponent("bank.json"))
            }
        }
        return count
    }

    private static func relativePath(from root: URL, to file: URL) -> String {
        let rp = root.path
        let fp = file.path
        guard fp.hasPrefix(rp) else { return file.lastPathComponent }
        var rest = fp.dropFirst(rp.count)
        if rest.first == "/" { rest.removeFirst() }
        let s = String(rest)
        return s.isEmpty ? file.lastPathComponent : s
    }

    private static func sanitizeFilename(_ s: String) -> String {
        let invalid = CharacterSet(charactersIn: ":/\\")
        let t = s.components(separatedBy: invalid).joined(separator: "_")
            .components(separatedBy: .newlines).joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
        return t.isEmpty ? "patch" : t
    }
}
