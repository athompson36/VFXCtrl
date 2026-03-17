import SwiftUI

struct LibrarySidebar: View {
    var body: some View {
        List {
            Section("Library") {
                Label("All Patches", systemImage: "music.note.list")
                Label("Favorites", systemImage: "star")
                Label("Live Sets", systemImage: "bolt")
                Label("Incoming Captures", systemImage: "tray.and.arrow.down")
            }
        }
        .navigationTitle("Library")
    }
}
