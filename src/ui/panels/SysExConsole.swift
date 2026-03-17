import SwiftUI
import UniformTypeIdentifiers

struct SysExConsole: View {
    @EnvironmentObject private var midi: MIDIDeviceManager
    @State private var showSendFile = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("SysEx Log")
                Spacer()
                Button("Send file…") { showSendFile = true }
                    .fileImporter(
                        isPresented: $showSendFile,
                        allowedContentTypes: [.data],
                        allowsMultipleSelection: false
                    ) { result in
                        guard case .success(let urls) = result, let url = urls.first,
                              url.startAccessingSecurityScopedResource(),
                              let data = try? Data(contentsOf: url) else { return }
                        defer { url.stopAccessingSecurityScopedResource() }
                        midi.sendSysEx(data)
                    }
                HStack(spacing: 12) {
                    Text("Delay \(Int(midi.interMessageDelayMs)) ms")
                        .font(.caption)
                    Slider(value: $midi.interMessageDelayMs, in: 10...200, step: 5)
                        .frame(width: 120)
                    Button("Stop Sends") {
                        midi.stopSends()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)

            List(midi.messageLog.reversed(), id: \.self) { line in
                Text(line)
                    .font(.system(.caption, design: .monospaced))
            }
        }
    }
}
