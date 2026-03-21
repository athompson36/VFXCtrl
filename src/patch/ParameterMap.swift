import Foundation

enum VerificationStatus: String, Codable {
    case verified
    case inferred
    case unknown
}

struct ParameterDefinition: Identifiable, Codable, Hashable {
    let id = UUID()
    let key: String
    let label: String
    let shortLabel: String
    let page: EditorPage
    let sysexPage: Int
    let sysexSlot: Int
    let minValue: Int
    let maxValue: Int
    let status: VerificationStatus
    let note: String
}

/// Complete VFX-SD parameter map derived from the official MIDI Implementation Specification v2.00.
/// Section 5: Parameter Page and Slot Definitions.
/// Per spec: when multiple slot numbers are listed, use the HIGHEST for Parameter Change messages.
let initialParameterMap: [ParameterDefinition] = [

    // ── System / Master (Pages 0–2) ──
    .init(key: "sys.tune",          label: "Master Tune",           shortLabel: "TUNE",    page: .system, sysexPage: 0,  sysexSlot: 0, minValue: 0, maxValue: 255, status: .verified, note: "-128..+127 as unsigned byte"),
    .init(key: "sys.touch",         label: "Touch",                 shortLabel: "TOUCH",   page: .system, sysexPage: 0,  sysexSlot: 1, minValue: 0, maxValue: 4,   status: .verified, note: "SOFT,MED,FIRM,HARD 1-4"),
    .init(key: "sys.bendRange",     label: "System Bend Range",     shortLabel: "BEND",    page: .system, sysexPage: 0,  sysexSlot: 2, minValue: 0, maxValue: 12,  status: .verified, note: "Semitones"),
    .init(key: "sys.fs1",           label: "FS1 Footswitch",        shortLabel: "FS1",     page: .system, sysexPage: 0,  sysexSlot: 4, minValue: 0, maxValue: 3,   status: .verified, note: "UNUSED,SOSTENU,PATCH L,ADVANCE"),
    .init(key: "sys.fs2",           label: "FS2 Footswitch",        shortLabel: "FS2",     page: .system, sysexPage: 0,  sysexSlot: 5, minValue: 0, maxValue: 1,   status: .verified, note: "SUSTAIN,PATCH R"),
    .init(key: "sys.sliderMode",    label: "Slider Mode",           shortLabel: "SLIDER",  page: .system, sysexPage: 1,  sysexSlot: 0, minValue: 0, maxValue: 1,   status: .verified, note: "NORMAL,TIMBRE"),
    .init(key: "sys.cvPedal",       label: "CV Pedal Config",       shortLabel: "PEDAL",   page: .system, sysexPage: 1,  sysexSlot: 1, minValue: 0, maxValue: 1,   status: .verified, note: "VOL,MOD"),
    .init(key: "sys.pitchTable",    label: "System Pitch Table",    shortLabel: "PTBL",    page: .system, sysexPage: 1,  sysexSlot: 3, minValue: 0, maxValue: 1,   status: .verified, note: "CUSTOM,NORMAL"),
    .init(key: "sys.maxVelocity",   label: "Max Keyboard Velocity", shortLabel: "MAXVEL",  page: .system, sysexPage: 1,  sysexSlot: 4, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "sys.voiceMuting",   label: "Voice Muting",          shortLabel: "VMUTE",   page: .system, sysexPage: 2,  sysexSlot: 2, minValue: 0, maxValue: 1,   status: .verified, note: "OFF,ON"),

    // ── MIDI Control (Pages 3–4) ──
    .init(key: "sys.midiBaseCh",    label: "MIDI Base Channel",     shortLabel: "BASECH",  page: .system, sysexPage: 3,  sysexSlot: 0, minValue: 0, maxValue: 15,  status: .verified, note: "0-indexed internally"),
    .init(key: "sys.midiLoop",      label: "MIDI Loop",             shortLabel: "LOOP",    page: .system, sysexPage: 3,  sysexSlot: 1, minValue: 0, maxValue: 1,   status: .verified, note: "OFF,ON"),
    .init(key: "sys.midiSendCh",    label: "MIDI Send Channel",     shortLabel: "SENDCH",  page: .system, sysexPage: 3,  sysexSlot: 2, minValue: 0, maxValue: 1,   status: .verified, note: "BASE,TRACK"),
    .init(key: "sys.midiInMode",    label: "MIDI Mode",             shortLabel: "MODE",    page: .system, sysexPage: 3,  sysexSlot: 3, minValue: 0, maxValue: 4,   status: .verified, note: "OMNI,POLY,MULTI,MONO A,MONO B"),
    .init(key: "sys.midiTranspose", label: "MIDI Transpose",        shortLabel: "XPOSE",   page: .system, sysexPage: 3,  sysexSlot: 4, minValue: 0, maxValue: 2,   status: .verified, note: "SEND,RECV,BOTH"),
    .init(key: "sys.midiExtCtrl",   label: "Ext Controller #",      shortLabel: "EXTCC",   page: .system, sysexPage: 3,  sysexSlot: 5, minValue: 0, maxValue: 95,  status: .verified, note: "CC number"),
    .init(key: "sys.localControl",  label: "MIDI Controllers",      shortLabel: "LOCAL",   page: .system, sysexPage: 4,  sysexSlot: 0, minValue: 0, maxValue: 1,   status: .verified, note: "OFF,ON"),
    .init(key: "sys.songSelect",    label: "MIDI Song Select",      shortLabel: "SONG",    page: .system, sysexPage: 4,  sysexSlot: 1, minValue: 0, maxValue: 1,   status: .verified, note: "OFF,ON"),
    .init(key: "sys.sendStartStop", label: "Send Start/Stop",       shortLabel: "START",   page: .system, sysexPage: 4,  sysexSlot: 2, minValue: 0, maxValue: 1,   status: .verified, note: "OFF,ON"),
    .init(key: "sys.sysexRx",       label: "SysEx Enable",          shortLabel: "SYSEX",   page: .system, sysexPage: 4,  sysexSlot: 3, minValue: 0, maxValue: 1,   status: .verified, note: "OFF,ON"),
    .init(key: "sys.midiStatus",    label: "Program Change",        shortLabel: "PCHG",    page: .system, sysexPage: 4,  sysexSlot: 5, minValue: 0, maxValue: 2,   status: .verified, note: "OFF,ON,NEW"),

    // ── Program Control (Page 5) ──
    .init(key: "prog.pitchTable",   label: "Pitch Table",           shortLabel: "PTBL",    page: .performance, sysexPage: 5, sysexSlot: 0, minValue: 0, maxValue: 1,  status: .verified, note: "OFF,ON"),
    .init(key: "prog.bendRange",    label: "Program Bend Range",    shortLabel: "PBEND",   page: .performance, sysexPage: 5, sysexSlot: 2, minValue: 0, maxValue: 13, status: .verified, note: "13=global"),
    .init(key: "prog.delayMult",    label: "Delay Multiplier",      shortLabel: "DLYMX",   page: .performance, sysexPage: 5, sysexSlot: 3, minValue: 0, maxValue: 3,  status: .verified, note: "X1,X2,X4,X8"),
    .init(key: "prog.restrike",     label: "Restrike Delay",        shortLabel: "RSTK",    page: .performance, sysexPage: 5, sysexSlot: 4, minValue: 0, maxValue: 99, status: .verified, note: ""),
    .init(key: "prog.glide",        label: "Glide Time",            shortLabel: "GLIDE",   page: .performance, sysexPage: 5, sysexSlot: 5, minValue: 0, maxValue: 99, status: .verified, note: ""),

    // ── Wave (Pages 7–10) ──
    .init(key: "wave.select",       label: "Wave Name",             shortLabel: "WAVE",    page: .wave, sysexPage: 7, sysexSlot: 0, minValue: 0, maxValue: 147, status: .verified, note: "0..147 for VFX-SD Version II"),
    .init(key: "wave.class",        label: "Wave Class",            shortLabel: "CLASS",   page: .wave, sysexPage: 7, sysexSlot: 1, minValue: 0, maxValue: 12,  status: .verified, note: "0..12 for VFX-SD Version II"),
    .init(key: "wave.delay",        label: "Wave Delay Time",       shortLabel: "WDLY",    page: .wave, sysexPage: 7, sysexSlot: 2, minValue: 0, maxValue: 251, status: .verified, note: "251=key up"),
    .init(key: "wave.start",        label: "Wave Start Index",      shortLabel: "START",   page: .wave, sysexPage: 7, sysexSlot: 3, minValue: 0, maxValue: 127, status: .verified, note: "Sampled wave classes"),
    .init(key: "wave.velStart",     label: "Wave Vel Start Mod",    shortLabel: "VSTRT",   page: .wave, sysexPage: 7, sysexSlot: 4, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),
    .init(key: "wave.direction",    label: "Wave Direction",        shortLabel: "DIR",     page: .wave, sysexPage: 7, sysexSlot: 5, minValue: 0, maxValue: 1,   status: .verified, note: "FORWARD,REVERSE"),

    // ── Pitch (Page 11) ──
    .init(key: "pitch.octave",      label: "Pitch Octave",          shortLabel: "OCT",     page: .wave, sysexPage: 11, sysexSlot: 0, minValue: 0, maxValue: 255, status: .verified, note: "-4..+4"),
    .init(key: "pitch.semitone",    label: "Pitch Semitone",        shortLabel: "SEMI",    page: .wave, sysexPage: 11, sysexSlot: 1, minValue: 0, maxValue: 255, status: .verified, note: "-12..+12"),
    .init(key: "pitch.fine",        label: "Pitch Fine Tune",       shortLabel: "FINE",    page: .wave, sysexPage: 11, sysexSlot: 2, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),

    // ── Pitch Mod (Page 12) ──
    .init(key: "pitch.modSrc",      label: "Pitch Mod Source",      shortLabel: "PSRC",    page: .motion, sysexPage: 12, sysexSlot: 1, minValue: 0, maxValue: 15,  status: .verified, note: ""),
    .init(key: "pitch.modAmt",      label: "Pitch Mod Amount",      shortLabel: "PAMT",    page: .motion, sysexPage: 12, sysexSlot: 2, minValue: 0, maxValue: 255, status: .verified, note: "-99..+99"),
    .init(key: "pitch.glideMode",   label: "Glide Mode",            shortLabel: "GLIDE",   page: .motion, sysexPage: 12, sysexSlot: 3, minValue: 0, maxValue: 4,   status: .verified, note: "NONE,PEDAL,MONO,LEGATO,TRIGGER"),
    .init(key: "pitch.env1Mod",     label: "Pitch Env1 Mod",        shortLabel: "PE1",     page: .motion, sysexPage: 12, sysexSlot: 4, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),
    .init(key: "pitch.lfoMod",      label: "Pitch LFO Mod",         shortLabel: "PLFO",    page: .motion, sysexPage: 12, sysexSlot: 5, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),

    // ── Filter #1 (Page 13) ──
    .init(key: "filter.type",       label: "Filter #1 Type",        shortLabel: "FTYP",    page: .filter, sysexPage: 13, sysexSlot: 0, minValue: 0, maxValue: 1,   status: .verified, note: "LO-PASS/2,LO-PASS/3"),
    .init(key: "filter.cutoff",     label: "Filter #1 Cutoff",      shortLabel: "CUT",     page: .filter, sysexPage: 13, sysexSlot: 1, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "filter.keytrack",   label: "Filter #1 Kbd Track",   shortLabel: "FKBD",    page: .filter, sysexPage: 13, sysexSlot: 2, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),
    .init(key: "filter.modSrc",     label: "Filter #1 Mod Source",  shortLabel: "FSRC",    page: .filter, sysexPage: 13, sysexSlot: 3, minValue: 0, maxValue: 15,  status: .verified, note: ""),
    .init(key: "filter.env",        label: "Filter #1 Env2 Mod",    shortLabel: "FENV",    page: .filter, sysexPage: 13, sysexSlot: 4, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),
    .init(key: "filter.modAmt",     label: "Filter #1 Mod Amount",  shortLabel: "FAMT",    page: .filter, sysexPage: 13, sysexSlot: 5, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),

    // ── Filter #2 (Page 14) ──
    .init(key: "filter2.type",      label: "Filter #2 Type",        shortLabel: "F2TY",    page: .filter, sysexPage: 14, sysexSlot: 0, minValue: 0, maxValue: 3,   status: .verified, note: "HI-PASS/2,HI-PASS/1,LO-PASS/2,LO-PASS/1"),
    .init(key: "filter2.cutoff",    label: "Filter #2 Cutoff",      shortLabel: "F2CT",    page: .filter, sysexPage: 14, sysexSlot: 1, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "filter2.keytrack",  label: "Filter #2 Kbd Track",   shortLabel: "F2KB",    page: .filter, sysexPage: 14, sysexSlot: 2, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),
    .init(key: "filter2.modSrc",    label: "Filter #2 Mod Source",  shortLabel: "F2SR",    page: .filter, sysexPage: 14, sysexSlot: 3, minValue: 0, maxValue: 15,  status: .verified, note: ""),
    .init(key: "filter2.modAmt",    label: "Filter #2 Mod Amount",  shortLabel: "F2AM",    page: .filter, sysexPage: 14, sysexSlot: 4, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),
    .init(key: "filter2.env",       label: "Filter #2 Env2 Mod",    shortLabel: "F2EN",    page: .filter, sysexPage: 14, sysexSlot: 5, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),

    // ── Output (Pages 15–17) ──
    .init(key: "output.volume",     label: "Voice Volume",          shortLabel: "VOL",     page: .amp,  sysexPage: 15, sysexSlot: 0, minValue: 0, maxValue: 127, status: .verified, note: "Per-voice"),
    .init(key: "output.volModSrc",  label: "Volume Mod Source",     shortLabel: "VSRC",    page: .amp,  sysexPage: 15, sysexSlot: 1, minValue: 0, maxValue: 15,  status: .verified, note: ""),
    .init(key: "output.volModAmt",  label: "Volume Mod Amount",     shortLabel: "VAMT",    page: .amp,  sysexPage: 15, sysexSlot: 2, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),
    .init(key: "output.pan",        label: "Pan",                   shortLabel: "PAN",     page: .performance, sysexPage: 16, sysexSlot: 2, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "output.dest",       label: "Output Destination",    shortLabel: "DEST",    page: .fx,   sysexPage: 16, sysexSlot: 1, minValue: 0, maxValue: 3,   status: .verified, note: "DRY,FX1,FX2,AUX"),
    .init(key: "output.preGain",    label: "Pre-Gain Switch",       shortLabel: "GAIN",    page: .amp,  sysexPage: 16, sysexSlot: 5, minValue: 0, maxValue: 1,   status: .verified, note: "OFF,ON"),

    // ── LFO (Pages 18–19) ──
    .init(key: "lfo.rate",          label: "LFO Rate",              shortLabel: "RATE",    page: .motion, sysexPage: 18, sysexSlot: 0, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "lfo.rateModSrc",    label: "LFO Rate Mod Source",   shortLabel: "RSRC",    page: .motion, sysexPage: 18, sysexSlot: 1, minValue: 0, maxValue: 15,  status: .verified, note: ""),
    .init(key: "lfo.rateModAmt",    label: "LFO Rate Mod Amount",   shortLabel: "RAMT",    page: .motion, sysexPage: 18, sysexSlot: 2, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),
    .init(key: "lfo.depth",         label: "LFO Depth",             shortLabel: "DEPTH",   page: .motion, sysexPage: 18, sysexSlot: 3, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "lfo.delay",         label: "LFO Delay",             shortLabel: "DELAY",   page: .motion, sysexPage: 18, sysexSlot: 5, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "lfo.waveshape",     label: "LFO Waveshape",         shortLabel: "WAVE",    page: .motion, sysexPage: 19, sysexSlot: 1, minValue: 0, maxValue: 6,   status: .verified, note: "TRI,SIN,SIN/TRI,POS/SIN,SAW,SQR"),
    .init(key: "lfo.restart",       label: "LFO Restart",           shortLabel: "RSTR",    page: .motion, sysexPage: 19, sysexSlot: 2, minValue: 0, maxValue: 1,   status: .verified, note: "OFF,ON"),
    .init(key: "lfo.noiseRate",     label: "Noise Source Rate",     shortLabel: "NOISE",   page: .motion, sysexPage: 19, sysexSlot: 5, minValue: 0, maxValue: 127, status: .verified, note: ""),

    // ── Env1 / Amplitude (Pages 20–22) ──
    .init(key: "env1.initLevel",    label: "Env1 Initial Level",    shortLabel: "E1IL",    page: .amp, sysexPage: 20, sysexSlot: 1, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env1.peakLevel",    label: "Env1 Peak Level",       shortLabel: "E1PK",    page: .amp, sysexPage: 20, sysexSlot: 2, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env1.susLevel",     label: "Env1 Sustain Level",    shortLabel: "E1SU",    page: .amp, sysexPage: 20, sysexSlot: 5, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env1.attack",       label: "Env1 Attack Time",      shortLabel: "E1AT",    page: .amp, sysexPage: 21, sysexSlot: 1, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "env1.decay1",       label: "Env1 Decay 1 Time",     shortLabel: "E1D1",    page: .amp, sysexPage: 21, sysexSlot: 2, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "env1.release",      label: "Env1 Release Time",     shortLabel: "E1RL",    page: .amp, sysexPage: 21, sysexSlot: 5, minValue: 0, maxValue: 255, status: .verified, note: "-100..+99"),
    .init(key: "env1.lvlVelSens",   label: "Env1 Level Vel Sens",   shortLabel: "E1VS",    page: .amp, sysexPage: 22, sysexSlot: 4, minValue: 0, maxValue: 127, status: .verified, note: ""),

    // ── Effects (Pages 29–31) ──
    .init(key: "fx.type",           label: "Effect Type",           shortLabel: "FXTY",    page: .fx, sysexPage: 29, sysexSlot: 1, minValue: 0, maxValue: 21, status: .verified, note: "22 effect types, see spec"),
    .init(key: "fx.fx1Mix",         label: "FX1 Mix",               shortLabel: "FX1",     page: .fx, sysexPage: 29, sysexSlot: 4, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "fx.fx2Mix",         label: "FX2 Mix",               shortLabel: "FX2",     page: .fx, sysexPage: 29, sysexSlot: 5, minValue: 0, maxValue: 127, status: .verified, note: ""),

    // ── Voice Select (Page 38) ──
    .init(key: "voice.status",      label: "Voice Status",          shortLabel: "VSTAT",   page: .wave, sysexPage: 38, sysexSlot: 0, minValue: 0, maxValue: 2, status: .verified, note: "OFF,ON,SOLO"),
]
