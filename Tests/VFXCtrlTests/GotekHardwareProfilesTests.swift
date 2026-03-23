import XCTest
@testable import VFXCtrl

final class GotekHardwareProfilesTests: XCTestCase {
    func testMergeHostProfileFillsMissingKeys() {
        let profile = EnsoniqHostProfile.profile(id: "asr_ts_mr61")!
        let merged = GotekEnsoniqSetupMerge.mergeHostProfile(
            into: ["nav-mode": "indexed"],
            profile: profile,
            replace: false
        )
        XCTAssertEqual(merged["nav-mode"], "indexed")
        XCTAssertEqual(merged["interface"], "ibmpc-hdout")
        XCTAssertEqual(merged["host"], "ensoniq")
    }

    func testMergeHostProfileEPSAddsChgrst() {
        let profile = EnsoniqHostProfile.profile(id: "eps")!
        let merged = GotekEnsoniqSetupMerge.mergeHostProfile(into: [:], profile: profile, replace: true)
        XCTAssertEqual(merged["chgrst"], "delay-3")
        XCTAssertEqual(merged["interface"], "shugart")
    }

    func testMergeHostProfileDoesNotOverwriteWhenReplaceFalse() {
        let profile = EnsoniqHostProfile.profile(id: "vfx_sd_sd1")!
        let merged = GotekEnsoniqSetupMerge.mergeHostProfile(
            into: ["interface": "ibmpc-hdout"],
            profile: profile,
            replace: false
        )
        XCTAssertEqual(merged["interface"], "ibmpc-hdout")
    }

    func testMergeHostProfileReplaceRemovesStaleChgrst() {
        let profile = EnsoniqHostProfile.profile(id: "vfx_sd_sd1")!
        let merged = GotekEnsoniqSetupMerge.mergeHostProfile(
            into: ["chgrst": "delay-3", "host": "ensoniq"],
            profile: profile,
            replace: true
        )
        XCTAssertNil(merged["chgrst"])
        XCTAssertEqual(merged["interface"], "shugart")
    }
}
