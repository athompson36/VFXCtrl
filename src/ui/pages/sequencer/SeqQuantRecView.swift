import SwiftUI

struct SeqQuantRecView: View {
    @EnvironmentObject private var editor: EditorState

    private static let quantizeOptions = ["Off", "1/4", "1/8", "1/16", "1/32", "1/4 Triplet", "1/8 Triplet"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Quantize & Record")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(VFXTheme.vfdGreen)

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("Quantize")
                    .foregroundStyle(VFXTheme.textPrimary)
                    .frame(width: 120, alignment: .leading)
                Picker("", selection: Binding(
                    get: { min(editor.controls["seq.quant", default: 0], Self.quantizeOptions.count - 1) },
                    set: { editor.set("seq.quant", value: $0) }
                )) {
                    ForEach(Array(Self.quantizeOptions.enumerated()), id: \.offset) { i, name in
                        Text(name).tag(i)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 140)
            }

            Toggle(isOn: Binding(
                get: { (editor.controls["seq.loop", default: 0]) != 0 },
                set: { editor.set("seq.loop", value: $0 ? 1 : 0) }
            )) {
                Text("Loop")
                    .foregroundStyle(VFXTheme.textPrimary)
            }
            .toggleStyle(.switch)
            .tint(VFXTheme.vfdGreen)

            Toggle(isOn: Binding(
                get: { (editor.controls["seq.click", default: 0]) != 0 },
                set: { editor.set("seq.click", value: $0 ? 1 : 0) }
            )) {
                Text("Click (metronome)")
                    .foregroundStyle(VFXTheme.textPrimary)
            }
            .toggleStyle(.switch)
            .tint(VFXTheme.vfdGreen)

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("Punch In (measure)")
                    .foregroundStyle(VFXTheme.textPrimary)
                    .frame(width: 160, alignment: .leading)
                TextField("0", value: Binding(
                    get: { editor.controls["seq.punchIn", default: 0] },
                    set: { editor.set("seq.punchIn", value: min(999, max(0, $0))) }
                ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
            }

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("Punch Out (measure)")
                    .foregroundStyle(VFXTheme.textPrimary)
                    .frame(width: 160, alignment: .leading)
                TextField("0", value: Binding(
                    get: { editor.controls["seq.punchOut", default: 0] },
                    set: { editor.set("seq.punchOut", value: min(999, max(0, $0))) }
                ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
