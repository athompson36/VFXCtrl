import Foundation

/// Builds MIDI messages for live parameter edits on the Ensoniq VFX-SD.
///
/// Uses the official VFX-SD MIDI Implementation Specification v2.00:
/// - SysEx Parameter Change = Message Type 00, Command Type 01
/// - Data bytes are nibblized (8-bit -> two 4-bit nibble bytes)
/// - Parameters addressed by voice [0..5], page [0..31], slot [0..5]
/// - Master volume uses MIDI CC 7 (not a SysEx page/slot parameter)
///
/// See docs/Ensoniq VFX-SD MIDI Implementation Specification v2.00.md, sections 2–5.
enum LiveSysExBuilder {

    // MARK: - Constants

    private static let sysexStart: UInt8 = 0xF0
    private static let sysexEnd: UInt8 = 0xF7
    private static let ensoniqId: UInt8 = 0x0F
    private static let vfxFamilyId: UInt8 = 0x05
    private static let vfxsdModelId: UInt8 = 0x00
    private static let messageTypeCommand: UInt8 = 0x00
    private static let commandTypeParamChange: UInt8 = 0x01
    private static let commandTypeVirtualButton: UInt8 = 0x00

    // MARK: - Public API

    /// All parameter keys that support live editing.
    static var supportedLiveKeys: Set<String> {
        Set(parameterAddressTable.keys).union(ccParameterKeys).union(virtualButtonKeys)
    }

    /// Keys handled via MIDI CC rather than SysEx.
    static let ccParameterKeys: Set<String> = ["sys.masterVol"]

    /// Keys handled via Virtual Button commands.
    static let virtualButtonKeys: Set<String> = [
        "seq.play", "seq.stop", "seq.record"
    ]

    /// Result of building a live message — either SysEx data or a short MIDI CC message.
    enum LiveMessage {
        case sysex(Data)
        case cc(channel: UInt8, controller: UInt8, value: UInt8)
        case virtualButton(Data)
    }

    /// Builds a MIDI message for the given key and value.
    /// Returns nil if the key is not supported for live editing.
    static func buildMessage(key: String, value: Int, voice: Int = 0, channel: Int = 0) -> LiveMessage? {
        if ccParameterKeys.contains(key) {
            return buildCC(key: key, value: value, channel: channel)
        }
        if virtualButtonKeys.contains(key) {
            return buildVirtualButton(key: key, channel: channel)
        }
        if let addr = parameterAddressTable[key] {
            let data = buildParameterChange(
                voice: voice,
                page: addr.page,
                slot: addr.slot,
                valueHi: addr.hiByteValue?(value) ?? 0,
                valueLo: addr.loByteValue?(value) ?? UInt8(clamped: value, min: addr.min, max: addr.max),
                channel: channel
            )
            return .sysex(data)
        }
        return nil
    }

    /// Legacy compatibility: builds raw Data for SysEx keys only (returns nil for CC/button keys).
    static func build(key: String, value: Int, voice: Int = 0, channel: Int = 0) -> Data? {
        switch buildMessage(key: key, value: value, voice: voice, channel: channel) {
        case .sysex(let data): return data
        case .virtualButton(let data): return data
        default: return nil
        }
    }

    // MARK: - SysEx Parameter Change (Command Type 01)

    /// Builds a complete SysEx Parameter Change message per spec section 3.1.2.
    /// Format: F0 0F 05 00 [ch] 00 {nibblized: cmdType voice page slot valHi valLo} F7
    static func buildParameterChange(
        voice: Int, page: Int, slot: Int,
        valueHi: UInt8 = 0, valueLo: UInt8,
        channel: Int = 0
    ) -> Data {
        var bytes: [UInt8] = [
            sysexStart,
            ensoniqId,
            vfxFamilyId,
            vfxsdModelId,
            UInt8(channel & 0x0F),
            messageTypeCommand
        ]
        appendNibblized(&bytes, commandTypeParamChange)
        appendNibblized(&bytes, UInt8(voice & 0x07))
        appendNibblized(&bytes, UInt8(page & 0x1F))
        appendNibblized(&bytes, UInt8(slot & 0x07))
        appendNibblized(&bytes, valueHi)
        appendNibblized(&bytes, valueLo)
        bytes.append(sysexEnd)
        return Data(bytes)
    }

