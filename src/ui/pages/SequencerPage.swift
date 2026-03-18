import SwiftUI

struct SequencerPage: View {
    @State private var selectedSubPage: SequencerSubPage = .transport

    var body: some View {
        VStack(spacing: 0) {
            Picker("Seq section", selection: $selectedSubPage) {
                ForEach(SequencerSubPage.allCases, id: \.self) { page in
                    Text(page.rawValue).tag(page)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(VFXTheme.panelBackground)

            Group {
                switch selectedSubPage {
                case .transport: SeqTransportView()
                case .tempoClock: SeqTempoClockView()
                case .songTrack: SeqSongTrackView()
                case .quantRec: SeqQuantRecView()
                case .dumpLoad: SeqDumpLoadView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(VFXTheme.surface)
        }
    }
}
