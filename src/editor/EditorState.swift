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
    case system = "System"
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
    "sys.masterVol", "sys.tune", "sys.touch",
    "sys.midiBaseCh", "sys.midiInMode", "sys.localControl", "sys.sysexRx", "sys.xposEnable", "sys.midiStatus",
    "sys.pitchTable", "sys.diskType",
]

final class EditorState: ObservableObject {
    @Published var selectedPage: EditorPage = .wave
    @Published var comparePatch: VFXPatch?
    @Published var snapshots: [VFXPatch] = []

    // Not @Published — mutations during slider drag must not fire objectWillChange
    // on every tick. We call objectWillChange.send() manually, throttled.
    var currentPatch: VFXPatch = VFXPatch()
    var controls: [String: Int] = [:]

    var onLiveParameterChange: ((String, Int) -> Void)?

    static let liveEditEnabledKey = "VFXCtrl.liveEditEnabled"

    private static let liveThrottleInterval: CFAbsoluteTime = 0.05
    private var lastLiveSendTime: CFAbsoluteTime = 0
    private var liveTrailingWork: DispatchWorkItem?

    func set(_ key: String, value: Int) {
        LiveDebugLog.log("EditorState.set(\(key)=\(value)) START")
        let oldValue = controls[key]
        guard oldValue != value else {
            LiveDebugLog.log("EditorState.set SKIP (unchanged)")
            return
        }

        controls[key] = value
        currentPatch.parameters[key] = value
        if MacroEngine.macroKeys.contains(key) {
            MacroEngine().apply(key, value: value, to: &currentPatch)
            for (k, v) in currentPatch.parameters { controls[k] = v }
        }

        objectWillChange.send()

        let liveOn = UserDefaults.standard.bool(forKey: Self.liveEditEnabledKey)
        if liveOn, onLiveParameterChange != nil, LiveSysExBuilder.supportedLiveKeys.contains(key) {
            scheduleLiveSend(key: key, value: value)
        }
        LiveDebugLog.log("EditorState.set(\(key)) END")
    }

    private func scheduleLiveSend(key: String, value: Int) {
        liveTrailingWork?.cancel()
        let now = CFAbsoluteTimeGetCurrent()
        if now - lastLiveSendTime >= Self.liveThrottleInterval {
            lastLiveSendTime = now
            LiveDebugLog.log("EditorState.scheduleLiveSend INVOKE NOW \(key)=\(value)")
            onLiveParameterChange?(key, value)
        } else {
            let delay = Self.liveThrottleInterval - (now - lastLiveSendTime)
            let work = DispatchWorkItem { [weak self] in
                guard let self else { return }
                LiveDebugLog.log("EditorState.scheduleLiveSend INVOKE DEFERRED \(key)=\(value)")
                self.lastLiveSendTime = CFAbsoluteTimeGetCurrent()
                self.onLiveParameterChange?(key, value)
                self.liveTrailingWork = nil
            }
            liveTrailingWork = work
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
        }
    }

    func loadPatch(_ patch: VFXPatch) {
        currentPatch = patch
        var c = patch.parameters
        for key in allPageControlKeys where c[key] == nil {
            c[key] = 0
        }
        if c["seq.song"] == nil || c["seq.song"]! < 1 || c["seq.song"]! > 60 { c["seq.song"] = 1 }
        if c["seq.sequence"] == nil || c["seq.sequence"]! < 1 || c["seq.sequence"]! > 60 { c["seq.sequence"] = 1 }
        if c["seq.track"] == nil || c["seq.track"]! < 1 || c["seq.track"]! > 24 { c["seq.track"] = 1 }
        controls = c
        objectWillChange.send()
    }

    func addSnapshot() {
        let copy = VFXPatch(id: UUID(), name: "Snapshot \(snapshotDateString())", category: currentPatch.category, notes: currentPatch.notes, rawSysEx: currentPatch.rawSysEx, parameters: currentPatch.parameters)
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
