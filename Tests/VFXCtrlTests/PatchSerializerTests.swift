import XCTest
@testable import VFXCtrl

final class PatchSerializerTests: XCTestCase {

    func testSerialize_returnsRawSysExWhenPresent() throws {
        let raw = Data([0xF0, 0x0F, 0x05, 0x01, 0x02, 0xF7])
        let patch = VFXPatch(name: "T", rawSysEx: raw, parameters: [:])
        let out = try PatchSerializer().serialize(patch)
        XCTAssertEqual(out, raw)
    }

    func testSerialize_throwsWhenNoRawSysEx() {
        let patch = VFXPatch(name: "No raw", rawSysEx: nil, parameters: [:])
        XCTAssertThrowsError(try PatchSerializer().serialize(patch))
    }

    /// Parse → serialize must preserve bytes for a minimal valid program dump envelope.
    func testParseThenSerialize_roundTripPreservesRawSysEx() throws {
        var data = Data(count: 28)
        data[0] = 0xF0
        data[1] = 0x0F
        data[2] = 0x05
        data[27] = 0xF7
        let patch = try PatchParser().parseProgramDump(data)
        let out = try PatchSerializer().serialize(patch)
        XCTAssertEqual(out, data)
    }
}
