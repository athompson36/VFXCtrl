import XCTest
@testable import VFXCtrl

final class MacroEngineTests: XCTestCase {
    func testApplyBrightness_setsFilterParams() {
        var patch = VFXPatch(parameters: [:])
        let engine = MacroEngine()
        engine.apply("macro.brightness", value: 80, to: &patch)
        XCTAssertEqual(patch.parameters["filter.cutoff"], 80)
        XCTAssertEqual(patch.parameters["filter.resonance"], 20)
    }

    func testApplyAttack_setsAmpParams() {
        var patch = VFXPatch(parameters: [:])
        let engine = MacroEngine()
        engine.apply("macro.attack", value: 50, to: &patch)
        XCTAssertEqual(patch.parameters["amp.attack"], 50)
        XCTAssertEqual(patch.parameters["amp.decay"], 70)
    }

    func testApplyUnknownKey_noChange() {
        var patch = VFXPatch(parameters: ["x": 1])
        let engine = MacroEngine()
        engine.apply("unknown.macro", value: 100, to: &patch)
        XCTAssertEqual(patch.parameters["x"], 1)
        XCTAssertNil(patch.parameters["filter.cutoff"])
    }

    func testMacroKeys_hasEightItems() {
        XCTAssertEqual(MacroEngine.macroKeys.count, 8)
    }
}
