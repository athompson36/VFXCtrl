import Foundation

/// Maps macro knob values to one or more parameters. Addresses are placeholders until verified.
/// See docs/MACRO_MAP.md for the mapping table.
struct MacroEngine {
    /// Apply a macro value to the patch. Each macro drives one or more parameter keys.
    /// Real-time SysEx send (when addresses are verified) should be done by the caller.
    func apply(_ macroKey: String, value: Int, to patch: inout VFXPatch) {
        switch macroKey {
        case "macro.brightness":
            patch.parameters["filter.cutoff"] = value
            patch.parameters["filter.modAmt"] = min(255, value * 2)
        case "macro.motion":
            patch.parameters["motion.amount"] = value
            patch.parameters["lfo1.depth"] = value / 2
        case "macro.weight":
            patch.parameters["amp.attack"] = 127 - value / 2
            patch.parameters["amp.level"] = value
        case "macro.attack":
            patch.parameters["amp.attack"] = value
            patch.parameters["amp.decay"] = min(127, value + 20)
        case "macro.space":
            patch.parameters["fx.mix"] = value / 2
            patch.parameters["fx.feedback"] = value / 4
        case "macro.width":
            patch.parameters["wave.pan"] = value
            patch.parameters["perf.detune"] = value / 4
        case "macro.dirt":
            patch.parameters["filter.cutoff"] = min(127, (patch.parameters["filter.cutoff"] ?? 64) + value / 4)
            patch.parameters["filter.env"] = value / 2
        case "macro.animate":
            patch.parameters["lfo1.rate"] = value / 2
            patch.parameters["lfo2.rate"] = value / 4
        default:
            break
        }
    }

    /// All macro keys in UI order (Macro page).
    static let macroKeys: [String] = [
        "macro.brightness", "macro.motion", "macro.weight", "macro.attack",
        "macro.space", "macro.width", "macro.dirt", "macro.animate",
    ]
}
