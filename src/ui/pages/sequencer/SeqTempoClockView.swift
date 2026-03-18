import SwiftUI

struct SeqTempoClockView: View {
    @EnvironmentObject private var editor: EditorState
    @State private var tempoText: String = "120"

    private var tempoValue: Int {
        Int(tempoText) ?? 120
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Tempo & Clock")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(VFXTheme.vfdGreen)

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("Tempo (BPM)")
                    .foregroundStyle(VFXTheme.textPrimary)
                    .frame(width: 120, alignment: .leading)
                TextField("120", text: $tempoText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                    .onChange(of: tempoText) { _, new in
                        let v = min(300, max(1, Int(new) ?? 120))
                        editor.set("seq.tempo", value: v)
                        if String(v) != new { tempoText = String(v) }
                    }
                    .onAppear {
                        let v = editor.controls["seq.tempo", default: 120]
                        tempoText = String(min(300, max(1, v)))
                    }
            }

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("Clock source")
                    .foregroundStyle(VFXTheme.textPrimary)
                    .frame(width: 120, alignment: .leading)
                Picker("", selection: Binding(
                    get: { editor.controls["seq.clockSource", default: 0] },
                    set: { editor.set("seq.clockSource", value: $0) }
                )) {
                    Text("Internal").tag(0)
                    Text("MIDI Clock").tag(1)
                }
                .pickerStyle(.menu)
                .frame(width: 140)
            }

            Button("Tap Tempo") {
                editor.set("seq.tap", value: 1)
            }
            .buttonStyle(VFXButtonStyle())
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
