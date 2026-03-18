import SwiftUI

struct SeqSongTrackView: View {
    @EnvironmentObject private var editor: EditorState

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Song & Track")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(VFXTheme.vfdGreen)

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("Song")
                    .foregroundStyle(VFXTheme.textPrimary)
                    .frame(width: 120, alignment: .leading)
                Picker("", selection: Binding(
                    get: { editor.controls["seq.song", default: 1] },
                    set: { editor.set("seq.song", value: $0) }
                )) {
                    ForEach(1...60, id: \.self) { n in
                        Text("\(n)").tag(n)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 80)
            }

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("Sequence")
                    .foregroundStyle(VFXTheme.textPrimary)
                    .frame(width: 120, alignment: .leading)
                Picker("", selection: Binding(
                    get: { editor.controls["seq.sequence", default: 1] },
                    set: { editor.set("seq.sequence", value: $0) }
                )) {
                    ForEach(1...60, id: \.self) { n in
                        Text("\(n)").tag(n)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 80)
            }

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("Track")
                    .foregroundStyle(VFXTheme.textPrimary)
                    .frame(width: 120, alignment: .leading)
                Picker("", selection: Binding(
                    get: { editor.controls["seq.track", default: 1] },
                    set: { editor.set("seq.track", value: $0) }
                )) {
                    ForEach(1...24, id: \.self) { n in
                        Text("\(n)").tag(n)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 80)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
