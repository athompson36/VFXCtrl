import XCTest
@testable import VFXCtrl

final class ParameterEnumLabelsTests: XCTestCase {

    func testEnumLabelSpanMatchesParameterMap() {
        for def in initialParameterMap {
            guard let labels = ParameterEnumLabels.labels(
                forKey: def.key,
                minValue: def.minValue,
                maxValue: def.maxValue
            ) else { continue }

            let span = def.maxValue - def.minValue + 1
            XCTAssertEqual(
                labels.count,
                span,
                "Key \(def.key): label count \(labels.count) != span \(span)"
            )
        }
    }

    func testKnownKeysHaveLabels() {
        XCTAssertNotNil(ParameterEnumLabels.labels(forKey: "sys.midiInMode", minValue: 0, maxValue: 4))
        XCTAssertNotNil(ParameterEnumLabels.labels(forKey: "fx.type", minValue: 0, maxValue: 21))
        XCTAssertNotNil(ParameterEnumLabels.labels(forKey: "filter2.type", minValue: 0, maxValue: 3))
        XCTAssertNil(ParameterEnumLabels.labels(forKey: "filter.cutoff", minValue: 0, maxValue: 127))
    }
}
