import XCTest
@testable import VFXCtrl

final class PatchParserTests: XCTestCase {
    func testIsLikelyProgramDump_rejectsTooShort() {
        let short = Data([0xF0, 0x0F, 0x05, 0x00, 0xF7])
        XCTAssertFalse(PatchParser.isLikelyProgramDump(short))
    }

    func testIsLikelyProgramDump_rejectsWrongStart() {
        var data = Data(count: 50)
        data[0] = 0xF1
        data[49] = 0xF7
        data.replaceSubrange(0..<3, with: [0xF1, 0x0F, 0x05])
        XCTAssertFalse(PatchParser.isLikelyProgramDump(data))
    }

    func testIsLikelyProgramDump_rejectsWrongEnd() {
        var data = Data(count: 50)
        data[0] = 0xF0
        data[49] = 0xF6
        data.replaceSubrange(0..<3, with: [0xF0, 0x0F, 0x05])
        XCTAssertFalse(PatchParser.isLikelyProgramDump(data))
    }

    func testIsLikelyProgramDump_acceptsValidHeader() {
        var data = Data(count: 25)
        data[0] = 0xF0
        data[1] = 0x0F
        data[2] = 0x05
        data[24] = 0xF7
        XCTAssertTrue(PatchParser.isLikelyProgramDump(data))
    }

    func testParseProgramDump_throwsTooShort() {
        let data = Data([0xF0, 0x0F, 0x05, 0xF7])
        XCTAssertThrowsError(try PatchParser().parseProgramDump(data)) { error in
            XCTAssertEqual(error as? PatchParserError, .tooShort)
        }
    }

    func testParseProgramDump_returnsPatchWithRawSysEx() throws {
        var data = Data(count: 30)
        data[0] = 0xF0
        data[1] = 0x0F
        data[2] = 0x05
        data[29] = 0xF7
        let patch = try PatchParser().parseProgramDump(data)
        XCTAssertEqual(patch.rawSysEx, data)
        XCTAssertEqual(patch.name, "Captured Program")
        XCTAssertNotNil(patch.parameters["raw.0"])
    }
}
