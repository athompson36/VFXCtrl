import Foundation

/// Top-level UI mode: synth editor vs Gotek / FlashFloppy workflows.
enum AppWorkspace: String, CaseIterable, Identifiable {
    case synth = "Synth"
    case floppy = "Floppy Emulator"

    var id: String { rawValue }

    var title: String { rawValue }
}
