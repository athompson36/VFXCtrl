import Foundation

enum PatchParserError: Error, Equatable {
    case tooShort
    case notSysEx
    case noEndMarker
    case checksumMismatch
}

/// VFX-SD program dump: F0 0F 05 ... F7 (Ensoniq manufacturer 0x0F; exact header TBD).
private let expectedHeaderPrefix: [UInt8] = [0xF0, 0x0F, 0x05]
private let sysexEnd: UInt8 = 0xF7
private let minProgramDumpLength = 20

struct PatchParser {
    /// Returns true if data looks like a VFX-SD program dump (F0 0F 05 ... F7).
    static func isLikelyProgramDump(_ data: Data) -> Bool {
        guard data.count >= minProgramDumpLength,
              data.first == 0xF0,
              data.last == sysexEnd else { return false }
        for (i, b) in expectedHeaderPrefix.enumerated() where data[i] != b { return false }
        return true
    }

    /// - Parameter validateChecksum: If true, validates checksum (algorithm TBD per VFX-SD spec). Use false for raw-tool / capture mode.
    func parseProgramDump(_ data: Data, validateChecksum: Bool = false) throws -> VFXPatch {
        guard data.count >= minProgramDumpLength else { throw PatchParserError.tooShort }
        guard data.first == 0xF0 else { throw PatchParserError.notSysEx }
        guard data.last == sysexEnd else { throw PatchParserError.noEndMarker }
        guard data.prefix(expectedHeaderPrefix.count).elementsEqual(expectedHeaderPrefix) else {
            throw PatchParserError.notSysEx
        }
        if validateChecksum && !isChecksumValid(data) {
            throw PatchParserError.checksumMismatch
        }

        let payloadStart = expectedHeaderPrefix.count
        let payloadEnd = data.count - 1
        let payload = data.subdata(in: payloadStart..<payloadEnd)

        let name = extractName(from: payload)
        var parameters: [String: Int] = [:]
        for i in 0..<min(payload.count, 256) {
            parameters["raw.\(i)"] = Int(payload[i])
        }

        return VFXPatch(
            name: name,
            category: "Unsorted",
            notes: "",
            rawSysEx: data,
            parameters: parameters
        )
    }

    /// Attempt to read a short ASCII name from the start of the payload (offset/length TBD per spec).
    private func extractName(from payload: Data) -> String {
        let maxLen = 16
        let end = min(maxLen, payload.count)
        let slice = payload.prefix(end)
        let valid = slice.filter { $0 >= 0x20 && $0 < 0x7F }
        if valid.count >= 2, let s = String(bytes: valid, encoding: .ascii), !s.trimmingCharacters(in: .whitespaces).isEmpty {
            return s.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "Captured Program"
    }

    /// Checksum algorithm TBD from VFX-SD spec. Until verified, returns true (accept all).
    private func isChecksumValid(_ data: Data) -> Bool {
        // TODO: implement when VFX-SD checksum format is documented (e.g. XOR/sum in last byte).
        true
    }
}
