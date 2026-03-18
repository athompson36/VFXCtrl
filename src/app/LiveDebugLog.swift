import Foundation

/// Verbose logging for isolating live volume / pinwheel issues.
/// Enable via UserDefaults: `defaults write <bundle-id> VFXCtrl.verboseLiveDebug -bool true`
/// Or turn on "Debug: Live logging" in System page (when present).
enum LiveDebugLog {
    static let defaultsKey = "VFXCtrl.verboseLiveDebug"

    static var enabled: Bool {
        get { UserDefaults.standard.bool(forKey: defaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: defaultsKey) }
    }

    private static let baseTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    private static let lock = NSLock()

    static func log(_ message: String) {
        guard enabled else { return }
        lock.lock()
        defer { lock.unlock() }
        let t = String(format: "%.4f", CFAbsoluteTimeGetCurrent() - baseTime)
        let thread = Thread.isMainThread ? "main" : (Thread.current.name ?? "\(Thread.current)")
        print("[LiveDebug] \(t)s \(thread) \(message)")
    }

    static func log(_ label: String, start: Bool) {
        log("\(label) \(start ? "START" : "END")")
    }
}
