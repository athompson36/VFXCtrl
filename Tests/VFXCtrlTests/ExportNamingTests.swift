import XCTest
@testable import VFXCtrl

final class ExportNamingTests: XCTestCase {

    func testSanitizeFilenameStem_stripsHostileChars() {
        XCTAssertEqual(ExportNaming.sanitizeFilenameStem("a/b:c"), "a_b_c")
        XCTAssertEqual(ExportNaming.sanitizeFilenameStem("  lead  "), "lead")
    }

    func testCategoryFolder_knownCategories() {
        XCTAssertEqual(ExportNaming.categoryFolder(for: "Pads"), "03_PAD")
        XCTAssertEqual(ExportNaming.categoryFolder(for: "Factory"), "00_FACTORY")
        XCTAssertEqual(ExportNaming.categoryFolder(for: "unsorted"), "99_UNSORTED")
    }

    func testExportStem_numericPrefixAndTruncate() {
        let p = VFXPatch(name: "Very Long Patch Name Here", category: "Pads", rawSysEx: Data([1]))
        let opts = ExportNaming.Options(maxBaseNameLength: 8, numericPrefix: true, categorySubfolders: false)
        XCTAssertEqual(ExportNaming.exportStem(patch: p, index: 0, options: opts), "01_Very Lon")
    }

    func testOrderPrefix_wrapsToThreeDigits() {
        XCTAssertEqual(ExportNaming.orderPrefix(for: 0), "01_")
        XCTAssertEqual(ExportNaming.orderPrefix(for: 98), "99_")
        XCTAssertEqual(ExportNaming.orderPrefix(for: 99), "100_")
    }

    func testIndexedSlotBase_withSuffix() {
        let p = VFXPatch(name: "Lead One", category: "Lead", rawSysEx: Data([1]))
        let opts = ExportNaming.Options(
            maxBaseNameLength: 8,
            numericPrefix: false,
            categorySubfolders: false,
            flashFloppyIndexedMode: true,
            indexedPrefix: "DSKA"
        )
        XCTAssertEqual(ExportNaming.exportStem(patch: p, index: 0, options: opts), "DSKA0000_Lead One")
        XCTAssertEqual(ExportNaming.exportStem(patch: p, index: 42, options: opts), "DSKA0042_Lead One")
    }

    func testIndexedSlotBase_prefixNormalized() {
        XCTAssertEqual(ExportNaming.normalizedIndexedPrefix(""), "")
        XCTAssertEqual(ExportNaming.normalizedIndexedPrefix("ab"), "AB")
        XCTAssertEqual(ExportNaming.normalizedIndexedPrefix("toolongprefixxx"), "TOOLONG")
    }

    func testIndexedSlotBase_emptyPrefix_numericFilenames() {
        XCTAssertEqual(
            ExportNaming.indexedSlotBase(prefix: "", slotIndex: 0, nameSuffix: "Lead"),
            "0000_Lead"
        )
    }

    func testWritePatches_indexed_overwritesSameSlot() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("VFXIdx-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let raw = Data([0xF0, 0x0F, 0x05, 0xF7])
        let a = VFXPatch(name: "Same", category: "Lead", rawSysEx: raw)
        let opts = ExportNaming.Options(
            maxBaseNameLength: nil,
            numericPrefix: false,
            categorySubfolders: true,
            flashFloppyIndexedMode: true,
            indexedPrefix: "DSKA"
        )
        _ = ExportHelper.writePatches([a], to: dir, options: opts, manifest: nil)
        _ = ExportHelper.writePatches([a], to: dir, options: opts, manifest: nil)
        let files = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        let syx = files.filter { $0.pathExtension.lowercased() == "syx" }
        XCTAssertEqual(syx.count, 1)
        XCTAssertTrue(syx[0].lastPathComponent.hasPrefix("DSKA0000"))
    }

    func testUniqueSyxURL_avoidsCollision() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("VFXCtrlExportTest-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let u1 = ExportNaming.uniqueSyxURL(directory: dir, stem: "dup")
        try Data([0xF7]).write(to: u1)
        let u2 = ExportNaming.uniqueSyxURL(directory: dir, stem: "dup")
        XCTAssertNotEqual(u1.lastPathComponent, u2.lastPathComponent)
        XCTAssertTrue(u2.lastPathComponent.contains("dup_2"))
    }

    func testWritePatches_collisionSafeInSameFolder() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("VFXCtrlWriteTest-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let raw = Data([0xF0, 0x0F, 0x05, 0xF7])
        let a = VFXPatch(name: "Same", category: "Lead", rawSysEx: raw)
        let b = VFXPatch(name: "Same", category: "Lead", rawSysEx: raw)
        let opts = ExportNaming.Options(maxBaseNameLength: nil, numericPrefix: false, categorySubfolders: false)
        let count = ExportHelper.writePatches([a, b], to: dir, options: opts, manifest: nil)
        XCTAssertEqual(count, 2)
        let files = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        let syx = files.filter { $0.pathExtension.lowercased() == "syx" }
        XCTAssertEqual(syx.count, 2)
    }

    /// Stress-style check: many exports with numeric prefix stay unique on disk (Phase 7.7 automation).
    func testWritePatches_sixtyPatches_numericPrefix_noOverwrite() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("VFXCtrlBulk60-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let raw = Data([0xF0, 0x0F, 0x05, 0xF7])
        let patches = (0..<60).map { i in
            VFXPatch(name: "Bank Patch", category: "Pads", rawSysEx: raw, parameters: ["i": i])
        }
        let opts = ExportNaming.Options(maxBaseNameLength: 12, numericPrefix: true, categorySubfolders: false)
        let count = ExportHelper.writePatches(patches, to: dir, options: opts, manifest: nil)
        XCTAssertEqual(count, 60)
        let files = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        let syx = files.filter { $0.pathExtension.lowercased() == "syx" }
        XCTAssertEqual(syx.count, 60)
        let names = Set(syx.map(\.lastPathComponent))
        XCTAssertEqual(names.count, 60, "All 60 filenames must be unique")
    }

    func testWritePatches_bankJsonManifest() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("VFXCtrlBankJson-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let raw = Data([0xF0, 0x0F, 0x05, 0xF7])
        let p = VFXPatch(name: "One", category: "Pads", rawSysEx: raw)
        let opts = ExportNaming.Options(maxBaseNameLength: nil, numericPrefix: true, categorySubfolders: false)
        let manifest = BankManifestWriteOptions(liveSetName: "Test Set", truncatedToBankSize: true)
        let count = ExportHelper.writePatches([p], to: dir, options: opts, manifest: manifest)
        XCTAssertEqual(count, 1)

        let jsonURL = dir.appendingPathComponent("bank.json")
        XCTAssertTrue(FileManager.default.fileExists(atPath: jsonURL.path))
        let data = try Data(contentsOf: jsonURL)
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        let m = try dec.decode(BankExportManifest.self, from: data)
        XCTAssertEqual(m.format, BankExportManifest.currentFormat)
        XCTAssertEqual(m.liveSetName, "Test Set")
        XCTAssertTrue(m.truncatedToBankSize)
        XCTAssertEqual(m.maxProgramsPerBank, VFXBankLimits.programsPerInternalBank)
        XCTAssertEqual(m.slots.count, 1)
        XCTAssertEqual(m.slots[0].index, 1)
        XCTAssertTrue(m.slots[0].file.hasSuffix(".syx"))
    }
}
