import SwiftUI

struct PageGrid: View {
    @EnvironmentObject private var editor: EditorState
    let keys: [String]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 24) {
            ForEach(keys, id: \.self) { key in
                VirtualEncoder(
                    label: key.components(separatedBy: ".").last?.capitalized ?? key,
                    value: Binding(
                        get: { editor.controls[key, default: 0] },
                        set: { editor.set(key, value: $0) }
                    ),
                    range: 0...127
                )
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VFXTheme.surface)
    }
}
