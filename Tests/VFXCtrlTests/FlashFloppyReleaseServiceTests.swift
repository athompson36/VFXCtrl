import XCTest

@testable import VFXCtrl

final class FlashFloppyReleaseServiceTests: XCTestCase {
    func testParseLatestReleaseJSON_findsZipAsset() throws {
        let json = """
        {
          "tag_name": "v9.99",
          "assets": [
            { "name": "README.txt", "browser_download_url": "https://example.com/readme" },
            { "name": "flashfloppy-9.99.zip", "browser_download_url": "https://example.com/ff.zip" }
          ]
        }
        """.data(using: .utf8)!

        let info = try FlashFloppyReleaseService.parseLatestReleaseJSON(json)
        XCTAssertEqual(info.tag, "v9.99")
        XCTAssertEqual(info.zipAssetName, "flashfloppy-9.99.zip")
        XCTAssertEqual(info.zipDownloadURL.absoluteString, "https://example.com/ff.zip")
    }

    func testParseLatestReleaseJSON_caseInsensitivePrefix() throws {
        let json = """
        {
          "tag_name": "v1.0",
          "assets": [
            { "name": "FlashFloppy-1.0.ZIP", "browser_download_url": "https://example.com/z.zip" }
          ]
        }
        """.data(using: .utf8)!

        let info = try FlashFloppyReleaseService.parseLatestReleaseJSON(json)
        XCTAssertEqual(info.zipAssetName, "FlashFloppy-1.0.ZIP")
    }

    func testParseLatestReleaseJSON_noZipThrows() {
        let json = """
        { "tag_name": "v1.0", "assets": [ { "name": "other.zip", "browser_download_url": "https://x/z.zip" } ] }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try FlashFloppyReleaseService.parseLatestReleaseJSON(json)) { err in
            let se = err as? FlashFloppyReleaseService.ServiceError
            XCTAssertEqual(se, .noZipAsset)
        }
    }
}
