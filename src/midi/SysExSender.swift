import Foundation

struct SysExSender {
    var delayMs: UInt64 = 40

    mutating func pacedSend(messages: [Data], send: (Data) -> Void) async {
        for msg in messages {
            send(msg)
            try? await Task.sleep(nanoseconds: delayMs * 1_000_000)
        }
    }
}
