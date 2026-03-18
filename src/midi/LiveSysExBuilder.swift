import Foundation

/// Builds SysEx messages for live parameter edits. Master volume format uses command 0x05
/// (Parameter Change Request) per Ensoniq Fizmo/MR; address is still TBD. See docs/SYSEX_RESEARCH_FINDINGS.md and LIVE_PARAMETER_RESEARCH.md.
enum LiveSysExBuilder {
    private static let sysexStart: UInt8 = 0xF0
    private static let sysexEnd: UInt8 = 0xF7
    private static let ensoniqId: UInt8 = 0x0F
    private static let vfxModelByte: UInt8 = 0x05

    /// Keys that have a (possibly placeholder) real-time edit message. Add keys here as formats are verified.
    static let supportedLiveKeys: Set<String> = ["sys.masterVol"]

    /// Builds a SysEx message for the given key and value, or nil if the key is not supported or value is out of range.
    /// Message format for sys.masterVol is a PLACEHOLDER; replace bytes when spec or capture is available.
    static func build(key: String, value: Int) -> Data? {
        switch key {
        case "sys.masterVol":
            return buildMasterVolume(value: value)
        default:
            return nil
        }
    }

    /// VFX-SD master volume. Format inferred from Ensoniq Fizmo/MR docs (command 0x05 = parameter change).
    /// Address 0x0000 is placeholder; replace with verified address from v2.10 spec or Midi Quest capture.
    /// See docs/SYSEX_RESEARCH_FINDINGS.md.
    private static func buildMasterVolume(value: Int) -> Data? {
        let v = UInt8(min(127, max(0, value)))
        // F0 0F 05 [sub] [dev] 05 [addrHi] [addrLo] [value] F7
        // Ensoniq Fizmo/MR use 05 = Parameter Change Request; VFX-SD model byte 05; address TBD
        var bytes: [UInt8] = [
            sysexStart,
            ensoniqId,
            vfxModelByte,
            0x01,   // sub-id (01 in Fizmo for param change path; 00 in our program dump)
            0x00,   // device ID (0 = first device)
            0x05,   // command: Parameter Change Request (per Ensoniq Fizmo/MR spec)
            0x00,   // address high (placeholder - master vol address from spec or capture)
            0x00,   // address low
            v,
        ]
        // Checksum: many Ensoniq use XOR of data bytes or (0 - sum) & 0x7F. Uncomment and set when known.
        // let checksum = ensoniqChecksum(bytes.dropFirst(1).dropLast(1))
        // bytes.insert(checksum, at: bytes.count - 1)
        bytes.append(sysexEnd)
        return Data(bytes)
    }
}
