import Foundation

/// FlashFloppy 3.44 **numeric** indexed rack (`VFX-RACK-BUILD-FF344`): `0000_*.IMG`, `FF.CFG` only on the stick.
/// Skips `IMG.CFG`, `IMAGE_A.CFG`, catalogs, `.upd`, and AppleDouble (`._*`).
enum GotekIndexedRackDeploy {
    /// User preference: folder containing `000*` disk images + `FF.CFG` (e.g. repo `VFX-RACK-BUILD-FF344`).
    enum FolderPreferences {
        private static let pathKey = "VFXCtrl.gotekIndexedRackFolderPath"
        private static let bookmarkKey = "VFXCtrl.gotekIndexedRackFolderBookmark"

        static func savedFolderURL() -> URL? {
            if let data = UserDefaults.standard.data(forKey: bookmarkKey) {
                var stale = false
                do {
                    let url = try URL(
                        resolvingBookmarkData: data,
                        options: [.withSecurityScope, .withoutUI],
                        relativeTo: nil,
                        bookmarkDataIsStale: &stale
                    )
                    if !stale, FileManager.default.fileExists(atPath: url.path) {
                        return url.standardizedFileURL
                    }
                } catch {
                    UserDefaults.standard.removeObject(forKey: bookmarkKey)
                }
            }
            guard let s = UserDefaults.standard.string(forKey: pathKey)?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !s.isEmpty
            else { return nil }
            var isDir: ObjCBool = false
            guard FileManager.default.fileExists(atPath: s, isDirectory: &isDir), isDir.boolValue else { return nil }
            return URL(fileURLWithPath: s, isDirectory: true)
        }

        static func setSavedFolderURL(_ url: URL?) {
            if let url {
                let std = url.standardizedFileURL
                UserDefaults.standard.set(std.path, forKey: pathKey)
                do {
                    let data = try std.bookmarkData(
                        options: .withSecurityScope,
                        includingResourceValuesForKeys: nil,
                        relativeTo: nil
                    )
                    UserDefaults.standard.set(data, forKey: bookmarkKey)
                } catch {
                    UserDefaults.standard.removeObject(forKey: bookmarkKey)
                }
            } else {
                UserDefaults.standard.removeObject(forKey: pathKey)
                UserDefaults.standard.removeObject(forKey: bookmarkKey)
            }
        }
    }

    /// `true` for files that belong on the Gotek stick root for this rack (flat layout).
    static func isDeployableFileName(_ name: String) -> Bool {
        if name.hasPrefix("._") || name == ".DS_Store" { return false }
        let lower = name.lowercased()
        if lower == "ff.cfg" { return true }
        guard name.count >= 9, name[name.startIndex].isNumber else { return false }
        let four = name.prefix(4)
        guard four.allSatisfy(\.isNumber) else { return false }
        guard name[name.index(name.startIndex, offsetBy: 4)] == "_" else { return false }
        return lower.hasSuffix(".hfe") || lower.hasSuffix(".img")
    }

    /// Sorted deployable file URLs directly under `sourceDir` (not recursive).
    static func deployableFileURLs(in sourceDir: URL) throws -> [URL] {
        let fm = FileManager.default
        let contents = try fm.contentsOfDirectory(
            at: sourceDir,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        return contents.filter { url in
            let isFile = (try? url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) ?? false
            guard isFile else { return false }
            return isDeployableFileName(url.lastPathComponent)
        }.sorted {
            $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending
        }
    }

    /// Files in `sourceDir` that are not copied (for UI summary).
    static func nonDeployableFileNames(in sourceDir: URL) throws -> [String] {
        let fm = FileManager.default
        let contents = try fm.contentsOfDirectory(
            at: sourceDir,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        var skipped: [String] = []
        for url in contents {
            let isFile = (try? url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) ?? false
            guard isFile else { continue }
            let n = url.lastPathComponent
            if !isDeployableFileName(n) { skipped.append(n) }
        }
        return skipped.sorted()
    }

    struct CopyResult: Sendable {
        let copiedFileNames: [String]
        let skippedOtherFileCount: Int
    }

    /// Copies allowlisted files to `destinationRoot` (overwrites same basename). Does not delete unrelated files on the USB stick.
    static func copyDeployableFiles(from sourceDir: URL, to destinationRoot: URL) throws -> CopyResult {
        let files = try deployableFileURLs(in: sourceDir)
        guard !files.isEmpty else {
            throw DeployError.noDeployableFiles
        }
        let fm = FileManager.default
        var names: [String] = []
        for src in files {
            let base = src.lastPathComponent
            let dest = destinationRoot.appendingPathComponent(base)
            if fm.fileExists(atPath: dest.path) {
                try fm.removeItem(at: dest)
            }
            try fm.copyItem(at: src, to: dest)
            names.append(base)
        }
        let skipped = try nonDeployableFileNames(in: sourceDir).count
        return CopyResult(copiedFileNames: names, skippedOtherFileCount: skipped)
    }
}

enum DeployError: LocalizedError {
    case noDeployableFiles

    var errorDescription: String? {
        switch self {
        case .noDeployableFiles:
            return "No deployable files found (expected 0000_*.HFE / 0000_*.IMG and FF.CFG in the chosen folder)."
        }
    }
}
