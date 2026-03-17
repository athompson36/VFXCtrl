import SwiftUI

struct WavePage: View {
    @EnvironmentObject private var editor: EditorState

    var body: some View { PageGrid(keys: ["wave.select", "wave.coarse", "wave.fine", "wave.octave", "wave.level", "wave.velocity", "wave.keytrack", "wave.pan"]) }
}
