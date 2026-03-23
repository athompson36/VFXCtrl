import XCTest

@testable import VFXCtrl

final class GotekIndexedRackDeployTests: XCTestCase {
    func testIsDeployableFileName_acceptsRackPayload() {
        XCTAssertTrue(GotekIndexedRackDeploy.isDeployableFileName("0000_VFX_SD_OS_2.10.IMG"))
        XCTAssertTrue(GotekIndexedRackDeploy.isDeployableFileName("0155_Blank_002.hfe"))
        XCTAssertTrue(GotekIndexedRackDeploy.isDeployableFileName("FF.CFG"))
    }

    func testIsDeployableFileName_rejectsContextFiles() {
        XCTAssertFalse(GotekIndexedRackDeploy.isDeployableFileName("IMG.CFG"))
        XCTAssertFalse(GotekIndexedRackDeploy.isDeployableFileName("img.cfg"))
        XCTAssertFalse(GotekIndexedRackDeploy.isDeployableFileName("IMAGE_A.CFG"))
        XCTAssertFalse(GotekIndexedRackDeploy.isDeployableFileName("VFX_RACK_CATALOG.json"))
        XCTAssertFalse(GotekIndexedRackDeploy.isDeployableFileName("._0000_Foo.HFE"))
        XCTAssertFalse(GotekIndexedRackDeploy.isDeployableFileName("DSKA0000_VFX.IMG"))
        XCTAssertFalse(GotekIndexedRackDeploy.isDeployableFileName("0000noUnderscore.HFE"))
        XCTAssertFalse(GotekIndexedRackDeploy.isDeployableFileName("0000_patch.syx"))
    }

    func testCopyDeployableFiles_filtersAndOverwrites() throws {
        let fm = FileManager.default
        let src = fm.temporaryDirectory.appendingPathComponent("rack-src-\(UUID().uuidString)")
        let dst = fm.temporaryDirectory.appendingPathComponent("rack-dst-\(UUID().uuidString)")
        try fm.createDirectory(at: src, withIntermediateDirectories: true)
        try fm.createDirectory(at: dst, withIntermediateDirectories: true)
        defer {
            try? fm.removeItem(at: src)
            try? fm.removeItem(at: dst)
        }

        try Data([1, 2]).write(to: src.appendingPathComponent("0001_x.HFE"))
        try Data([3]).write(to: src.appendingPathComponent("junk.md"))
        try Data([9]).write(to: src.appendingPathComponent("FF.CFG"))

        let r1 = try GotekIndexedRackDeploy.copyDeployableFiles(from: src, to: dst)
        XCTAssertEqual(r1.copiedFileNames.count, 2)
        XCTAssertTrue(r1.copiedFileNames.contains("0001_x.HFE"))
        XCTAssertTrue(r1.copiedFileNames.contains("FF.CFG"))
        XCTAssertEqual(try Data(contentsOf: dst.appendingPathComponent("0001_x.HFE")), Data([1, 2]))
        XCTAssertFalse(fm.fileExists(atPath: dst.appendingPathComponent("junk.md").path))
        XCTAssertGreaterThanOrEqual(r1.skippedOtherFileCount, 1)

        try Data([7, 8]).write(to: src.appendingPathComponent("0001_x.HFE"))
        let r2 = try GotekIndexedRackDeploy.copyDeployableFiles(from: src, to: dst)
        XCTAssertEqual(try Data(contentsOf: dst.appendingPathComponent("0001_x.HFE")), Data([7, 8]))
        XCTAssertEqual(r2.copiedFileNames.count, 2)
    }

    func testCopyDeployableFiles_throwsWhenNothingToCopy() throws {
        let fm = FileManager.default
        let src = fm.temporaryDirectory.appendingPathComponent("rack-empty-\(UUID().uuidString)")
        let dst = fm.temporaryDirectory.appendingPathComponent("rack-dst2-\(UUID().uuidString)")
        try fm.createDirectory(at: src, withIntermediateDirectories: true)
        try fm.createDirectory(at: dst, withIntermediateDirectories: true)
        defer {
            try? fm.removeItem(at: src)
            try? fm.removeItem(at: dst)
        }
        try Data([1]).write(to: src.appendingPathComponent("only.md"))
        XCTAssertThrowsError(try GotekIndexedRackDeploy.copyDeployableFiles(from: src, to: dst)) { err in
            XCTAssertTrue(err is DeployError)
        }
    }
}
