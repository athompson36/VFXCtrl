import SwiftUI

struct TransportBar: View {
    @EnvironmentObject private var editor: EditorState
    @EnvironmentObject private var midi: MIDIDeviceManager

    var body: some View {
        HStack(spacing: 12) {
            Menu {
                Button("Refresh") { midi.refreshDevices() }
                ForEach(midi.availableInputs, id: \.id) { item in
                    Button(item.name) { midi.selectInput(item.id) }
                }
            } label: {
                Text("IN: \(midi.inputName)")
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: 140, alignment: .leading)

            Menu {
                ForEach(midi.availableOutputs, id: \.id) { item in
                    Button(item.name) { midi.selectOutput(item.id) }
                }
            } label: {
                Text("OUT: \(midi.outputName)")
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: 140, alignment: .leading)

            Text("Ch \(midi.midiChannel)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
            Button("Request Patch") { requestPatch() }
            Button("Send") { sendCurrentPatch() }
            Button("Compare") {
                editor.comparePatch = editor.currentPatch
            }
            Divider().frame(height: 20)
            Button("Play") {}
            Button("Stop") {}
            Button("Record") {}
            Button("Tap") {}
        }
        .padding()
    }

    private func requestPatch() {
        // VFX-SD "send current program" request format TBD; placeholder.
        // When verified, send the request SysEx here.
    }

    private func sendCurrentPatch() {
        guard let data = editor.currentPatch.rawSysEx else { return }
        midi.sendSysEx(data)
    }
}