    // MARK: - Virtual Button Command (Command Type 00)

    /// Builds a Virtual Button press + release SysEx pair per spec section 3.1.1.
    /// Button down = number, button up = number + 96.
    static func buildVirtualButtonPair(buttonNumber: Int, channel: Int = 0) -> [Data] {
        [buildVirtualButtonData(buttonNumber: buttonNumber, channel: channel),
         buildVirtualButtonData(buttonNumber: buttonNumber + 96, channel: channel)]
    }

    private static func buildVirtualButtonData(buttonNumber: Int, channel: Int) -> Data {
        var bytes: [UInt8] = [
            sysexStart, ensoniqId, vfxFamilyId, vfxsdModelId,
            UInt8(channel & 0x0F), messageTypeCommand
        ]
        appendNibblized(&bytes, commandTypeVirtualButton)
        appendNibblized(&bytes, UInt8(buttonNumber & 0x7F))
        bytes.append(sysexEnd)
        return Data(bytes)
    }

    // MARK: - MIDI CC

    private static func buildCC(key: String, value: Int, channel: Int) -> LiveMessage? {
        switch key {
        case "sys.masterVol":
            return .cc(
                channel: UInt8(channel & 0x0F),
                controller: 7,
                value: UInt8(clamped: value, min: 0, max: 127)
            )
        default:
            return nil
        }
    }

    // MARK: - Virtual Button dispatch

    private static func buildVirtualButton(key: String, channel: Int) -> LiveMessage? {
        let buttonNumber: Int?
        switch key {
        case "seq.play":   buttonNumber = 91
        case "seq.stop":   buttonNumber = 92
        case "seq.record": buttonNumber = 89
        default: buttonNumber = nil
        }
        guard let btn = buttonNumber else { return nil }
        var combined = Data()
        for msg in buildVirtualButtonPair(buttonNumber: btn, channel: channel) {
            combined.append(msg)
        }
        return .virtualButton(combined)
    }

    // MARK: - Nibblization (spec section 2.3)

    /// Converts an 8-bit byte to two nibblized MIDI bytes and appends them.
    /// Hi nibble first, lo nibble second.
    private static func appendNibblized(_ bytes: inout [UInt8], _ value: UInt8) {
        bytes.append((value >> 4) & 0x0F)
        bytes.append(value & 0x0F)
    }

    // MARK: - Parameter Address Table (from spec section 5)

    struct ParamAddress {
        let page: Int
        let slot: Int
        let min: Int
        let max: Int
        /// For parameters that use the hi byte of the value word (e.g. key ranges).
        var hiByteValue: ((Int) -> UInt8)? = nil
        /// Custom lo byte transform. If nil, value is clamped to min..max.
        var loByteValue: ((Int) -> UInt8)? = nil
    }

