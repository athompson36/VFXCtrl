import Foundation

/// VFX-SD modulation: **16** mod sources (0…15) and **10** destinations (see `ParameterEnumLabels` / MIDI spec).
/// Hardware has 2 routing slots; UI uses `mod.src1`/`dest1`/`depth1`, `mod.src2`/`dest2`/`depth2`.
enum ModMatrixModel {
    static var sources: [(index: Int, name: String)] {
        ParameterEnumLabels.modSourcePickerRows().map { (index: $0.value, name: $0.name) }
    }

    static var destinations: [(index: Int, name: String)] {
        ParameterEnumLabels.modDestinationPickerRows().map { (index: $0.value, name: $0.name) }
    }

    static func matrixKey(sourceIndex: Int, destIndex: Int) -> String {
        "mod.matrix.\(sourceIndex).\(destIndex)"
    }
}
