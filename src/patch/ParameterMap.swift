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
    let page: EditorPage
    let address: Int?
    let minValue: Int
    let maxValue: Int
    let status: VerificationStatus
    let note: String
}

let initialParameterMap: [ParameterDefinition] = [
    .init(key: "wave.select", label: "Wave", page: .wave, address: nil, minValue: 0, maxValue: 127, status: .unknown, note: "Needs original spec or capture"),
    .init(key: "filter.cutoff", label: "Cutoff", page: .filter, address: nil, minValue: 0, maxValue: 127, status: .unknown, note: "Needs original spec or capture"),
    .init(key: "amp.attack", label: "Attack", page: .amp, address: nil, minValue: 0, maxValue: 127, status: .unknown, note: "Needs original spec or capture"),
    .init(key: "seq.tempo", label: "Tempo", page: .sequencer, address: nil, minValue: 0, maxValue: 255, status: .unknown, note: "Verify if directly addressable"),
    .init(key: "fx.mix", label: "FX Mix", page: .fx, address: nil, minValue: 0, maxValue: 127, status: .unknown, note: "Verify if patch-scoped over SysEx")
]