    /// Maps UI parameter keys to VFX-SD page/slot addresses.
    /// Per spec: "the highest slot number should be used when multiple are listed."
    static let parameterAddressTable: [String: ParamAddress] = {
        var t: [String: ParamAddress] = [:]

        // -- System / Master (pages 0-2) --
        t["sys.tune"]       = .init(page: 0, slot: 0, min: 0, max: 255)  // -128..+127 as unsigned
        t["sys.touch"]      = .init(page: 0, slot: 1, min: 0, max: 4)
        t["sys.bendRange"]  = .init(page: 0, slot: 2, min: 0, max: 12)
        t["sys.fs1"]        = .init(page: 0, slot: 4, min: 0, max: 3)
        t["sys.fs2"]        = .init(page: 0, slot: 5, min: 0, max: 1)
        t["sys.sliderMode"] = .init(page: 1, slot: 0, min: 0, max: 1)
        t["sys.cvPedal"]    = .init(page: 1, slot: 1, min: 0, max: 1)
        t["sys.pitchTable"] = .init(page: 1, slot: 3, min: 0, max: 1)
        t["sys.maxVelocity"] = .init(page: 1, slot: 4, min: 0, max: 127)
        t["sys.voiceMuting"] = .init(page: 2, slot: 2, min: 0, max: 1)
        t["sys.diskType"]   = .init(page: 2, slot: 4, min: 0, max: 127)
        t["sys.xposEnable"] = .init(page: 2, slot: 5, min: 0, max: 1)

        // -- MIDI Control (pages 3-4) --
        t["sys.midiBaseCh"]   = .init(page: 3, slot: 0, min: 0, max: 15)
        t["sys.midiLoop"]     = .init(page: 3, slot: 1, min: 0, max: 1)
        t["sys.midiSendCh"]   = .init(page: 3, slot: 2, min: 0, max: 1)
        t["sys.midiInMode"]   = .init(page: 3, slot: 3, min: 0, max: 4)
        t["sys.midiTranspose"] = .init(page: 3, slot: 4, min: 0, max: 2)
        t["sys.midiExtCtrl"]  = .init(page: 3, slot: 5, min: 0, max: 95)
        t["sys.localControl"] = .init(page: 4, slot: 0, min: 0, max: 1)
        t["sys.songSelect"]   = .init(page: 4, slot: 1, min: 0, max: 1)
        t["sys.sendStartStop"] = .init(page: 4, slot: 2, min: 0, max: 1)
        t["sys.sysexRx"]      = .init(page: 4, slot: 3, min: 0, max: 1)
        t["sys.midiStatus"]   = .init(page: 4, slot: 5, min: 0, max: 2)

        // -- Program Control (page 5) --
        t["prog.pitchTable"]  = .init(page: 5, slot: 0, min: 0, max: 1)
        t["prog.bendRange"]   = .init(page: 5, slot: 1, min: 0, max: 13)
        t["prog.delayMult"]   = .init(page: 5, slot: 2, min: 0, max: 3)
        t["prog.restrike"]    = .init(page: 5, slot: 4, min: 0, max: 99)
        t["prog.glide"]       = .init(page: 5, slot: 5, min: 0, max: 99)

        // -- Mod Mixer (page 6) --
        t["mod.src1"]    = .init(page: 6, slot: 1, min: 0, max: 15)
        t["mod.src2"]    = .init(page: 6, slot: 2, min: 0, max: 15)
        t["mod.depth1"]  = .init(page: 6, slot: 4, min: 0, max: 15) // Scaler
        t["mod.depth2"]  = .init(page: 6, slot: 5, min: 0, max: 15) // Shape

        // -- Wave (pages 7-10, page depends on wave class) --
        t["wave.select"]    = .init(page: 7, slot: 0, min: 0, max: 147)
        t["wave.class"]     = .init(page: 7, slot: 1, min: 0, max: 12)
        t["wave.delay"]     = .init(page: 7, slot: 2, min: 0, max: 251)
        t["wave.start"]     = .init(page: 7, slot: 3, min: 0, max: 127)
        t["wave.velStart"]  = .init(page: 7, slot: 4, min: 0, max: 255) // -127..+127
        t["wave.direction"] = .init(page: 7, slot: 5, min: 0, max: 1)

        // -- Pitch (page 11) --
        t["pitch.octave"]    = .init(page: 11, slot: 0, min: 0, max: 255) // -4..+4
        t["pitch.semitone"]  = .init(page: 11, slot: 1, min: 0, max: 255) // -12..+12
        t["pitch.fine"]      = .init(page: 11, slot: 2, min: 0, max: 255) // -127..+127
        t["pitch.table"]     = .init(page: 11, slot: 4, min: 0, max: 2)

        // -- Pitch Mod (page 12) --
        t["pitch.modSrc"]    = .init(page: 12, slot: 1, min: 0, max: 15)
        t["pitch.modAmt"]    = .init(page: 12, slot: 2, min: 0, max: 255) // -99..+99
        t["pitch.glideMode"] = .init(page: 12, slot: 3, min: 0, max: 4)
        t["pitch.env1Mod"]   = .init(page: 12, slot: 4, min: 0, max: 255) // -127..+127
        t["pitch.lfoMod"]    = .init(page: 12, slot: 5, min: 0, max: 255) // -127..+127

        // -- Filter #1 (page 13) --
        t["filter.type"]     = .init(page: 13, slot: 0, min: 0, max: 1)  // LO-PASS/2, LO-PASS/3
        t["filter.cutoff"]   = .init(page: 13, slot: 1, min: 0, max: 127)
        t["filter.keytrack"] = .init(page: 13, slot: 2, min: 0, max: 255) // -127..+127
        t["filter.modSrc"]   = .init(page: 13, slot: 3, min: 0, max: 15)
        t["filter.modAmt"]   = .init(page: 13, slot: 5, min: 0, max: 255) // -127..+127
        t["filter.env"]      = .init(page: 13, slot: 4, min: 0, max: 255) // Env2 Mod -127..+127

        // -- Filter #2 (page 14) --
        t["filter2.type"]     = .init(page: 14, slot: 0, min: 0, max: 3)
        t["filter2.cutoff"]   = .init(page: 14, slot: 1, min: 0, max: 127)
        t["filter2.keytrack"] = .init(page: 14, slot: 2, min: 0, max: 255)
        t["filter2.modSrc"]   = .init(page: 14, slot: 3, min: 0, max: 15)
        t["filter2.modAmt"]   = .init(page: 14, slot: 4, min: 0, max: 255)
        t["filter2.env"]      = .init(page: 14, slot: 5, min: 0, max: 255)

        // -- Output (pages 15-17) --
        t["output.volume"]     = .init(page: 15, slot: 0, min: 0, max: 127)
        t["output.volModSrc"]  = .init(page: 15, slot: 1, min: 0, max: 15)
        t["output.volModAmt"]  = .init(page: 15, slot: 2, min: 0, max: 255)
        t["output.keyScale"]   = .init(page: 15, slot: 3, min: 0, max: 255) // -128..+127
        t["output.dest"]       = .init(page: 16, slot: 1, min: 0, max: 3) // DRY,FX1,FX2,AUX
        t["output.pan"]        = .init(page: 16, slot: 2, min: 0, max: 127)
        t["output.panModSrc"]  = .init(page: 16, slot: 3, min: 0, max: 15)
        t["output.panModAmt"]  = .init(page: 16, slot: 4, min: 0, max: 255)
        t["output.preGain"]    = .init(page: 16, slot: 5, min: 0, max: 1)
        t["output.priority"]   = .init(page: 17, slot: 2, min: 0, max: 2)
        t["output.velThresh"]  = .init(page: 17, slot: 4, min: 0, max: 255) // -127..+127

        // -- LFO (pages 18-19) --
        t["lfo.rate"]         = .init(page: 18, slot: 0, min: 0, max: 99)
        t["lfo.rateModSrc"]   = .init(page: 18, slot: 1, min: 0, max: 15)
        t["lfo.rateModAmt"]   = .init(page: 18, slot: 2, min: 0, max: 255) // -127..+127
        t["lfo.depth"]        = .init(page: 18, slot: 3, min: 0, max: 127)
        t["lfo.depthModSrc"]  = .init(page: 18, slot: 4, min: 0, max: 15)
        t["lfo.delay"]        = .init(page: 18, slot: 5, min: 0, max: 99)
        t["lfo.waveshape"]    = .init(page: 19, slot: 1, min: 0, max: 6)
        t["lfo.restart"]      = .init(page: 19, slot: 2, min: 0, max: 1)
        t["lfo.noiseRate"]    = .init(page: 19, slot: 5, min: 0, max: 127)

        // Simplified aliases for UI page keys
        t["lfo1.rate"]        = t["lfo.rate"]!
        t["lfo1.depth"]       = t["lfo.depth"]!

        // -- Env1 / Amplitude (pages 20-22) --
        t["env1.initLevel"]   = .init(page: 20, slot: 1, min: 0, max: 127)
        t["env1.peakLevel"]   = .init(page: 20, slot: 2, min: 0, max: 127)
        t["env1.bp1Level"]    = .init(page: 20, slot: 3, min: 0, max: 127)
        t["env1.bp2Level"]    = .init(page: 20, slot: 4, min: 0, max: 127)
        t["env1.susLevel"]    = .init(page: 20, slot: 5, min: 0, max: 127)
        t["env1.attack"]      = .init(page: 21, slot: 1, min: 0, max: 99)
        t["env1.decay1"]      = .init(page: 21, slot: 2, min: 0, max: 99)
        t["env1.decay2"]      = .init(page: 21, slot: 3, min: 0, max: 99)
        t["env1.decay3"]      = .init(page: 21, slot: 4, min: 0, max: 99)
        t["env1.release"]     = .init(page: 21, slot: 5, min: 0, max: 255) // -100..+99
        t["env1.kbdTrack"]    = .init(page: 22, slot: 0, min: 0, max: 255)
        t["env1.velCurve"]    = .init(page: 22, slot: 2, min: 0, max: 9)
        t["env1.mode"]        = .init(page: 22, slot: 3, min: 0, max: 2)
        t["env1.lvlVelSens"]  = .init(page: 22, slot: 4, min: 0, max: 127)
        t["env1.atkVelSens"]  = .init(page: 22, slot: 5, min: 0, max: 127)

        // Simplified aliases for Amp page
        t["amp.attack"]       = t["env1.attack"]!
        t["amp.decay"]        = t["env1.decay1"]!
        t["amp.sustain"]      = t["env1.susLevel"]!
        t["amp.release"]      = t["env1.release"]!
        t["amp.velocity"]     = t["env1.lvlVelSens"]!
        t["amp.level"]        = t["output.volume"]!

        // -- Env2 (pages 23-25) --
        t["env2.initLevel"]   = .init(page: 23, slot: 1, min: 0, max: 127)
        t["env2.peakLevel"]   = .init(page: 23, slot: 2, min: 0, max: 127)
        t["env2.bp1Level"]    = .init(page: 23, slot: 3, min: 0, max: 127)
        t["env2.bp2Level"]    = .init(page: 23, slot: 4, min: 0, max: 127)
        t["env2.susLevel"]    = .init(page: 23, slot: 5, min: 0, max: 127)
        t["env2.attack"]      = .init(page: 24, slot: 1, min: 0, max: 99)
        t["env2.decay1"]      = .init(page: 24, slot: 2, min: 0, max: 99)
        t["env2.decay2"]      = .init(page: 24, slot: 3, min: 0, max: 99)
        t["env2.decay3"]      = .init(page: 24, slot: 4, min: 0, max: 99)
        t["env2.release"]     = .init(page: 24, slot: 5, min: 0, max: 255)
        t["env2.kbdTrack"]    = .init(page: 25, slot: 0, min: 0, max: 255)
        t["env2.velCurve"]    = .init(page: 25, slot: 2, min: 0, max: 9)
        t["env2.mode"]        = .init(page: 25, slot: 3, min: 0, max: 2)
        t["env2.lvlVelSens"]  = .init(page: 25, slot: 4, min: 0, max: 127)
        t["env2.atkVelSens"]  = .init(page: 25, slot: 5, min: 0, max: 127)

        // -- Env3 (pages 26-28) --
        t["env3.initLevel"]   = .init(page: 26, slot: 1, min: 0, max: 127)
        t["env3.peakLevel"]   = .init(page: 26, slot: 2, min: 0, max: 127)
        t["env3.bp1Level"]    = .init(page: 26, slot: 3, min: 0, max: 127)
        t["env3.bp2Level"]    = .init(page: 26, slot: 4, min: 0, max: 127)
        t["env3.susLevel"]    = .init(page: 26, slot: 5, min: 0, max: 127)
        t["env3.attack"]      = .init(page: 27, slot: 1, min: 0, max: 99)
        t["env3.decay1"]      = .init(page: 27, slot: 2, min: 0, max: 99)
        t["env3.decay2"]      = .init(page: 27, slot: 3, min: 0, max: 99)
        t["env3.decay3"]      = .init(page: 27, slot: 4, min: 0, max: 99)
        t["env3.release"]     = .init(page: 27, slot: 5, min: 0, max: 255)
        t["env3.kbdTrack"]    = .init(page: 28, slot: 0, min: 0, max: 255)
        t["env3.velCurve"]    = .init(page: 28, slot: 2, min: 0, max: 9)
        t["env3.mode"]        = .init(page: 28, slot: 3, min: 0, max: 2)
        t["env3.lvlVelSens"]  = .init(page: 28, slot: 4, min: 0, max: 127)
        t["env3.atkVelSens"]  = .init(page: 28, slot: 5, min: 0, max: 127)

        // -- Effects (pages 29-31, type-dependent) --
        t["fx.type"]      = .init(page: 29, slot: 1, min: 0, max: 21)
        t["fx.reverbMix"] = .init(page: 29, slot: 2, min: 0, max: 99) // FX2 Mix / Decay
        t["fx.fx1Mix"]    = .init(page: 29, slot: 4, min: 0, max: 127)
        t["fx.fx2Mix"]    = .init(page: 29, slot: 5, min: 0, max: 127)

        // -- Voice Select (page 38) --
        t["voice.status0"] = .init(page: 38, slot: 0, min: 0, max: 2)
        t["voice.status1"] = .init(page: 38, slot: 1, min: 0, max: 2)
        t["voice.status2"] = .init(page: 38, slot: 2, min: 0, max: 2)
        t["voice.status3"] = .init(page: 38, slot: 3, min: 0, max: 2)
        t["voice.status4"] = .init(page: 38, slot: 4, min: 0, max: 2)
        t["voice.status5"] = .init(page: 38, slot: 5, min: 0, max: 2)

        return t
    }()

