import AppKit
import SwiftUI
import UniformTypeIdentifiers

/// Edit FlashFloppy `FF.CFG` text; merge recommended Ensoniq + indexed defaults.
struct FFCfgEditorView: View {
    @Binding var cfgText: String
    @State private var replaceAllRecommended = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("FF.CFG")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(VFXTheme.textPrimary)

            Text("INI-style config on the USB stick root (or FF/ subfolder if you use that layout). Keys must match the FlashFloppy wiki (e.g. autoselect-file-secs, not autoselect-file).")
                .font(.caption)
                .foregroundStyle(VFXTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Button("Apply recommended (VFX-SD rack + extended OLED)") {
                    applyRecommended()
                }
                Toggle("Replace recommended keys", isOn: $replaceAllRecommended)
                .font(.caption)
            }
            Button("Merge 128×64 OLED layout (oled-128x64, 0d,7,1, font 8×16)") {
                mergeOLEDHints()
            }
            .font(.caption)
            HStack {
                Button("Load from file…") { loadFromFile() }
                Button("Save to file…") { saveToFile() }
            }
            .font(.caption)

            TextEditor(text: $cfgText)
                .font(.body.monospaced())
                .frame(minHeight: 200)
                .scrollContentBackground(.hidden)
                .background(VFXTheme.surface)

            Link("FF.CFG reference (wiki)", destination: URL(string: FFCfgFile.wikiURL)!)
                .font(.caption)
        }
        .padding(12)
        .background(VFXTheme.surface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func applyRecommended() {
        let parsed = FFCfgFile.parse(cfgText)
        let prefix = extractIndexedPrefix(from: parsed) ?? "DSKA"
        let merged = FFCfgFile.mergeRecommended(
            into: parsed,
            indexedPrefix: prefix,
            replaceRecommendedKeys: replaceAllRecommended
        )
        cfgText = FFCfgFile.encode(
            entries: merged,
            headerComment: "VFX-CTRL: VFX-SD + SamplerZone Gotek Extended / FF 3.44 — oled-128x64, display-order 0d,7,1, oled-font 8x16, rotary full,reverse, autoselect 0. Verify jumpers (FlashFloppy Host Platforms: Ensoniq)."
        )
    }

    private func mergeOLEDHints() {
        var parsed = FFCfgFile.parse(cfgText)
        let hints = FFCfgFile.recommendedOLEDDisplayOrderHints()
        for (k, v) in hints {
            if replaceAllRecommended || parsed[k] == nil {
                parsed[k] = v
            }
        }
        cfgText = FFCfgFile.encode(
            entries: parsed,
            headerComment: nil
        )
    }

    private func extractIndexedPrefix(from entries: [String: String]) -> String? {
        guard let raw = entries["indexed-prefix"] else { return nil }
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.hasPrefix("\""), t.hasSuffix("\""), t.count >= 2 {
            return String(t.dropFirst().dropLast())
        }
        return t
    }

    private func loadFromFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.title = "Open FF.CFG"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        if let s = try? String(contentsOf: url, encoding: .utf8) {
            cfgText = s
        }
    }

    private func saveToFile() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "FF.CFG"
        panel.title = "Save FF.CFG"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        try? cfgText.data(using: .utf8)?.write(to: url)
    }
}
