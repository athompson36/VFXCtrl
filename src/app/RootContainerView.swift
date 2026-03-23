import SwiftUI

struct RootContainerView: View {
    @State private var workspace: AppWorkspace = .synth

    var body: some View {
        VStack(spacing: 0) {
            Picker("Workspace", selection: $workspace) {
                ForEach(AppWorkspace.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(VFXTheme.panelBackground)

            Group {
                switch workspace {
                case .synth:
                    MainView()
                case .floppy:
                    FloppyEmulatorView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(VFXTheme.panelBackground)
    }
}
