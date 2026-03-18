import Foundation

/// VFX-SD modulation matrix: 15 sources × 10 destinations (see docs/VFX_MODULATION_MATRIX.md).
enum ModMatrixModel {
    static let sources: [(index: Int, name: String)] = [
        (0, "Pressure"),
        (1, "Velocity"),
        (2, "Mod Wheel"),
        (3, "Pitch Wheel"),
        (4, "Pedal"),
        (5, "Env 1"),
        (6, "Env 2"),
        (7, "LFO"),
        (8, "Keyboard"),
        (9, "Timbre"),
        (10, "Random"),
        (11, "Mix/Shaper"),
        (12, "Ext MIDI"),
        (13, "Wheel+Press"),
        (14, "Vel+Press"),
    ]

    static let destinations: [(index: Int, name: String)] = [
        (0, "Wave Start"),
        (1, "Pitch"),
        (2, "Filt1 Cut"),
        (3, "Filt2 Cut"),
        (4, "LFO Rate"),
        (5, "LFO Level"),
        (6, "Volume"),
        (7, "Pan"),
        (8, "Transwave"),
        (9, "FX Mix"),
    ]

    static func matrixKey(sourceIndex: Int, destIndex: Int) -> String {
        "mod.matrix.\(sourceIndex).\(destIndex)"
    }
}
