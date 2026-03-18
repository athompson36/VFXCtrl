import SwiftUI

struct ModMatrixView: View {
    @EnvironmentObject private var editor: EditorState

    private let depthRange = 0...127
    private let cellWidth: CGFloat = 68
    private let sourceColumnWidth: CGFloat = 88
    private let rowHeight: CGFloat = 28

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            globalAmounts
            matrixHeader
            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                matrixGrid
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(VFXTheme.surface)
    }

    private var globalAmounts: some View {
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
                    .foregroundStyle(VFXTheme.textSecondary)
                    .frame(width: 28, alignment: .trailing)
                    .font(.system(.caption, design: .monospaced))
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
                    .foregroundStyle(VFXTheme.textSecondary)
                    .frame(width: 28, alignment: .trailing)
                    .font(.system(.caption, design: .monospaced))
            }
        }
        .padding(.bottom, 12)
    }

    private var matrixHeader: some View {
        HStack(spacing: 0) {
            Color.clear
                .frame(width: sourceColumnWidth, height: rowHeight)
            ForEach(ModMatrixModel.destinations, id: \.index) { dest in
                Text(dest.name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(VFXTheme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: cellWidth, height: rowHeight)
            }
        }
        .padding(.vertical, 4)
    }

    private var matrixGrid: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(ModMatrixModel.sources, id: \.index) { src in
                HStack(spacing: 0) {
                    Text(src.name)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(VFXTheme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(width: sourceColumnWidth, height: rowHeight, alignment: .leading)
                    ForEach(ModMatrixModel.destinations, id: \.index) { dest in
                        matrixCell(sourceIndex: src.index, destIndex: dest.index)
                    }
                }
            }
        }
    }

    private func matrixCell(sourceIndex: Int, destIndex: Int) -> some View {
        let key = ModMatrixModel.matrixKey(sourceIndex: sourceIndex, destIndex: destIndex)
        let value = editor.controls[key, default: 0]
        return HStack(spacing: 2) {
            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { editor.set(key, value: Int($0.rounded())) }
                ),
                in: 0...127
            )
            .tint(VFXTheme.vfdGreen)
            Text("\(value)")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(value > 0 ? VFXTheme.vfdGreen : VFXTheme.textSecondary)
                .frame(width: 20, alignment: .trailing)
        }
        .frame(width: cellWidth, height: rowHeight)
    }
}
