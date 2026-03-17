import Foundation

struct MacroEngine {
    func applyBrightness(_ value: Int, to patch: inout VFXPatch) {
        patch.parameters["filter.cutoff"] = value
        patch.parameters["filter.envAmount"] = value / 2
    }
}
