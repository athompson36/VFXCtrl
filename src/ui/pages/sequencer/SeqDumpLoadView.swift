import SwiftUI

struct SeqDumpLoadView: View {
    @EnvironmentObject private var midi: MIDIDeviceManager
    @EnvironmentObject private var editor: EditorState

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Dump / Load")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(VFXTheme.vfdGreen)

            Text("Request or send sequencer data via SysEx. Buttons are active once request/response formats are verified.")
                .font(.caption)
                .foregroundStyle(VFXTheme.textSecondary)

            HStack(spacing: 12) {
                Button("Request track dump") { }
                    .buttonStyle(VFXButtonStyle())
                    .disabled(true)
                Button("Request song dump") { }
                    .buttonStyle(VFXButtonStyle())
                    .disabled(true)
            }

            HStack(spacing: 12) {
                Button("Send track to synth") { }
                    .buttonStyle(VFXButtonStyle())
                    .disabled(true)
                Button("Send song to synth") { }
                    .buttonStyle(VFXButtonStyle())
                    .disabled(true)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
