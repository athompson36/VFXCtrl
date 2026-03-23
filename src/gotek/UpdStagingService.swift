import Foundation

enum UpdStagingService {
    /// `.upd` files directly under `usbRoot` (non-recursive).
    static func listUpdInRoot(of usbRoot: URL) throws -> [URL] {
        let fm = FileManager.default
        let items = try fm.contentsOfDirectory(at: usbRoot, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        return items
            .filter { $0.pathExtension.lowercased() == "upd" }
            .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
    }

    static func removeAllUpd(inRoot usbRoot: URL) throws {
        for u in try listUpdInRoot(of: usbRoot) {
            try FileManager.default.removeItem(at: u)
        }
    }

    /// Removes existing root `*.upd` files, then copies each source into `usbRoot`. Fails if a destination name already exists after cleanup.
    static func replaceUpdOnUSB(sources: [URL], usbRoot: URL) throws {
        guard !sources.isEmpty else { return }
        try removeAllUpd(inRoot: usbRoot)
        let fm = FileManager.default
        for src in sources {
            let dest = usbRoot.appendingPathComponent(src.lastPathComponent)
            guard !fm.fileExists(atPath: dest.path) else {
                throw UpdStagingError.destinationExists(dest.lastPathComponent)
            }
            try fm.copyItem(at: src, to: dest)
        }
    }
}

enum UpdStagingError: LocalizedError {
    case destinationExists(String)

    var errorDescription: String? {
        switch self {
        case .destinationExists(let name):
            return "Could not copy: \(name) already exists on the USB root."
        }
    }
}
