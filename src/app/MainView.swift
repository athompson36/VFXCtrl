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
                Divider().background(VFXTheme.textSecondary.opacity(0.3))
                PageSelector(selectedPage: $editor.selectedPage)
                Divider().background(VFXTheme.textSecondary.opacity(0.3))
                currentPage
                Divider().background(VFXTheme.textSecondary.opacity(0.3))
                SysExConsole()
                    .frame(height: 220)
            }
            .background(VFXTheme.panelBackground)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("VFX-CTRL")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(VFXTheme.vfdGreen)
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu("Export") {
                        Button("Current Patch…") {
                            exportCurrentPatch(gotekShortName: false)
                        }
                        .disabled(editor.currentPatch.rawSysEx == nil)
                        Button("Current Patch (Gotek ≤16 chars)…") {
                            exportCurrentPatch(gotekShortName: true)
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
            .onAppear {
                editor.onLiveParameterChange = { key, value in
                    LiveDebugLog.log("MainView.onLiveParameterChange \(key)=\(value) START")
                    let channel = midi.midiChannel - 1
                    guard let msg = LiveSysExBuilder.buildMessage(key: key, value: value, channel: channel) else {
                        LiveDebugLog.log("MainView.onLiveParameterChange build=nil END")
                        return
                    }
                    switch msg {
                    case .sysex(let data):
                        let hex = data.map { String(format: "%02X", $0) }.joined(separator: " ")
                        LiveDebugLog.log("Live SysEx TX: \(hex)")
                        midi.sendSysEx(data, quiet: true)
                    case .cc(let ch, let cc, let val):
                        LiveDebugLog.log("Live CC TX: ch=\(ch+1) cc=\(cc) val=\(val)")
                        midi.sendCC(channel: ch, controller: cc, value: val, quiet: true)
                    case .virtualButton(let data):
                        let hex = data.map { String(format: "%02X", $0) }.joined(separator: " ")
                        LiveDebugLog.log("Live VBtn TX: \(hex)")
                        midi.sendSysEx(data, quiet: true)
                    }
                    LiveDebugLog.log("MainView.onLiveParameterChange done END")
                }
            }
        }
    }

    private func exportCurrentPatch(gotekShortName: Bool) {
        guard let data = editor.currentPatch.rawSysEx else { return }
        if gotekShortName {
            _ = ExportHelper.saveSysExGotek(data, patchName: editor.currentPatch.name, maxBaseNameLength: 16)
        } else {
            _ = ExportHelper.saveSysEx(data, defaultName: editor.currentPatch.name + ".syx")
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
        case .system: SystemPage()
        }
    }
}
