import Foundation

/// Helpers for organizing `ParameterDefinition` rows by editor tab and VFX-SD hardware page.
enum ParameterCatalog {

    /// Definitions for one editor tab, sorted by hardware page then slot.
    static func definitions(for editorPage: EditorPage) -> [ParameterDefinition] {
        initialParameterMap
            .filter { $0.page == editorPage }
            .sorted { a, b in
                if a.sysexPage != b.sysexPage { return a.sysexPage < b.sysexPage }
                if a.sysexSlot != b.sysexSlot { return a.sysexSlot < b.sysexSlot }
                return a.key < b.key
            }
    }

    /// All keys declared in the librarian map (for initializing patch editor state).
    static var allMappedKeys: [String] {
        Array(Set(initialParameterMap.map(\.key))).sorted()
    }

    /// Section title for a hardware page number within an editor tab.
    static func sectionTitle(sysexPage: Int) -> String {
        switch sysexPage {
        case 0...2: return "System / master · page \(sysexPage)"
        case 3...4: return "MIDI control · page \(sysexPage)"
        case 5: return "Program control · page 5"
        case 6: return "Mod mixer · page 6"
        case 7...10: return "Wave · pages 7–10 (class-dependent)"
        case 11: return "Pitch · page 11"
        case 12: return "Pitch modulation · page 12"
        case 13: return "Filter #1 · page 13"
        case 14: return "Filter #2 · page 14"
        case 15: return "Output / voice level · page 15"
        case 16: return "Output / routing & pan · page 16"
        case 17: return "Output / priority · page 17"
        case 18...19: return "LFO · pages 18–19"
        case 20...22: return "Env1 (amplitude) · pages 20–22"
        case 23...25: return "Env2 · pages 23–25"
        case 26...28: return "Env3 · pages 26–28"
        case 29...31: return "Effects · pages 29–31"
        case 38: return "Voice status · page 38"
        case 900: return "Master (MIDI CC)"
        case 997: return "Sequencer (UI)"
        case 998: return "Legacy / patch-only (no live SysEx yet)"
        case 999: return "Performance (patch / UI only)"
        default: return "Page \(sysexPage)"
        }
    }
}
