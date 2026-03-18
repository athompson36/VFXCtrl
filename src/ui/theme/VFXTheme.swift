import SwiftUI

/// VFX-SD inspired theme: dark panel, vacuum-fluorescent display (VFD) green accent, 80s Ensoniq-era look.
enum VFXTheme {
    /// Dark grey panel (typical late-80s synth).
    static let panelBackground = Color(red: 0.14, green: 0.14, blue: 0.16)
    /// Slightly lighter surface for cards/controls.
    static let surface = Color(red: 0.18, green: 0.18, blue: 0.20)
    /// VFD-style green (vacuum fluorescent display).
    static let vfdGreen = Color(red: 0.25, green: 0.88, blue: 0.55)
    /// Dimmer VFD green for secondary elements.
    static let vfdGreenDim = Color(red: 0.18, green: 0.65, blue: 0.40)
    /// Amber option (some VFDs were amber).
    static let vfdAmber = Color(red: 0.95, green: 0.72, blue: 0.25)
    /// Primary text on dark.
    static let textPrimary = Color.white.opacity(0.92)
    static let textSecondary = Color.white.opacity(0.6)
    /// Knob ring / encoder border.
    static let knobRing = Color.white.opacity(0.35)
    static let knobRingHighlight = vfdGreen
}
