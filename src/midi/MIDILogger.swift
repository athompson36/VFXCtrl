import Foundation

struct MIDILogEntry: Identifiable, Codable {
    let id = UUID()
    let timestamp: Date
    let direction: String
    let hex: String
}
