import Foundation
import AppKit
import UniformTypeIdentifiers

enum ExportHelper {
    /// Presents a save panel and writes data to the chosen URL. Returns true if saved.
    static func saveSysEx(_ data: Data, defaultName: String) -> Bool {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.data]
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

    /// Presents a directory open panel; writes one .syx file per patch (using rawSysEx) into the chosen folder. Returns count written.
    static func exportPatches(_ patches: [VFXPatch], toFolderChoosingFrom window: NSWindow? = nil) -> Int {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose Folder"
        panel.title = "Export Live Set"
        let result = panel.runModal()
        guard result == .OK, let dir = panel.url else { return 0 }
        var count = 0
        for patch in patches {
            guard let data = patch.rawSysEx else { continue }
            let name = sanitizeFilename(patch.name) + ".syx"
            let url = dir.appendingPathComponent(name)
            do {
                try data.write(to: url)
                count += 1
            } catch { }
        }
        return count
    }

    private static func sanitizeFilename(_ s: String) -> String {
        let invalid = CharacterSet(charactersIn: ":/\\")
        let t = s.components(separatedBy: invalid).joined(separator: "_")
            .components(separatedBy: .newlines).joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
        return t.isEmpty ? "patch" : t
    }
}
