import Foundation

enum EditorPage: String, CaseIterable, Codable {
    case wave = "Wave"
    case motion = "Motion"
    case filter = "Filter"
    case amp = "Amp"
    case mod = "Mod"
    case performance = "Perf"
    case sequencer = "Seq"
    case fx = "FX"
    case macro = "Macro"
}

final class EditorState: ObservableObject {
    @Published var selectedPage: EditorPage = .wave
    @Published var currentPatch: VFXPatch = VFXPatch()
    @Published var comparePatch: VFXPatch?
    @Published var controls: [String: Int] = [:]

    func set(_ key: String, value: Int) {
        controls[key] = value
        currentPatch.parameters[key] = value
    }

    /// Load a patch into the editor (current patch and control values).
    func loadPatch(_ patch: VFXPatch) {
        currentPatch = patch
        controls = patch.parameters
    }
}