    // MARK: - Virtual Button Numbers (from spec section 3.1.1.1)

    static let buttonNumbers: [String: Int] = [
        "btn.wave": 29, "btn.pitch": 33, "btn.pitchMod": 34,
        "btn.filters": 35, "btn.output": 40, "btn.lfo": 42,
        "btn.env1": 45, "btn.env2": 48, "btn.env3": 51,
        "btn.effectsProg": 51, "btn.selectVoice": 60,
        "btn.copy": 61, "btn.write": 62, "btn.compare": 63,
        "btn.volume": 66, "btn.pan": 65, "btn.timbre": 67,
        "btn.keyZone": 68, "btn.transpose": 67, "btn.release": 69,
        "btn.patchSelect": 70,
        "btn.midiPerf": 73, "btn.effectsPerf": 76,
        "btn.multiA": 80, "btn.multiB": 81,
        "btn.replaceProgram": 83,
        "btn.master": 25, "btn.midiControl": 28,
        "btn.up": 14, "btn.down": 15,
        "btn.soft0": 16, "btn.soft1": 17, "btn.soft2": 18,
        "btn.soft3": 19, "btn.soft4": 20, "btn.soft5": 21,
        "btn.seqControl": 85, "btn.editSong": 84,
        "btn.editTrack": 86, "btn.record": 89,
        "btn.play": 91, "btn.stop": 92,
    ]
}

// MARK: - UInt8 Clamping

private extension UInt8 {
    init(clamped value: Int, min: Int, max: Int) {
        let clamped = Swift.min(Swift.max(value, min), max)
        self = UInt8(clamped & 0xFF)
    }
}
