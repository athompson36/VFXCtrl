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
    /// VFX-SD SysEx page (0–38), or 900/998/999 for UI grouping only.
    let sysexPage: Int
    let sysexSlot: Int
    let minValue: Int
    let maxValue: Int
    let status: VerificationStatus
    let note: String
}

/// Complete VFX-SD parameter map derived from the official MIDI Implementation Specification v2.00
/// and aligned with `LiveSysExBuilder.parameterAddressTable` for live edit.
/// Section 5: Parameter Page and Slot Definitions.
/// Per spec: when multiple slot numbers are listed, use the HIGHEST for Parameter Change messages.
let initialParameterMap: [ParameterDefinition] = [

    // ── System / Master (Pages 0–2) ──
    .init(key: "sys.masterVol",     label: "Master Volume",         shortLabel: "MVOL",    page: .system, sysexPage: 900, sysexSlot: 0, minValue: 0, maxValue: 127, status: .verified, note: "MIDI CC 7, not SysEx"),
    .init(key: "sys.tune",          label: "Master Tune",           shortLabel: "TUNE",    page: .system, sysexPage: 0,  sysexSlot: 0, minValue: 0, maxValue: 255, status: .verified, note: "-128..+127 as unsigned byte"),
    .init(key: "sys.touch",         label: "Touch",                 shortLabel: "TOUCH",   page: .system, sysexPage: 0,  sysexSlot: 1, minValue: 0, maxValue: 4,   status: .verified, note: "SOFT,MED,FIRM,HARD 1-4"),
    .init(key: "sys.bendRange",     label: "System Bend Range",     shortLabel: "BEND",    page: .system, sysexPage: 0,  sysexSlot: 2, minValue: 0, maxValue: 12,  status: .verified, note: "Semitones"),
    .init(key: "sys.fs1",           label: "FS1 Footswitch",        shortLabel: "FS1",     page: .system, sysexPage: 0,  sysexSlot: 4, minValue: 0, maxValue: 3,   status: .verified, note: "UNUSED,SOSTENU,PATCH L,ADVANCE"),
    .init(key: "sys.fs2",           label: "FS2 Footswitch",        shortLabel: "FS2",     page: .system, sysexPage: 0,  sysexSlot: 5, minValue: 0, maxValue: 1,   status: .verified, note: "SUSTAIN,PATCH R"),
    .init(key: "sys.sliderMode",    label: "Slider Mode",           shortLabel: "SLIDER",  page: .system, sysexPage: 1,  sysexSlot: 0, minValue: 0, maxValue: 1,   status: .verified, note: "NORMAL,TIMBRE"),
    .init(key: "sys.cvPedal",       label: "CV Pedal Config",       shortLabel: "CVPD",    page: .system, sysexPage: 1,  sysexSlot: 1, minValue: 0, maxValue: 1,   status: .verified, note: "VOL,MOD"),
    .init(key: "sys.pitchTable",    label: "System Pitch Table",    shortLabel: "SPTBL",   page: .system, sysexPage: 1,  sysexSlot: 3, minValue: 0, maxValue: 1,   status: .verified, note: "CUSTOM,NORMAL"),
    .init(key: "sys.maxVelocity",   label: "Max Keyboard Velocity", shortLabel: "MAXVEL",  page: .system, sysexPage: 1,  sysexSlot: 4, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "sys.voiceMuting",   label: "Voice Muting",          shortLabel: "VMUTE",   page: .system, sysexPage: 2,  sysexSlot: 2, minValue: 0, maxValue: 1,   status: .verified, note: "OFF,ON"),
    .init(key: "sys.xposEnable",    label: "XPOS Enable",           shortLabel: "XPOS",    page: .system, sysexPage: 2,  sysexSlot: 5, minValue: 0, maxValue: 1,   status: .unknown, note: "Placeholder; verify in spec"),
    .init(key: "sys.diskType",      label: "Disk Type",             shortLabel: "DISK",    page: .system, sysexPage: 2,  sysexSlot: 4, minValue: 0, maxValue: 127, status: .unknown, note: "Patch / UI"),

    // ── MIDI Control (Pages 3–4) ──
    .init(key: "sys.midiBaseCh",    label: "MIDI Base Channel",     shortLabel: "BASECH",  page: .system, sysexPage: 3,  sysexSlot: 0, minValue: 0, maxValue: 15,  status: .verified, note: "0-indexed internally"),
    .init(key: "sys.midiLoop",      label: "MIDI Loop",             shortLabel: "LOOP",    page: .system, sysexPage: 3,  sysexSlot: 1, minValue: 0, maxValue: 1,   status: .verified, note: "OFF,ON"),
    .init(key: "sys.midiSendCh",    label: "MIDI Send Channel",     shortLabel: "SENDCH",  page: .system, sysexPage: 3,  sysexSlot: 2, minValue: 0, maxValue: 1,   status: .verified, note: "BASE,TRACK"),
    .init(key: "sys.midiInMode",    label: "MIDI Mode",             shortLabel: "MODE",    page: .system, sysexPage: 3,  sysexSlot: 3, minValue: 0, maxValue: 4,   status: .verified, note: "OMNI,POLY,MULTI,MONO A,MONO B"),
    .init(key: "sys.midiTranspose", label: "MIDI Transpose",        shortLabel: "XPOSE",   page: .system, sysexPage: 3,  sysexSlot: 4, minValue: 0, maxValue: 2,   status: .verified, note: "SEND,RECV,BOTH"),
    .init(key: "sys.midiExtCtrl",   label: "Ext Controller #",      shortLabel: "EXTCC",   page: .system, sysexPage: 3,  sysexSlot: 5, minValue: 0, maxValue: 95,  status: .verified, note: "CC number"),
    .init(key: "sys.localControl",  label: "MIDI Controllers",      shortLabel: "LOCAL",   page: .system, sysexPage: 4,  sysexSlot: 0, minValue: 0, maxValue: 1,   status: .verified, note: "OFF,ON"),
    .init(key: "sys.songSelect",    label: "MIDI Song Select",      shortLabel: "SONG",    page: .system, sysexPage: 4,  sysexSlot: 1, minValue: 0, maxValue: 1,   status: .verified, note: "OFF,ON"),
    .init(key: "sys.sendStartStop", label: "Send Start/Stop",       shortLabel: "STRT",    page: .system, sysexPage: 4,  sysexSlot: 2, minValue: 0, maxValue: 1,   status: .verified, note: "OFF,ON"),
    .init(key: "sys.sysexRx",       label: "SysEx Enable",          shortLabel: "SYSEX",   page: .system, sysexPage: 4,  sysexSlot: 3, minValue: 0, maxValue: 1,   status: .verified, note: "OFF,ON"),
    .init(key: "sys.midiStatus",    label: "Program Change Routing", shortLabel: "PCHG",   page: .system, sysexPage: 4,  sysexSlot: 5, minValue: 0, maxValue: 2,   status: .verified, note: "Local / MIDI / Both (not Off-On-New)"),

    // ── Program Control (Page 5) — slots match LiveSysExBuilder ──
    .init(key: "prog.pitchTable",   label: "Program Pitch Table",   shortLabel: "PTBL",    page: .performance, sysexPage: 5, sysexSlot: 0, minValue: 0, maxValue: 1,  status: .verified, note: "OFF,ON per program"),
    .init(key: "prog.bendRange",    label: "Program Bend Range",    shortLabel: "PBEND",   page: .performance, sysexPage: 5, sysexSlot: 1, minValue: 0, maxValue: 13, status: .verified, note: "13=global"),
    .init(key: "prog.delayMult",    label: "Delay Multiplier",      shortLabel: "DLYMX",   page: .performance, sysexPage: 5, sysexSlot: 2, minValue: 0, maxValue: 3,  status: .verified, note: "X1,X2,X4,X8"),
    .init(key: "prog.restrike",     label: "Restrike Delay",        shortLabel: "RSTK",    page: .performance, sysexPage: 5, sysexSlot: 4, minValue: 0, maxValue: 99, status: .verified, note: ""),
    .init(key: "prog.glide",        label: "Glide Time",            shortLabel: "PGLD",    page: .performance, sysexPage: 5, sysexSlot: 5, minValue: 0, maxValue: 99, status: .verified, note: ""),

    // ── Performance (patch / editor only; not in live table) ──
    .init(key: "perf.split",        label: "Split Point",           shortLabel: "SPLIT",   page: .performance, sysexPage: 999, sysexSlot: 0, minValue: 0, maxValue: 127, status: .unknown, note: "Patch workflow"),
    .init(key: "perf.balance",      label: "Zone Balance",          shortLabel: "BAL",     page: .performance, sysexPage: 999, sysexSlot: 1, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "perf.detune",       label: "Detune",                shortLabel: "DET",     page: .performance, sysexPage: 999, sysexSlot: 2, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "perf.zonelow",      label: "Key Zone Low",          shortLabel: "ZLO",     page: .performance, sysexPage: 999, sysexSlot: 3, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "perf.zonehigh",     label: "Key Zone High",         shortLabel: "ZHI",     page: .performance, sysexPage: 999, sysexSlot: 4, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "perf.vellow",       label: "Vel Zone Low",          shortLabel: "VLO",     page: .performance, sysexPage: 999, sysexSlot: 5, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "perf.velhigh",      label: "Vel Zone High",         shortLabel: "VHI",     page: .performance, sysexPage: 999, sysexSlot: 6, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "perf.transpose",    label: "Transpose",             shortLabel: "XPOSE",   page: .performance, sysexPage: 999, sysexSlot: 7, minValue: 0, maxValue: 127, status: .unknown, note: ""),

    // ── Mod mixer (Page 6) — depths are 0..15 per spec ──
    .init(key: "mod.src1",          label: "Mod Source 1",          shortLabel: "MS1",     page: .mod, sysexPage: 6, sysexSlot: 1, minValue: 0, maxValue: 15,  status: .verified, note: ""),
    .init(key: "mod.src2",          label: "Mod Source 2",          shortLabel: "MS2",     page: .mod, sysexPage: 6, sysexSlot: 2, minValue: 0, maxValue: 15,  status: .verified, note: ""),
    .init(key: "mod.depth1",        label: "Mod Scaler",            shortLabel: "SCL",     page: .mod, sysexPage: 6, sysexSlot: 4, minValue: 0, maxValue: 15,  status: .verified, note: "Mixer scaler"),
    .init(key: "mod.depth2",        label: "Mod Shape",           shortLabel: "SHP",     page: .mod, sysexPage: 6, sysexSlot: 5, minValue: 0, maxValue: 15,  status: .verified, note: "Mixer shape"),
    .init(key: "mod.dest1",         label: "Mod Dest 1 (UI)",       shortLabel: "MD1",     page: .mod, sysexPage: 998, sysexSlot: 0, minValue: 0, maxValue: 9,   status: .inferred, note: "Not in live SysEx table"),
    .init(key: "mod.dest2",         label: "Mod Dest 2 (UI)",       shortLabel: "MD2",     page: .mod, sysexPage: 998, sysexSlot: 1, minValue: 0, maxValue: 9,   status: .inferred, note: "Not in live SysEx table"),
    .init(key: "mod.pedal",         label: "Mod Pedal (UI)",        shortLabel: "PED",     page: .mod, sysexPage: 998, sysexSlot: 2, minValue: 0, maxValue: 127, status: .unknown, note: "Patch / UI"),
    .init(key: "mod.pressure",      label: "Mod Pressure (UI)",     shortLabel: "PRS",     page: .mod, sysexPage: 998, sysexSlot: 3, minValue: 0, maxValue: 127, status: .unknown, note: "Patch / UI"),

    // ── Wave (Pages 7–10) ──
    .init(key: "wave.select",       label: "Wave Name",             shortLabel: "WAVE",    page: .wave, sysexPage: 7, sysexSlot: 0, minValue: 0, maxValue: 147, status: .verified, note: "0..147 VFX-SD II"),
    .init(key: "wave.class",        label: "Wave Class",            shortLabel: "CLASS",   page: .wave, sysexPage: 7, sysexSlot: 1, minValue: 0, maxValue: 12,  status: .verified, note: ""),
    .init(key: "wave.delay",        label: "Wave Delay Time",       shortLabel: "WDLY",    page: .wave, sysexPage: 7, sysexSlot: 2, minValue: 0, maxValue: 251, status: .verified, note: "251=key up"),
    .init(key: "wave.start",        label: "Wave Start Index",      shortLabel: "START",   page: .wave, sysexPage: 7, sysexSlot: 3, minValue: 0, maxValue: 127, status: .verified, note: "Sampled classes"),
    .init(key: "wave.velStart",     label: "Wave Vel Start Mod",    shortLabel: "VSTRT",   page: .wave, sysexPage: 7, sysexSlot: 4, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),
    .init(key: "wave.direction",    label: "Wave Direction",        shortLabel: "DIR",     page: .wave, sysexPage: 7, sysexSlot: 5, minValue: 0, maxValue: 1,   status: .verified, note: "FORWARD,REVERSE"),

    // ── Pitch (Page 11) ──
    .init(key: "pitch.octave",      label: "Pitch Octave",          shortLabel: "OCT",     page: .wave, sysexPage: 11, sysexSlot: 0, minValue: 0, maxValue: 255, status: .verified, note: "-4..+4"),
    .init(key: "pitch.semitone",    label: "Pitch Semitone",        shortLabel: "SEMI",    page: .wave, sysexPage: 11, sysexSlot: 1, minValue: 0, maxValue: 255, status: .verified, note: "-12..+12"),
    .init(key: "pitch.fine",        label: "Pitch Fine Tune",       shortLabel: "FINE",    page: .wave, sysexPage: 11, sysexSlot: 2, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),
    .init(key: "pitch.table",       label: "Program Pitch Table",   shortLabel: "PTBLP",   page: .wave, sysexPage: 11, sysexSlot: 4, minValue: 0, maxValue: 2,   status: .verified, note: "Per program"),

    // ── Pitch Mod (Page 12) ──
    .init(key: "pitch.modSrc",      label: "Pitch Mod Source",      shortLabel: "PSRC",    page: .motion, sysexPage: 12, sysexSlot: 1, minValue: 0, maxValue: 15,  status: .verified, note: ""),
    .init(key: "pitch.modAmt",      label: "Pitch Mod Amount",      shortLabel: "PAMT",    page: .motion, sysexPage: 12, sysexSlot: 2, minValue: 0, maxValue: 255, status: .verified, note: "-99..+99"),
    .init(key: "pitch.glideMode",   label: "Glide Mode",            shortLabel: "GLMD",    page: .motion, sysexPage: 12, sysexSlot: 3, minValue: 0, maxValue: 4,   status: .verified, note: "NONE,PEDAL,MONO,LEGATO,TRIGGER"),
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
    .init(key: "filter2.type",      label: "Filter #2 Type",        shortLabel: "F2TY",    page: .filter, sysexPage: 14, sysexSlot: 0, minValue: 0, maxValue: 3,   status: .verified, note: ""),
    .init(key: "filter2.cutoff",    label: "Filter #2 Cutoff",      shortLabel: "F2CT",    page: .filter, sysexPage: 14, sysexSlot: 1, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "filter2.keytrack",  label: "Filter #2 Kbd Track",   shortLabel: "F2KB",    page: .filter, sysexPage: 14, sysexSlot: 2, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),
    .init(key: "filter2.modSrc",    label: "Filter #2 Mod Source",  shortLabel: "F2SR",    page: .filter, sysexPage: 14, sysexSlot: 3, minValue: 0, maxValue: 15,  status: .verified, note: ""),
    .init(key: "filter2.modAmt",    label: "Filter #2 Mod Amount",  shortLabel: "F2AM",    page: .filter, sysexPage: 14, sysexSlot: 4, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),
    .init(key: "filter2.env",       label: "Filter #2 Env2 Mod",    shortLabel: "F2EN",    page: .filter, sysexPage: 14, sysexSlot: 5, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),

    // ── Legacy filter UI keys (macros / old patches) ──
    .init(key: "filter.resonance",  label: "Resonance (legacy)",    shortLabel: "RES",     page: .filter, sysexPage: 998, sysexSlot: 10, minValue: 0, maxValue: 127, status: .unknown, note: "No direct VFX-SD param"),
    .init(key: "filter.velocity",   label: "Filt Vel (legacy)",     shortLabel: "FVEL",    page: .filter, sysexPage: 998, sysexSlot: 11, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "filter.mode",       label: "Filt Mode (legacy)",    shortLabel: "FMODE",   page: .filter, sysexPage: 998, sysexSlot: 12, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "filter.source",     label: "Filt Src (legacy)",     shortLabel: "FSRC2",   page: .filter, sysexPage: 998, sysexSlot: 13, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "filter.alt",        label: "Filt Alt (legacy)",     shortLabel: "FALT",    page: .filter, sysexPage: 998, sysexSlot: 14, minValue: 0, maxValue: 127, status: .unknown, note: ""),

    // ── Output (Pages 15–17) ──
    .init(key: "output.volume",     label: "Voice Volume",          shortLabel: "VOL",     page: .amp,  sysexPage: 15, sysexSlot: 0, minValue: 0, maxValue: 127, status: .verified, note: "Per-voice"),
    .init(key: "output.volModSrc",  label: "Volume Mod Source",     shortLabel: "VSRC",    page: .amp,  sysexPage: 15, sysexSlot: 1, minValue: 0, maxValue: 15,  status: .verified, note: ""),
    .init(key: "output.volModAmt",  label: "Volume Mod Amount",     shortLabel: "VAMT",    page: .amp,  sysexPage: 15, sysexSlot: 2, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),
    .init(key: "output.keyScale",   label: "Amp Key Scale",         shortLabel: "KSC",     page: .amp,  sysexPage: 15, sysexSlot: 3, minValue: 0, maxValue: 255, status: .verified, note: "-128..+127"),
    .init(key: "output.dest",       label: "Output Destination",    shortLabel: "DEST",    page: .fx,   sysexPage: 16, sysexSlot: 1, minValue: 0, maxValue: 3,   status: .verified, note: "DRY,FX1,FX2,AUX"),
    .init(key: "output.pan",        label: "Pan",                   shortLabel: "PAN",     page: .performance, sysexPage: 16, sysexSlot: 2, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "output.panModSrc",  label: "Pan Mod Source",        shortLabel: "PSRC",    page: .performance, sysexPage: 16, sysexSlot: 3, minValue: 0, maxValue: 15,  status: .verified, note: ""),
    .init(key: "output.panModAmt",  label: "Pan Mod Amount",        shortLabel: "PAMT",    page: .performance, sysexPage: 16, sysexSlot: 4, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),
    .init(key: "output.preGain",    label: "Pre-Gain Switch",       shortLabel: "GAIN",    page: .amp,  sysexPage: 16, sysexSlot: 5, minValue: 0, maxValue: 1,   status: .verified, note: "OFF,ON"),
    .init(key: "output.priority",   label: "Voice Priority",        shortLabel: "PRI",     page: .amp,  sysexPage: 17, sysexSlot: 2, minValue: 0, maxValue: 2,   status: .verified, note: ""),
    .init(key: "output.velThresh",  label: "Velocity Threshold",    shortLabel: "VTHR",    page: .amp,  sysexPage: 17, sysexSlot: 4, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),

    // ── LFO (Pages 18–19) ──
    .init(key: "lfo.rate",          label: "LFO Rate",              shortLabel: "RATE",    page: .motion, sysexPage: 18, sysexSlot: 0, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "lfo.rateModSrc",    label: "LFO Rate Mod Source",   shortLabel: "RSRC",    page: .motion, sysexPage: 18, sysexSlot: 1, minValue: 0, maxValue: 15,  status: .verified, note: ""),
    .init(key: "lfo.rateModAmt",    label: "LFO Rate Mod Amount",   shortLabel: "RAMT",    page: .motion, sysexPage: 18, sysexSlot: 2, minValue: 0, maxValue: 255, status: .verified, note: "-127..+127"),
    .init(key: "lfo.depth",         label: "LFO Depth",             shortLabel: "DEPTH",   page: .motion, sysexPage: 18, sysexSlot: 3, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "lfo.depthModSrc",   label: "LFO Depth Mod Source",  shortLabel: "DSRC",    page: .motion, sysexPage: 18, sysexSlot: 4, minValue: 0, maxValue: 15,  status: .verified, note: ""),
    .init(key: "lfo.delay",         label: "LFO Delay",             shortLabel: "LDLY",    page: .motion, sysexPage: 18, sysexSlot: 5, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "lfo.waveshape",     label: "LFO Waveshape",         shortLabel: "LSHP",    page: .motion, sysexPage: 19, sysexSlot: 1, minValue: 0, maxValue: 6,   status: .verified, note: ""),
    .init(key: "lfo.restart",       label: "LFO Restart",           shortLabel: "RSTR",    page: .motion, sysexPage: 19, sysexSlot: 2, minValue: 0, maxValue: 1,   status: .verified, note: "OFF,ON"),
    .init(key: "lfo.noiseRate",     label: "Noise Source Rate",     shortLabel: "NOIS",    page: .motion, sysexPage: 19, sysexSlot: 5, minValue: 0, maxValue: 127, status: .verified, note: ""),

    // ── Legacy motion keys ──
    .init(key: "motion.position",   label: "Motion Pos (legacy)",   shortLabel: "MPOS",    page: .motion, sysexPage: 998, sysexSlot: 20, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "motion.amount",     label: "Motion Amt (legacy)",   shortLabel: "MAMT",    page: .motion, sysexPage: 998, sysexSlot: 21, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "motion.source",     label: "Motion Src (legacy)",   shortLabel: "MSRC",    page: .motion, sysexPage: 998, sysexSlot: 22, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "lfo1.rate",         label: "LFO1 Rate (= lfo.rate)", shortLabel: "L1RT",   page: .motion, sysexPage: 998, sysexSlot: 23, minValue: 0, maxValue: 99,  status: .inferred, note: "Alias of lfo.rate"),
    .init(key: "lfo1.depth",        label: "LFO1 Depth (= lfo.depth)", shortLabel: "L1DP", page: .motion, sysexPage: 998, sysexSlot: 24, minValue: 0, maxValue: 127, status: .inferred, note: "Alias of lfo.depth"),
    .init(key: "lfo2.rate",         label: "LFO2 Rate (legacy)",    shortLabel: "L2RT",    page: .motion, sysexPage: 998, sysexSlot: 25, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "modwheel.depth",    label: "Mod Wheel Depth",       shortLabel: "MW",      page: .motion, sysexPage: 998, sysexSlot: 26, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "aftertouch.depth",  label: "Aftertouch Depth",      shortLabel: "AT",      page: .motion, sysexPage: 998, sysexSlot: 27, minValue: 0, maxValue: 127, status: .unknown, note: ""),

    // ── Env1 / Amplitude (Pages 20–22) ──
    .init(key: "env1.initLevel",    label: "Env1 Initial Level",    shortLabel: "E1IL",    page: .amp, sysexPage: 20, sysexSlot: 1, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env1.peakLevel",    label: "Env1 Peak Level",       shortLabel: "E1PK",    page: .amp, sysexPage: 20, sysexSlot: 2, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env1.bp1Level",     label: "Env1 Breakpoint 1",     shortLabel: "E1B1",    page: .amp, sysexPage: 20, sysexSlot: 3, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env1.bp2Level",     label: "Env1 Breakpoint 2",     shortLabel: "E1B2",    page: .amp, sysexPage: 20, sysexSlot: 4, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env1.susLevel",     label: "Env1 Sustain Level",    shortLabel: "E1SU",    page: .amp, sysexPage: 20, sysexSlot: 5, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env1.attack",       label: "Env1 Attack Time",      shortLabel: "E1AT",    page: .amp, sysexPage: 21, sysexSlot: 1, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "env1.decay1",       label: "Env1 Decay 1 Time",     shortLabel: "E1D1",    page: .amp, sysexPage: 21, sysexSlot: 2, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "env1.decay2",       label: "Env1 Decay 2 Time",     shortLabel: "E1D2",    page: .amp, sysexPage: 21, sysexSlot: 3, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "env1.decay3",       label: "Env1 Decay 3 Time",     shortLabel: "E1D3",    page: .amp, sysexPage: 21, sysexSlot: 4, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "env1.release",      label: "Env1 Release Time",     shortLabel: "E1RL",    page: .amp, sysexPage: 21, sysexSlot: 5, minValue: 0, maxValue: 255, status: .verified, note: "-100..+99"),
    .init(key: "env1.kbdTrack",     label: "Env1 Key Track",        shortLabel: "E1KB",    page: .amp, sysexPage: 22, sysexSlot: 0, minValue: 0, maxValue: 255, status: .verified, note: ""),
    .init(key: "env1.velCurve",     label: "Env1 Vel Curve",        shortLabel: "E1VC",    page: .amp, sysexPage: 22, sysexSlot: 2, minValue: 0, maxValue: 9,   status: .verified, note: ""),
    .init(key: "env1.mode",         label: "Env1 Mode",             shortLabel: "E1MD",    page: .amp, sysexPage: 22, sysexSlot: 3, minValue: 0, maxValue: 2,   status: .verified, note: ""),
    .init(key: "env1.lvlVelSens",   label: "Env1 Level Vel Sens",   shortLabel: "E1VS",    page: .amp, sysexPage: 22, sysexSlot: 4, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env1.atkVelSens",   label: "Env1 Attack Vel Sens",  shortLabel: "E1VAS",   page: .amp, sysexPage: 22, sysexSlot: 5, minValue: 0, maxValue: 127, status: .verified, note: ""),

    // ── Env2 (Pages 23–25) ──
    .init(key: "env2.initLevel",    label: "Env2 Initial Level",    shortLabel: "E2IL",    page: .amp, sysexPage: 23, sysexSlot: 1, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env2.peakLevel",    label: "Env2 Peak Level",       shortLabel: "E2PK",    page: .amp, sysexPage: 23, sysexSlot: 2, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env2.bp1Level",     label: "Env2 Breakpoint 1",     shortLabel: "E2B1",    page: .amp, sysexPage: 23, sysexSlot: 3, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env2.bp2Level",     label: "Env2 Breakpoint 2",     shortLabel: "E2B2",    page: .amp, sysexPage: 23, sysexSlot: 4, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env2.susLevel",     label: "Env2 Sustain Level",    shortLabel: "E2SU",    page: .amp, sysexPage: 23, sysexSlot: 5, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env2.attack",       label: "Env2 Attack Time",      shortLabel: "E2AT",    page: .amp, sysexPage: 24, sysexSlot: 1, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "env2.decay1",       label: "Env2 Decay 1 Time",     shortLabel: "E2D1",    page: .amp, sysexPage: 24, sysexSlot: 2, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "env2.decay2",       label: "Env2 Decay 2 Time",     shortLabel: "E2D2",    page: .amp, sysexPage: 24, sysexSlot: 3, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "env2.decay3",       label: "Env2 Decay 3 Time",     shortLabel: "E2D3",    page: .amp, sysexPage: 24, sysexSlot: 4, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "env2.release",      label: "Env2 Release Time",     shortLabel: "E2RL",    page: .amp, sysexPage: 24, sysexSlot: 5, minValue: 0, maxValue: 255, status: .verified, note: ""),
    .init(key: "env2.kbdTrack",     label: "Env2 Key Track",        shortLabel: "E2KB",    page: .amp, sysexPage: 25, sysexSlot: 0, minValue: 0, maxValue: 255, status: .verified, note: ""),
    .init(key: "env2.velCurve",     label: "Env2 Vel Curve",        shortLabel: "E2VC",    page: .amp, sysexPage: 25, sysexSlot: 2, minValue: 0, maxValue: 9,   status: .verified, note: ""),
    .init(key: "env2.mode",         label: "Env2 Mode",             shortLabel: "E2MD",    page: .amp, sysexPage: 25, sysexSlot: 3, minValue: 0, maxValue: 2,   status: .verified, note: ""),
    .init(key: "env2.lvlVelSens",   label: "Env2 Level Vel Sens",   shortLabel: "E2VS",    page: .amp, sysexPage: 25, sysexSlot: 4, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env2.atkVelSens",   label: "Env2 Attack Vel Sens",  shortLabel: "E2VAS",   page: .amp, sysexPage: 25, sysexSlot: 5, minValue: 0, maxValue: 127, status: .verified, note: ""),

    // ── Env3 (Pages 26–28) ──
    .init(key: "env3.initLevel",    label: "Env3 Initial Level",    shortLabel: "E3IL",    page: .amp, sysexPage: 26, sysexSlot: 1, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env3.peakLevel",    label: "Env3 Peak Level",       shortLabel: "E3PK",    page: .amp, sysexPage: 26, sysexSlot: 2, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env3.bp1Level",     label: "Env3 Breakpoint 1",     shortLabel: "E3B1",    page: .amp, sysexPage: 26, sysexSlot: 3, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env3.bp2Level",     label: "Env3 Breakpoint 2",     shortLabel: "E3B2",    page: .amp, sysexPage: 26, sysexSlot: 4, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env3.susLevel",     label: "Env3 Sustain Level",    shortLabel: "E3SU",    page: .amp, sysexPage: 26, sysexSlot: 5, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env3.attack",       label: "Env3 Attack Time",      shortLabel: "E3AT",    page: .amp, sysexPage: 27, sysexSlot: 1, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "env3.decay1",       label: "Env3 Decay 1 Time",     shortLabel: "E3D1",    page: .amp, sysexPage: 27, sysexSlot: 2, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "env3.decay2",       label: "Env3 Decay 2 Time",     shortLabel: "E3D2",    page: .amp, sysexPage: 27, sysexSlot: 3, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "env3.decay3",       label: "Env3 Decay 3 Time",     shortLabel: "E3D3",    page: .amp, sysexPage: 27, sysexSlot: 4, minValue: 0, maxValue: 99,  status: .verified, note: ""),
    .init(key: "env3.release",      label: "Env3 Release Time",     shortLabel: "E3RL",    page: .amp, sysexPage: 27, sysexSlot: 5, minValue: 0, maxValue: 255, status: .verified, note: ""),
    .init(key: "env3.kbdTrack",     label: "Env3 Key Track",        shortLabel: "E3KB",    page: .amp, sysexPage: 28, sysexSlot: 0, minValue: 0, maxValue: 255, status: .verified, note: ""),
    .init(key: "env3.velCurve",     label: "Env3 Vel Curve",        shortLabel: "E3VC",    page: .amp, sysexPage: 28, sysexSlot: 2, minValue: 0, maxValue: 9,   status: .verified, note: ""),
    .init(key: "env3.mode",         label: "Env3 Mode",             shortLabel: "E3MD",    page: .amp, sysexPage: 28, sysexSlot: 3, minValue: 0, maxValue: 2,   status: .verified, note: ""),
    .init(key: "env3.lvlVelSens",   label: "Env3 Level Vel Sens",   shortLabel: "E3VS",    page: .amp, sysexPage: 28, sysexSlot: 4, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "env3.atkVelSens",   label: "Env3 Attack Vel Sens",  shortLabel: "E3VAS",   page: .amp, sysexPage: 28, sysexSlot: 5, minValue: 0, maxValue: 127, status: .verified, note: ""),

    // ── Amp shortcuts (same as env1/output; for macros / compatibility) ──
    .init(key: "amp.attack",        label: "Amp Attack (= env1)",   shortLabel: "AATK",    page: .amp, sysexPage: 998, sysexSlot: 40, minValue: 0, maxValue: 99,  status: .inferred, note: "Alias"),
    .init(key: "amp.decay",         label: "Amp Decay (= env1 d1)", shortLabel: "ADEC",    page: .amp, sysexPage: 998, sysexSlot: 41, minValue: 0, maxValue: 99,  status: .inferred, note: "Alias"),
    .init(key: "amp.sustain",       label: "Amp Sustain (= env1)", shortLabel: "ASUS",   page: .amp, sysexPage: 998, sysexSlot: 42, minValue: 0, maxValue: 127, status: .inferred, note: "Alias"),
    .init(key: "amp.release",       label: "Amp Release (= env1)",  shortLabel: "ARLS",    page: .amp, sysexPage: 998, sysexSlot: 43, minValue: 0, maxValue: 255, status: .inferred, note: "Alias"),
    .init(key: "amp.velocity",      label: "Amp Vel Sens (= env1)", shortLabel: "AVEL",    page: .amp, sysexPage: 998, sysexSlot: 44, minValue: 0, maxValue: 127, status: .inferred, note: "Alias"),
    .init(key: "amp.level",         label: "Amp Level (= output)",  shortLabel: "ALVL",    page: .amp, sysexPage: 998, sysexSlot: 45, minValue: 0, maxValue: 127, status: .inferred, note: "Alias"),
    .init(key: "amp.keyscale",      label: "Amp Keyscale (legacy)", shortLabel: "AKS",     page: .amp, sysexPage: 998, sysexSlot: 46, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "amp.alt",           label: "Amp Alt (legacy)",      shortLabel: "AALT",    page: .amp, sysexPage: 998, sysexSlot: 47, minValue: 0, maxValue: 127, status: .unknown, note: ""),

    // ── Effects (Pages 29–31) ──
    .init(key: "fx.type",           label: "Effect Type",           shortLabel: "FXTY",    page: .fx, sysexPage: 29, sysexSlot: 1, minValue: 0, maxValue: 21, status: .verified, note: "22 types"),
    .init(key: "fx.reverbMix",      label: "FX2 Mix / Decay",       shortLabel: "RVB",     page: .fx, sysexPage: 29, sysexSlot: 2, minValue: 0, maxValue: 99, status: .verified, note: "Type-dependent"),
    .init(key: "fx.fx1Mix",         label: "FX1 Mix",               shortLabel: "FX1",     page: .fx, sysexPage: 29, sysexSlot: 4, minValue: 0, maxValue: 127, status: .verified, note: ""),
    .init(key: "fx.fx2Mix",         label: "FX2 Mix",               shortLabel: "FX2",     page: .fx, sysexPage: 29, sysexSlot: 5, minValue: 0, maxValue: 127, status: .verified, note: ""),

    .init(key: "fx.mix",            label: "FX Mix (legacy)",       shortLabel: "MIX",     page: .fx, sysexPage: 998, sysexSlot: 50, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "fx.time",           label: "FX Time (legacy)",      shortLabel: "TIME",    page: .fx, sysexPage: 998, sysexSlot: 51, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "fx.feedback",       label: "FX FB (legacy)",        shortLabel: "FB",      page: .fx, sysexPage: 998, sysexSlot: 52, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "fx.depth",          label: "FX Depth (legacy)",     shortLabel: "DEP",     page: .fx, sysexPage: 998, sysexSlot: 53, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "fx.rate",           label: "FX Rate (legacy)",      shortLabel: "RATE",    page: .fx, sysexPage: 998, sysexSlot: 54, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "fx.tone",           label: "FX Tone (legacy)",      shortLabel: "TONE",    page: .fx, sysexPage: 998, sysexSlot: 55, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "fx.alt",            label: "FX Alt (legacy)",       shortLabel: "FALT",    page: .fx, sysexPage: 998, sysexSlot: 56, minValue: 0, maxValue: 127, status: .unknown, note: ""),

    // ── Voice Select (Page 38) — one status per voice slot ──
    .init(key: "voice.status0",     label: "Voice 1 Status",        shortLabel: "V1",      page: .wave, sysexPage: 38, sysexSlot: 0, minValue: 0, maxValue: 2, status: .verified, note: "OFF,ON,SOLO"),
    .init(key: "voice.status1",     label: "Voice 2 Status",        shortLabel: "V2",      page: .wave, sysexPage: 38, sysexSlot: 1, minValue: 0, maxValue: 2, status: .verified, note: ""),
    .init(key: "voice.status2",     label: "Voice 3 Status",        shortLabel: "V3",      page: .wave, sysexPage: 38, sysexSlot: 2, minValue: 0, maxValue: 2, status: .verified, note: ""),
    .init(key: "voice.status3",     label: "Voice 4 Status",        shortLabel: "V4",      page: .wave, sysexPage: 38, sysexSlot: 3, minValue: 0, maxValue: 2, status: .verified, note: ""),
    .init(key: "voice.status4",     label: "Voice 5 Status",        shortLabel: "V5",      page: .wave, sysexPage: 38, sysexSlot: 4, minValue: 0, maxValue: 2, status: .verified, note: ""),
    .init(key: "voice.status5",     label: "Voice 6 Status",        shortLabel: "V6",      page: .wave, sysexPage: 38, sysexSlot: 5, minValue: 0, maxValue: 2, status: .verified, note: ""),
    .init(key: "voice.status",      label: "Voice Status (legacy)", shortLabel: "VST",     page: .wave, sysexPage: 998, sysexSlot: 60, minValue: 0, maxValue: 2, status: .unknown, note: "Use voice.status0..5"),

    // ── Legacy wave keys ──
    .init(key: "wave.coarse",       label: "Wave Coarse (legacy)",  shortLabel: "WCRS",    page: .wave, sysexPage: 998, sysexSlot: 70, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "wave.fine",         label: "Wave Fine (legacy)",    shortLabel: "WFNE",    page: .wave, sysexPage: 998, sysexSlot: 71, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "wave.octave",       label: "Wave Octave (legacy)",  shortLabel: "WOCT",    page: .wave, sysexPage: 998, sysexSlot: 72, minValue: 0, maxValue: 127, status: .unknown, note: "See pitch.octave"),
    .init(key: "wave.level",        label: "Wave Level (legacy)",   shortLabel: "WLVL",    page: .wave, sysexPage: 998, sysexSlot: 73, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "wave.velocity",     label: "Wave Vel (legacy)",     shortLabel: "WVEL",    page: .wave, sysexPage: 998, sysexSlot: 74, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "wave.keytrack",     label: "Wave Kbd (legacy)",     shortLabel: "WKBD",    page: .wave, sysexPage: 998, sysexSlot: 75, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "wave.pan",          label: "Wave Pan (legacy)",     shortLabel: "WPAN",    page: .wave, sysexPage: 998, sysexSlot: 76, minValue: 0, maxValue: 127, status: .unknown, note: "See output.pan"),

    // ── Macro page (editor macros; not hardware parameters) ──
    .init(key: "macro.brightness",  label: "Macro · Brightness",    shortLabel: "BRITE",   page: .macro, sysexPage: 999, sysexSlot: 0, minValue: 0, maxValue: 127, status: .unknown, note: "Drives filter etc."),
    .init(key: "macro.motion",      label: "Macro · Motion",        shortLabel: "MOT",     page: .macro, sysexPage: 999, sysexSlot: 1, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "macro.weight",      label: "Macro · Weight",        shortLabel: "WT",      page: .macro, sysexPage: 999, sysexSlot: 2, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "macro.attack",      label: "Macro · Attack",        shortLabel: "ATK",     page: .macro, sysexPage: 999, sysexSlot: 3, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "macro.space",       label: "Macro · Space",         shortLabel: "SPC",     page: .macro, sysexPage: 999, sysexSlot: 4, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "macro.width",       label: "Macro · Width",         shortLabel: "WD",      page: .macro, sysexPage: 999, sysexSlot: 5, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "macro.dirt",        label: "Macro · Dirt",          shortLabel: "DIRT",    page: .macro, sysexPage: 999, sysexSlot: 6, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "macro.animate",     label: "Macro · Animate",       shortLabel: "ANIM",    page: .macro, sysexPage: 999, sysexSlot: 7, minValue: 0, maxValue: 127, status: .unknown, note: ""),

    // ── Sequencer (UI placeholders; virtual buttons for play/stop/rec) ──
    .init(key: "seq.tempo",         label: "Seq Tempo (BPM)",       shortLabel: "BPM",     page: .sequencer, sysexPage: 997, sysexSlot: 0, minValue: 1, maxValue: 300, status: .unknown, note: ""),
    .init(key: "seq.song",          label: "Song #",                shortLabel: "SONG",    page: .sequencer, sysexPage: 997, sysexSlot: 1, minValue: 1, maxValue: 60,  status: .unknown, note: ""),
    .init(key: "seq.sequence",      label: "Sequence #",            shortLabel: "SEQ",     page: .sequencer, sysexPage: 997, sysexSlot: 2, minValue: 1, maxValue: 60,  status: .unknown, note: ""),
    .init(key: "seq.track",         label: "Track #",               shortLabel: "TRK",     page: .sequencer, sysexPage: 997, sysexSlot: 3, minValue: 1, maxValue: 24,  status: .unknown, note: ""),
    .init(key: "seq.loop",          label: "Loop",                  shortLabel: "LOOP",    page: .sequencer, sysexPage: 997, sysexSlot: 4, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "seq.quant",         label: "Quantize",              shortLabel: "QNT",     page: .sequencer, sysexPage: 997, sysexSlot: 5, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "seq.click",         label: "Click",                 shortLabel: "CLK",     page: .sequencer, sysexPage: 997, sysexSlot: 6, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "seq.mode",          label: "Seq Mode",              shortLabel: "MODE",    page: .sequencer, sysexPage: 997, sysexSlot: 7, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "seq.tap",           label: "Tap Tempo",             shortLabel: "TAP",     page: .sequencer, sysexPage: 997, sysexSlot: 8, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "seq.clockSource",   label: "Clock Source",          shortLabel: "CLKS",    page: .sequencer, sysexPage: 997, sysexSlot: 9, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "seq.punchIn",       label: "Punch In",              shortLabel: "PIN",     page: .sequencer, sysexPage: 997, sysexSlot: 10, minValue: 0, maxValue: 127, status: .unknown, note: ""),
    .init(key: "seq.punchOut",      label: "Punch Out",             shortLabel: "POUT",    page: .sequencer, sysexPage: 997, sysexSlot: 11, minValue: 0, maxValue: 127, status: .unknown, note: ""),
]
