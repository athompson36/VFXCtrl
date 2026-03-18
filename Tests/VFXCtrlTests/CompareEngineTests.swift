import XCTest
@testable import VFXCtrl

final class CompareEngineTests: XCTestCase {
    func testChangedKeys_emptyWhenIdentical() {
        let p = VFXPatch(parameters: ["a": 1, "b": 2])
        let engine = CompareEngine()
        XCTAssertEqual(engine.changedKeys(current: p, compare: p), [])
    }

    func testChangedKeys_returnsDifferentKeys() {
        let a = VFXPatch(parameters: ["a": 1, "b": 2, "c": 3])
        let b = VFXPatch(parameters: ["a": 1, "b": 99, "c": 3])
        let engine = CompareEngine()
        XCTAssertEqual(engine.changedKeys(current: a, compare: b), ["b"])
    }

    func testChangedKeys_returnsSorted() {
        let a = VFXPatch(parameters: ["z": 1, "a": 2])
        let b = VFXPatch(parameters: ["z": 9, "a": 9])
        let engine = CompareEngine()
        XCTAssertEqual(engine.changedKeys(current: a, compare: b), ["a", "z"])
    }

    func testChangedKeys_includesKeyOnlyInCurrent() {
        let a = VFXPatch(parameters: ["a": 1, "b": 2])
        let b = VFXPatch(parameters: ["a": 1])
        let engine = CompareEngine()
        XCTAssertEqual(engine.changedKeys(current: a, compare: b), ["b"])
    }
}
