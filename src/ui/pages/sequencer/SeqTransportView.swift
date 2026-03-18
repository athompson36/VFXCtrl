import SwiftUI

struct SeqTransportView: View {
    @EnvironmentObject private var midi: MIDIDeviceManager
    @EnvironmentObject private var editor: EditorState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Transport")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(VFXTheme.vfdGreen)
            HStack(spacing: 12) {
                Button("Play") { midi.sequencerPlay() }
                    .buttonStyle(VFXButtonStyle())
                Button("Stop") { midi.sequencerStop() }
                    .buttonStyle(VFXButtonStyle())
                Button("Record") { midi.sequencerRecord() }
                    .buttonStyle(VFXButtonStyle())
                Button("Continue") { midi.sequencerTap() }
                    .buttonStyle(VFXButtonStyle())
            }
            Text("Transport commands sent when VFX-SD sequencer SysEx is verified.")
                .font(.caption)
                .foregroundStyle(VFXTheme.textSecondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
