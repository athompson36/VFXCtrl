import SwiftUI

struct SeqDumpLoadView: View {
    @EnvironmentObject private var midi: MIDIDeviceManager
    @EnvironmentObject private var editor: EditorState

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Dump / Load")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(VFXTheme.vfdGreen)

            Text("Sequencer bulk SysEx is unimplemented until request/dump formats are verified on hardware. See docs/PHASE5_SEQUENCER_FX.md (TODO 5.1).")
                .font(.caption)
                .foregroundStyle(VFXTheme.textSecondary)

            HStack(spacing: 12) {
                Button("Request track dump") {
                    midi.transportUserNotice = "Sequencer track dump: not implemented — verify SysEx request bytes (Phase 5.1)."
                }
                .buttonStyle(VFXButtonStyle())
                Button("Request song dump") {
                    midi.transportUserNotice = "Sequencer song dump: not implemented — verify SysEx request bytes (Phase 5.1)."
                }
                .buttonStyle(VFXButtonStyle())
            }

            HStack(spacing: 12) {
                Button("Send track to synth") {
                    midi.transportUserNotice = "Send sequencer track: not implemented — verify message format (Phase 5.1)."
                }
                .buttonStyle(VFXButtonStyle())
                Button("Send song to synth") {
                    midi.transportUserNotice = "Send sequencer song: not implemented — verify message format (Phase 5.1)."
                }
                .buttonStyle(VFXButtonStyle())
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
