import CryptoKit
import Foundation

/// SHA256 over raw SysEx bytes for librarian duplicate detection (Gotek / import workflow).
enum SysExDigest {
    static func sha256Hex(of data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
