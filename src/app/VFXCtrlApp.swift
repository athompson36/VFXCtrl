import SwiftUI

@main
struct VFXCtrlApp: App {
    @StateObject private var editorState = EditorState()
    @StateObject private var midi = MIDIDeviceManager()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(editorState)
                .environmentObject(midi)
        }
        .defaultSize(width: 1440, height: 900)
    }
}
