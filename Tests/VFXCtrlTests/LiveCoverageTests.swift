import XCTest
@testable import VFXCtrl

/// Ensures every key that can be sent live is declared in `ParameterMap` (or is an intentional virtual action).
final class LiveCoverageTests: XCTestCase {

    func test_supportedLiveKeys_existInParameterMap_orAreVirtualActions() {
        let mapKeys = Set(ParameterCatalog.allMappedKeys)
        let virtual = Set(["seq.play", "seq.stop", "seq.record"])
        for key in LiveSysExBuilder.supportedLiveKeys {
            if virtual.contains(key) { continue }
            XCTAssertTrue(
                mapKeys.contains(key),
                "Live key \"\(key)\" is missing from ParameterMap — add it or remove from LiveSysExBuilder."
            )
        }
    }
}
