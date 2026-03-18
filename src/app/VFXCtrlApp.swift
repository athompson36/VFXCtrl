import SwiftUI

@main
struct VFXCtrlApp: App {
    @StateObject private var editorState = EditorState()
    @StateObject private var midi = MIDIDeviceManager()
    @StateObject private var library = LibraryDB()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(editorState)
                .environmentObject(midi)
                .environmentObject(library)
                .onAppear(perform: wireReceiveSysEx)
                .preferredColorScheme(.dark)
        }
        .defaultSize(width: 1440, height: 900)
    }

    private func wireReceiveSysEx() {
        midi.onReceiveSysEx = { [weak editorState] data in
            guard PatchParser.isLikelyProgramDump(data),
                  let patch = try? PatchParser().parseProgramDump(data) else { return }
            DispatchQueue.main.async {
                editorState?.loadPatch(patch)
            }
        }
    }
}
