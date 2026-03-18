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

/// All control keys used by the 9 editor pages (per UI_PAGES.md).
private let allPageControlKeys: [String] = [
    "wave.select", "wave.coarse", "wave.fine", "wave.octave", "wave.level", "wave.velocity", "wave.keytrack", "wave.pan",
    "motion.position", "motion.amount", "motion.source", "lfo1.rate", "lfo1.depth", "lfo2.rate", "modwheel.depth", "aftertouch.depth",
    "filter.cutoff", "filter.resonance", "filter.env", "filter.velocity", "filter.keytrack", "filter.mode", "filter.source", "filter.alt",
    "amp.attack", "amp.decay", "amp.sustain", "amp.release", "amp.velocity", "amp.level", "amp.keyscale", "amp.alt",
    "mod.src1", "mod.dest1", "mod.depth1", "mod.src2", "mod.dest2", "mod.depth2", "mod.pedal", "mod.pressure",
    "perf.split", "perf.balance", "perf.detune", "perf.zonelow", "perf.zonehigh", "perf.vellow", "perf.velhigh", "perf.transpose",
    "seq.tempo", "seq.song", "seq.sequence", "seq.track", "seq.loop", "seq.quant", "seq.click", "seq.mode", "seq.tap",
    "seq.clockSource", "seq.punchIn", "seq.punchOut",
    "fx.type", "fx.mix", "fx.time", "fx.feedback", "fx.depth", "fx.rate", "fx.tone", "fx.alt",
    "macro.brightness", "macro.motion", "macro.weight", "macro.attack", "macro.space", "macro.width", "macro.dirt", "macro.animate",
]

final class EditorState: ObservableObject {
    @Published var selectedPage: EditorPage = .wave
    @Published var currentPatch: VFXPatch = VFXPatch()
    @Published var comparePatch: VFXPatch?
    @Published var controls: [String: Int] = [:]
    @Published var snapshots: [VFXPatch] = []

    func set(_ key: String, value: Int) {
        controls[key] = value
        currentPatch.parameters[key] = value
        if MacroEngine.macroKeys.contains(key) {
            var p = currentPatch
            MacroEngine().apply(key, value: value, to: &p)
            currentPatch = p
            for (k, v) in p.parameters { controls[k] = v }
        }
    }

    /// Load a patch into the editor (current patch and control values).
    /// Ensures every page control key has a value (default 0) so encoders display correctly.
    func loadPatch(_ patch: VFXPatch) {
        currentPatch = patch
        var c = patch.parameters
        for key in allPageControlKeys where c[key] == nil {
            c[key] = 0
        }
        controls = c
    }

    func addSnapshot() {
        var copy = currentPatch
        copy = VFXPatch(id: UUID(), name: "Snapshot \(snapshotDateString())", category: copy.category, notes: copy.notes, rawSysEx: copy.rawSysEx, parameters: copy.parameters)
        snapshots.append(copy)
    }

    func removeSnapshot(at offsets: IndexSet) {
        snapshots.remove(atOffsets: offsets)
    }

    func restoreSnapshot(_ patch: VFXPatch) {
        loadPatch(patch)
    }

    private func snapshotDateString() -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: Date())
    }
}
