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
                    .foregroundStyle(VFXTheme.textPrimary)
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
                    .foregroundStyle(VFXTheme.textPrimary)
            }
            .frame(maxWidth: 140, alignment: .leading)

            Text("Ch")
                .foregroundStyle(VFXTheme.textSecondary)
            Picker("MIDI Channel", selection: $midi.midiChannel) {
                ForEach(1...16, id: \.self) { ch in
                    Text("\(ch)").tag(ch)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 44)
            .labelsHidden()

            Spacer()
            if midi.patchRequestPhase == .waitingForDump {
                Text("Waiting for dump…")
                    .font(.caption2)
                    .foregroundStyle(VFXTheme.vfdGreenDim)
            }
            if let notice = midi.transportUserNotice {
                Text(notice)
                    .font(.caption2)
                    .foregroundStyle(.orange)
                    .lineLimit(2)
                    .frame(maxWidth: 280, alignment: .trailing)
            }
            Button("Request Patch") { requestPatch() }
                .buttonStyle(VFXButtonStyle())
            Button("Send") { sendCurrentPatch() }
                .buttonStyle(VFXButtonStyle())
            Button("Compare") {
                editor.comparePatch = editor.currentPatch
            }
            .buttonStyle(VFXButtonStyle())
            Divider().frame(height: 20).background(VFXTheme.textSecondary)
            Button("Play") { midi.sequencerPlay() }
                .buttonStyle(VFXButtonStyle())
            Button("Stop") { midi.sequencerStop() }
                .buttonStyle(VFXButtonStyle())
            Button("Record") { midi.sequencerRecord() }
                .buttonStyle(VFXButtonStyle())
            Button("Tap") { midi.sequencerTap() }
                .buttonStyle(VFXButtonStyle())
        }
        .padding()
        .background(VFXTheme.panelBackground)
    }

    private func requestPatch() {
        midi.requestCurrentProgram()
    }

    private func sendCurrentPatch() {
        guard midi.selectedOutputRef != 0 else {
            midi.transportUserNotice = "Select a MIDI output before sending."
            return
        }
        do {
            let data = try PatchSerializer().serialize(editor.currentPatch)
            midi.sendSysEx(data)
        } catch {
            midi.transportUserNotice = "Nothing to send: patch has no program SysEx (request from synth or import a .syx first)."
        }
    }
}

/// Panel-style button: dark with VFD green when prominent.
struct VFXButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(VFXTheme.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(configuration.isPressed ? VFXTheme.vfdGreenDim.opacity(0.4) : VFXTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
