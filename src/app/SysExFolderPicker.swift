import AppKit
import Foundation

/// Choose a folder (NSOpenPanel) and list immediate `.syx` children. Security scope stays open for the `body` call.
enum SysExFolderPicker {
    /// Non-recursive listing (shallow folder, Gotek-style).
    static func presentAndCollectSyx(body: ([URL]) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose Folder"
        panel.title = "Import .syx from Folder"
        panel.message = "Select a folder containing SysEx (.syx) files (top level only)."
        guard panel.runModal() == .OK, let dir = panel.url else { return }
        guard dir.startAccessingSecurityScopedResource() else { return }
        defer { dir.stopAccessingSecurityScopedResource() }
        let fm = FileManager.default
        guard let items = try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else {
            body([])
            return
        }
        let syx = items
            .filter { $0.pathExtension.lowercased() == "syx" }
            .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
        body(syx)
    }
}
