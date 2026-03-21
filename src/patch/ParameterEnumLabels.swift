import Foundation

/// Human-readable option names for discrete (enum-like) parameters. Values are contiguous from `minValue`…`maxValue`;
/// `labels[i]` corresponds to raw value `minValue + i`.
enum ParameterEnumLabels {

    /// Returns labels if this key should use a text picker in the UI; `nil` for continuous numeric parameters.
    static func labels(forKey key: String, minValue: Int, maxValue: Int) -> [String]? {
        let span = maxValue - minValue + 1
        guard span >= 1 else { return nil }

        if let generated = generatedLabels(forKey: key, minValue: minValue, maxValue: maxValue) {
            guard generated.count == span else {
                assertionFailure("ParameterEnumLabels: generated \(key) count \(generated.count) != span \(span)")
                return nil
            }
            return generated
        }

        let resolved: [String]? = {
            if let direct = table[key] { return direct }
            if modSourceKeys.contains(key) { return modSources }
            if key == "mod.dest1" || key == "mod.dest2" { return modDestinations }
            return nil
        }()

        guard let labels = resolved else { return nil }
        guard labels.count == span else {
            assertionFailure("ParameterEnumLabels: key \(key) expected \(span) labels, got \(labels.count)")
            return nil
        }
        return labels
    }

    // MARK: - Keys sharing mod source list (spec order 0…15)

    private static let modSourceKeys: Set<String> = [
        "pitch.modSrc", "filter.modSrc", "filter2.modSrc",
        "output.volModSrc", "output.panModSrc",
        "lfo.rateModSrc", "lfo.depthModSrc",
        "mod.src1", "mod.src2",
    ]

    /// VFX-SD mod sources (0–15), per PARAMETER_MAP / MIDI spec.
    private static let modSources: [String] = [
        "Off", "LFO", "Noise", "Env1", "Env2", "Env3",
        "Velocity", "Vel×Press", "Keyboard", "Pressure",
        "Pedal", "Mod Wheel", "Ext MIDI", "Mod Mixer", "Pitch Wheel", "MIDI Key",
    ]

    private static let modDestinations: [String] = [
        "Wave Start", "Pitch", "Filt1 Cut", "Filt2 Cut", "LFO Rate",
        "LFO Level", "Volume", "Pan", "Transwave", "FX Mix",
    ]

    // MARK: - Generated label strips (large ranges)

