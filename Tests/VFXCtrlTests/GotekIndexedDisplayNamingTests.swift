import XCTest

@testable import VFXCtrl

final class GotekIndexedDisplayNamingTests: XCTestCase {
    func testSanitize_stripsIllegalChars() {
        XCTAssertEqual(GotekIndexedDisplayNaming.sanitizeFilenameSuffix("a/b:c"), "a_b_c")
    }

    func testPlainIndexedFileName() {
        let n = GotekIndexedDisplayNaming.plainIndexedFileName(
            slot: 2,
            prefix: "DSKA",
            fileExtension: "HFE"
        )
        XCTAssertEqual(n, "DSKA0002.hfe")
        let n2 = GotekIndexedDisplayNaming.plainIndexedFileName(
            slot: 2,
            prefix: "",
            fileExtension: "HFE"
        )
        XCTAssertEqual(n2, "0002.hfe")
    }

    func testIndexedFileName_withLabel_forLooseFiles() {
        let n = GotekIndexedDisplayNaming.indexedFileName(
            slot: 2,
            prefix: "DSKA",
            friendlyLabel: "ATW Colorado alogdig",
            fileExtension: "HFE"
        )
        XCTAssertEqual(n, "DSKA0002_ATW_Colorado_alogdig.hfe")
    }

    func testFriendlyRenameScript_containsMvFromPlain() throws {
        let json = """
        {"slots":[{"slot":0,"indexed_filename":"DSKA0000_VFX_SD_OS_2.10.IMG","friendly_label":"OS"}]}
        """.data(using: .utf8)!
        let cat = try JSONDecoder().decode(VFXRackCatalogFile.self, from: json)
        let sh = VFXRackFriendlyIndexedRenameScript.bashScript(catalog: cat, indexedPrefix: "DSKA")
        XCTAssertTrue(sh.contains("0000.img"))
        XCTAssertTrue(sh.contains("DSKA0000_VFX_SD_OS_2.10.IMG"))
        XCTAssertTrue(sh.contains("mv -f"))
    }
}
