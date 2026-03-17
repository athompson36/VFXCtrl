import SwiftUI

struct MainView: View {
    @EnvironmentObject private var editor: EditorState
    @EnvironmentObject private var midi: MIDIDeviceManager

    var body: some View {
        NavigationSplitView {
            LibrarySidebar()
        } content: {
            PatchListView()
        } detail: {
            VStack(spacing: 0) {
                TransportBar()
                Divider()
                PageSelector(selectedPage: $editor.selectedPage)
                Divider()
                currentPage
                Divider()
                SysExConsole()
                    .frame(height: 220)
            }
        }
    }

    @ViewBuilder
    private var currentPage: some View {
        switch editor.selectedPage {
        case .wave: WavePage()
        case .motion: MotionPage()
        case .filter: FilterPage()
        case .amp: AmpPage()
        case .mod: ModPage()
        case .performance: PerfPage()
        case .sequencer: SequencerPage()
        case .fx: FXPage()
        case .macro: MacroPage()
        }
    }
}
