import SwiftUI

/// Renders all `ParameterDefinition` rows for one editor tab, grouped by VFX-SD hardware page.
struct ParameterDefinitionsPage: View {
    @EnvironmentObject private var editor: EditorState

    let page: EditorPage
    /// Keys already shown elsewhere (e.g. System page custom pickers).
    var excludeKeys: Set<String> = []
    /// When `false`, only the inner stack is returned (for nesting inside another `ScrollView`).
    var scrolls: Bool = true

    private var definitions: [ParameterDefinition] {
        ParameterCatalog.definitions(for: page).filter { !excludeKeys.contains($0.key) }
    }

    private var grouped: [(section: String, items: [ParameterDefinition])] {
        let byPage = Dictionary(grouping: definitions, by: { $0.sysexPage })
        let sortedPages = byPage.keys.sorted()
        return sortedPages.map { p in
            (ParameterCatalog.sectionTitle(sysexPage: p), byPage[p]!.sorted {
                if $0.sysexSlot != $1.sysexSlot { return $0.sysexSlot < $1.sysexSlot }
                return $0.key < $1.key
            })
        }
    }

    @ViewBuilder
    var body: some View {
        let content = LazyVStack(alignment: .leading, spacing: 22) {
            if definitions.isEmpty {
                Text("No parameters for this tab.")
                    .foregroundStyle(VFXTheme.textSecondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(grouped, id: \.section) { group in
                    sectionBlock(title: group.section, items: group.items)
                }
            }
        }

        if scrolls {
            ScrollView {
                content
                    .padding(24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(VFXTheme.surface)
        } else {
            content
        }
    }

    private func sectionBlock(title: String, items: [ParameterDefinition]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(VFXTheme.vfdGreen)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 4), spacing: 20) {
                ForEach(items, id: \.key) { def in
                    VirtualEncoder(
                        label: def.shortLabel,
                        value: Binding(
                            get: { editor.controls[def.key, default: 0] },
                            set: { editor.set(def.key, value: $0) }
                        ),
                        range: def.minValue...def.maxValue
                    )
                    .help(def.label + (def.note.isEmpty ? "" : " — \(def.note)"))
                }
            }
        }
    }
}
