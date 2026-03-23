import XCTest

@testable import VFXCtrl

final class GotekDiskCatalogTests: XCTestCase {
    func testParseCSVLine() {
        let csv = """
        Disk Number,Source Collection,Sub-Collection,Disk Name,Sound Category,Compatibility,Notes
        1,ATW,CO,MyDisk,Cat,VFX-SD,Hello world
        """
        let rows = GotekDiskCatalog.parse(csvString: csv)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].diskNumber, 1)
        XCTAssertEqual(rows[0].diskName, "MyDisk")
        XCTAssertEqual(rows[0].notes, "Hello world")
    }
}
