import SwiftUI

/// Mod page: 2 routing slots only (VFX-SD hardware limit). Uses canonical keys mod.src1/dest1/depth1, mod.src2/dest2/depth2, mod.pedal, mod.pressure.
struct ModTwoSlotView: View {
    @EnvironmentObject private var editor: EditorState

    private let depthRange = 0...127
    private let sourceRange = 0..<ModMatrixModel.sources.count
    private let destRange = 0..<ModMatrixModel.destinations.count

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Modulation (2 routes)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(VFXTheme.vfdGreen)

            slotRow(slot: 1, srcKey: "mod.src1", destKey: "mod.dest1", depthKey: "mod.depth1")
            slotRow(slot: 2, srcKey: "mod.src2", destKey: "mod.dest2", depthKey: "mod.depth2")

            Divider()
                .background(VFXTheme.textSecondary)

            HStack(spacing: 24) {
                HStack(spacing: 8) {
                    Text("Pedal")
                        .foregroundStyle(VFXTheme.textPrimary)
                        .frame(width: 44, alignment: .leading)
                    Slider(
                        value: Binding(
                            get: { Double(editor.controls["mod.pedal", default: 0]) },
                            set: { editor.set("mod.pedal", value: Int($0.rounded())) }
                        ),
                        in: 0...127
                    )
                    .tint(VFXTheme.vfdGreen)
                    .frame(width: 120)
                    Text("\(editor.controls["mod.pedal", default: 0])")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(VFXTheme.textSecondary)
                        .frame(width: 28, alignment: .trailing)
                }
                HStack(spacing: 8) {
                    Text("Pressure")
                        .foregroundStyle(VFXTheme.textPrimary)
                        .frame(width: 56, alignment: .leading)
                    Slider(
                        value: Binding(
                            get: { Double(editor.controls["mod.pressure", default: 0]) },
                            set: { editor.set("mod.pressure", value: Int($0.rounded())) }
                        ),
                        in: 0...127
                    )
                    .tint(VFXTheme.vfdGreen)
                    .frame(width: 120)
                    Text("\(editor.controls["mod.pressure", default: 0])")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(VFXTheme.textSecondary)
                        .frame(width: 28, alignment: .trailing)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(VFXTheme.surface)
    }

    private func slotRow(slot: Int, srcKey: String, destKey: String, depthKey: String) -> some View {
        let srcIndex = min(max(editor.controls[srcKey, default: 0], 0), sourceRange.upperBound - 1)
        let destIndex = min(max(editor.controls[destKey, default: 0], 0), destRange.upperBound - 1)
        return HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text("Slot \(slot)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(VFXTheme.textSecondary)
                .frame(width: 44, alignment: .leading)
            Picker("Source", selection: Binding(
                get: { srcIndex },
                set: { editor.set(srcKey, value: $0) }
            )) {
                ForEach(ModMatrixModel.sources, id: \.index) { s in
                    Text(s.name).tag(s.index)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 120)
            Picker("Dest", selection: Binding(
                get: { destIndex },
                set: { editor.set(destKey, value: $0) }
            )) {
                ForEach(ModMatrixModel.destinations, id: \.index) { d in
                    Text(d.name).tag(d.index)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 120)
            Text("Depth")
                .foregroundStyle(VFXTheme.textPrimary)
                .frame(width: 36, alignment: .leading)
            Slider(
                value: Binding(
                    get: { Double(editor.controls[depthKey, default: 0]) },
                    set: { editor.set(depthKey, value: Int($0.rounded())) }
                ),
                in: 0...127
            )
            .tint(VFXTheme.vfdGreen)
            .frame(width: 140)
            Text("\(editor.controls[depthKey, default: 0])")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(VFXTheme.textSecondary)
                .frame(width: 24, alignment: .trailing)
        }
    }
}