    private static func generatedLabels(forKey key: String, minValue: Int, maxValue: Int) -> [String]? {
        // Multi-key rules (Swift `case a, b where` only binds `where` to `b` — use explicit sets.)
        if ["perf.split", "perf.zonelow", "perf.zonehigh"].contains(key), minValue == 0, maxValue == 127 {
            return (0...127).map { midiNoteLabel(raw: $0) }
        }
        if key == "perf.balance", minValue == 0, maxValue == 127 {
            return (0...127).map { "Bal \($0)" }
        }
        if key == "perf.detune", minValue == 0, maxValue == 127 {
            return (0...127).map { "Det \($0)" }
        }
        if key == "perf.vellow", minValue == 0, maxValue == 127 {
            return (0...127).map { "VLo \($0)" }
        }
        if key == "perf.velhigh", minValue == 0, maxValue == 127 {
            return (0...127).map { "VHi \($0)" }
        }
        if key == "perf.transpose", minValue == 0, maxValue == 127 {
            return (0...127).map { "Xpose \($0)" }
        }
        if key == "seq.song" || key == "seq.sequence", minValue == 1, maxValue == 60 {
            return (1...60).map { "#\($0)" }
        }

        switch key {
        case "wave.select" where minValue == 0 && maxValue == 147:
            return (0...147).map { "Wave #\($0)" }
        case "wave.delay" where minValue == 0 && maxValue == 251:
            return (0..<251).map { "Dly \($0)" } + ["Key up"]
        case "sys.midiExtCtrl" where minValue == 0 && maxValue == 95:
            return (0...95).map { "CC \($0)" }
        case "sys.bendRange" where minValue == 0 && maxValue == 12:
            return (0...12).map { "\($0) st" }
        case "lfo.rate" where minValue == 0 && maxValue == 99:
            return (0...99).map { "Rate \($0)" }
        case "lfo.delay" where minValue == 0 && maxValue == 99:
            return (0...99).map { "Dly \($0)" }
        case "lfo.noiseRate" where minValue == 0 && maxValue == 127:
            return (0...127).map { "Noise \($0)" }
        case "prog.restrike" where minValue == 0 && maxValue == 99:
            return (0...99).map { "Rstk \($0)" }
        case "prog.glide" where minValue == 0 && maxValue == 99:
            return (0...99).map { "Gld \($0)" }
        case "wave.start" where minValue == 0 && maxValue == 127:
            return (0...127).map { "Start \($0)" }
        case "lfo1.rate" where minValue == 0 && maxValue == 99:
            return (0...99).map { "Rate \($0)" }
        case "fx.reverbMix" where minValue == 0 && maxValue == 99:
            return (0...99).map { "Mix \($0)" }
        case "env1.attack" where minValue == 0 && maxValue == 99:
            return (0...99).map { "E1 Atk \($0)" }
        case "env1.decay1" where minValue == 0 && maxValue == 99:
            return (0...99).map { "E1 D1 \($0)" }
        case "env1.decay2" where minValue == 0 && maxValue == 99:
            return (0...99).map { "E1 D2 \($0)" }
        case "env1.decay3" where minValue == 0 && maxValue == 99:
            return (0...99).map { "E1 D3 \($0)" }
        case "env2.attack" where minValue == 0 && maxValue == 99:
            return (0...99).map { "E2 Atk \($0)" }
        case "env2.decay1" where minValue == 0 && maxValue == 99:
            return (0...99).map { "E2 D1 \($0)" }
        case "env2.decay2" where minValue == 0 && maxValue == 99:
            return (0...99).map { "E2 D2 \($0)" }
        case "env2.decay3" where minValue == 0 && maxValue == 99:
            return (0...99).map { "E2 D3 \($0)" }
        case "env3.attack" where minValue == 0 && maxValue == 99:
            return (0...99).map { "E3 Atk \($0)" }
        case "env3.decay1" where minValue == 0 && maxValue == 99:
            return (0...99).map { "E3 D1 \($0)" }
        case "env3.decay2" where minValue == 0 && maxValue == 99:
            return (0...99).map { "E3 D2 \($0)" }
        case "env3.decay3" where minValue == 0 && maxValue == 99:
            return (0...99).map { "E3 D3 \($0)" }
        case "amp.attack" where minValue == 0 && maxValue == 99:
            return (0...99).map { "Amp Atk \($0)" }
        case "amp.decay" where minValue == 0 && maxValue == 99:
            return (0...99).map { "Amp Dec \($0)" }
        case "seq.tempo" where minValue == 1 && maxValue == 300:
            return (1...300).map { "\($0) BPM" }
        case "seq.track" where minValue == 1 && maxValue == 24:
            return (1...24).map { "Trk \($0)" }
        default:
            return nil
        }
    }

    /// MIDI note number → e.g. `C4 (60)` (middle C = 60).
    private static func midiNoteLabel(raw: Int) -> String {
        let names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let o = raw / 12 - 1
        return "\(names[raw % 12])\(o) (\(raw))"
    }

    // MARK: - Per-key tables (must match ParameterMap min/max exactly)

