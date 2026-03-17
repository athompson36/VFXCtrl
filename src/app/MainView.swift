import SwiftUI

struct MainView: View {
    @EnvironmentObject private var editor: EditorState
    @EnvironmentObject private var midi: MIDIDeviceManager
    @EnvironmentObject private var library: LibraryDB
    @State private var showExportSetSheet = false

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
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu("Export") {
                        Button("Current Patch") {
                            exportCurrentPatch()
                        }
                        .disabled(editor.currentPatch.rawSysEx == nil)
                        Button("Live Set…") {
                            showExportSetSheet = true
                        }
                        .disabled(library.liveSets.isEmpty)
                    }
                }
            }
            .sheet(isPresented: $showExportSetSheet) {
                ExportLiveSetSheet(library: library) {
                    showExportSetSheet = false
                }
            }
        }
    }

    private func exportCurrentPatch() {
        guard let data = editor.currentPatch.rawSysEx else { return }
        _ = ExportHelper.saveSysEx(data, defaultName: editor.currentPatch.name + ".syx")
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
