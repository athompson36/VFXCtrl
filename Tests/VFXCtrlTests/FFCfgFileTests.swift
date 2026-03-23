import XCTest

@testable import VFXCtrl

final class FFCfgFileTests: XCTestCase {
    func testParse_skipsComments() {
        let text = """
        # hi
        nav-mode = indexed
        ;x
        host = ensoniq
        """
        let m = FFCfgFile.parse(text)
        XCTAssertEqual(m["nav-mode"], "indexed")
        XCTAssertEqual(m["host"], "ensoniq")
    }

    func testEncode_ordersKnownKeysFirst() {
        let m = ["z-extra": "1", "nav-mode": "indexed", "host": "ensoniq"]
        let s = FFCfgFile.encode(entries: m, headerComment: nil)
        XCTAssertTrue(s.contains("nav-mode = indexed"))
        XCTAssertTrue(s.contains("host = ensoniq"))
    }

    func testRecommended_hasIndexedAndEnsoniq() {
        let r = FFCfgFile.recommendedEntries(indexedPrefix: "DSKA")
        XCTAssertEqual(r["nav-mode"], "indexed")
        XCTAssertTrue(r["indexed-prefix"]?.contains("DSKA") == true)
        XCTAssertEqual(r["host"], "ensoniq")
    }

    func testRecommended_emptyIndexedPrefix_quoted() {
        let r = FFCfgFile.recommendedEntries(indexedPrefix: "")
        XCTAssertEqual(r["indexed-prefix"], "\"\"")
    }

    func testRecommended_extendedDisplayManualSelect() {
        let r = FFCfgFile.recommendedEntries(indexedPrefix: "")
        XCTAssertEqual(r["autoselect-file-secs"], "0")
        XCTAssertEqual(r["autoselect-folder-secs"], "0")
        XCTAssertEqual(r["ejected-on-startup"], "no")
        XCTAssertEqual(r["rotary"], "full,reverse")
        XCTAssertEqual(r["oled-font"], "8x16")
        XCTAssertEqual(r["display-type"], "oled-128x64")
        XCTAssertEqual(r["display-order"], "0d,7,1")
        XCTAssertEqual(r["display-scroll-pause"], "1800")
    }

    func testMergeRecommended_respectsReplaceFlag() {
        let base = ["nav-mode": "native", "host": "ensoniq"]
        let fill = FFCfgFile.mergeRecommended(into: base, indexedPrefix: "X", replaceRecommendedKeys: false)
        XCTAssertEqual(fill["nav-mode"], "native")
        XCTAssertNotNil(fill["indexed-prefix"])

        let rep = FFCfgFile.mergeRecommended(into: base, indexedPrefix: "X", replaceRecommendedKeys: true)
        XCTAssertEqual(rep["nav-mode"], "indexed")
    }
}