    private static let table: [String: [String]] = [
        // System / master
        "sys.touch": ["Off", "Soft", "Medium", "Firm", "Hard"],
        "sys.fs1": ["Unused", "Sostenuto", "Patch L", "Advance"],
        "sys.fs2": ["Sustain", "Patch R"],
        "sys.sliderMode": ["Normal", "Timbre"],
        "sys.cvPedal": ["Volume", "Mod"],
        "sys.pitchTable": ["Custom", "Normal"],
        "sys.voiceMuting": ["Off", "On"],
        "sys.xposEnable": ["Off", "On"],
        "sys.midiLoop": ["Off", "On"],
        "sys.midiSendCh": ["Base", "Track"],
        "sys.midiInMode": ["Omni", "Poly", "Multi", "Mono A", "Mono B"],
        "sys.midiTranspose": ["Send", "Receive", "Both"],
        "sys.localControl": ["Off", "On"],
        "sys.songSelect": ["Off", "On"],
        "sys.sendStartStop": ["Off", "On"],
        "sys.sysexRx": ["Off", "On"],
        // Program status: align with System page (LOCAL / MIDI / BOTH)
        "sys.midiStatus": ["Local", "MIDI", "Both"],
        "sys.midiBaseCh": (1...16).map { "Ch \($0)" },

        // Program control
        "prog.pitchTable": ["Off", "On"],
        "prog.bendRange": (0..<13).map { "\($0) st" } + ["Global"],
        "prog.delayMult": ["×1", "×2", "×4", "×8"],

        // Wave / pitch (class order per MIDI spec §5: sampled banks, Transwave, Waveform, Inharmonic, Multi-Wave, VFX-SD drum classes)
        "wave.class": [
            "Strings", "Brass", "Bass", "Breath", "Tuned Perc", "Percussion",
            "Transwave", "Waveform", "Inharmonic", "Multi-Wave",
            "Drum Sound", "Multi-Drum", "Class 12",
        ],
        "wave.direction": ["Forward", "Reverse"],
        "pitch.table": ["Off", "On", "Custom"],
        "pitch.glideMode": ["None", "Pedal", "Mono", "Legato", "Trigger"],

        // Filters (parameter label in map: "Filter #1 Type" / "Filter #2 Type" — these are the *values*)
        "filter.type": ["LP 2-pole", "LP 3-pole"],
        "filter2.type": ["HP 2-pole", "HP 1-pole", "LP 2-pole", "LP 1-pole"],

        // Output / FX routing
        "output.dest": ["Dry", "FX1", "FX2", "Aux"],
        "output.preGain": ["Off", "On"],
        "output.priority": ["Low", "Medium", "High"],

        // LFO
        "lfo.waveshape": ["Triangle", "Sine", "Sine/Tri", "+Sine", "Saw", "Square", "Noise"],
        "lfo.restart": ["Off", "On"],

        "mod.depth1": (0...15).map { "Scaler \($0)" },
        "mod.depth2": (0...15).map { "Shape \($0)" },

        // Envelopes (modes per spec)
        "env1.mode": ["Normal", "Finish", "Repeat"],
        "env2.mode": ["Normal", "Finish", "Repeat"],
        "env3.mode": ["Normal", "Finish", "Repeat"],
        "env1.velCurve": (0...9).map { "Curve \($0)" },
        "env2.velCurve": (0...9).map { "Curve \($0)" },
        "env3.velCurve": (0...9).map { "Curve \($0)" },

        // Mod mixer depths 0–15 are numeric; no table

        // Effects (0–21, names shortened from MIDI spec table)
        "fx.type": [
            "Large Hall", "Room Rev 1", "Dyn Reverb", "8-Chorus 1",
            "Chorus+Rev 1", "Flange+Rev 1", "Sm Hall", "Room Rev 2",
            "Chorus+Rev 2", "Flange+Rev 2", "Dly+Rev 1", "Dly+Rev 2",
            "FlgDly+Rev 1", "FlgDly+Rev 2", "Rotor+Dly", "Concert",
            "Warm Chamber", "Gated+Room", "Dirty Rotor", "Dyn Hall",
            "8-Chorus 2", "Dly+Flg+Hall",
        ],

        // Voice status
        "voice.status": ["Off", "On", "Solo"],
        "voice.status0": ["Off", "On", "Solo"],
        "voice.status1": ["Off", "On", "Solo"],
        "voice.status2": ["Off", "On", "Solo"],
        "voice.status3": ["Off", "On", "Solo"],
        "voice.status4": ["Off", "On", "Solo"],
        "voice.status5": ["Off", "On", "Solo"],
    ]

    /// Mod matrix pickers (`ModTwoSlotView`) — same order as MIDI spec values 0…15.
    static func modSourcePickerRows() -> [(value: Int, name: String)] {
        (0..<modSources.count).map { ($0, modSources[$0]) }
    }

    static func modDestinationPickerRows() -> [(value: Int, name: String)] {
        (0..<modDestinations.count).map { ($0, modDestinations[$0]) }
    }
}
