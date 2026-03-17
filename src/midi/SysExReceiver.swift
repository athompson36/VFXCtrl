import Foundation

final class SysExReceiver {
    var onReceive: ((Data) -> Void)?

    func handlePacket(_ data: Data) {
        onReceive?(data)
    }
}
