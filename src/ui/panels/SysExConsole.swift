import SwiftUI
import UniformTypeIdentifiers

struct SysExConsole: View {
    @EnvironmentObject private var midi: MIDIDeviceManager
    @State private var showSendFile = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("SysEx Log")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(VFXTheme.vfdGreen)
                Spacer()
                Button("Clear") { midi.clearLog() }
                    .buttonStyle(VFXButtonStyle())
                Button("Send file…") { showSendFile = true }
                    .buttonStyle(VFXButtonStyle())
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
                        .font(.system(size: 12))
                        .foregroundStyle(VFXTheme.textSecondary)
                    Slider(value: $midi.interMessageDelayMs, in: 10...200, step: 5)
                        .frame(width: 120)
                        .tint(VFXTheme.vfdGreen)
                    Button("Stop Sends") { midi.stopSends() }
                        .buttonStyle(VFXButtonStyle())
                }
            }
            .padding(.horizontal)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(midi.messageLog.suffix(200).reversed().enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(VFXTheme.vfdGreenDim)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(VFXTheme.panelBackground)
    }
}
