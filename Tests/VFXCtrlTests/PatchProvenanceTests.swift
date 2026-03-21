import XCTest
@testable import VFXCtrl

final class PatchProvenanceTests: XCTestCase {

    func testSha256Hex_emptyData_matchesKnownVector() {
        XCTAssertEqual(
            SysExDigest.sha256Hex(of: Data()),
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        )
    }

    func testSha256Hex_stableForSampleSysEx() {
        let data = Data([0xF0, 0x0F, 0x05, 0x01, 0x02, 0xF7])
        let a = SysExDigest.sha256Hex(of: data)
        let b = SysExDigest.sha256Hex(of: data)
        XCTAssertEqual(a, b)
        XCTAssertEqual(a.count, 64)
    }

    func testVFXPatchCodable_roundTripPreservesProvenance() throws {
        let raw = Data([0xF0, 0x0F, 0x05, 0xAA, 0xF7])
        var patch = VFXPatch(name: "Test", rawSysEx: raw, parameters: ["k": 1])
        patch.sourceFileName = "factory.syx"
        patch.importedAt = Date(timeIntervalSince1970: 1_700_000_000)
        patch.sourceSynthOS = "2.10"
        patch.sysexSHA256 = SysExDigest.sha256Hex(of: raw)
        patch.importIntegrityNote = PatchParser.programDumpChecksumNotValidatedNote

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = try encoder.encode(patch)
        let decoded = try decoder.decode(VFXPatch.self, from: data)

        XCTAssertEqual(decoded.name, patch.name)
        XCTAssertEqual(decoded.sourceFileName, patch.sourceFileName)
        XCTAssertEqual(decoded.sourceSynthOS, patch.sourceSynthOS)
        XCTAssertEqual(decoded.sysexSHA256, patch.sysexSHA256)
        XCTAssertEqual(decoded.rawSysEx, patch.rawSysEx)
        XCTAssertEqual(decoded.parameters["k"], 1)
        XCTAssertEqual(decoded.importIntegrityNote, patch.importIntegrityNote)
    }
}
