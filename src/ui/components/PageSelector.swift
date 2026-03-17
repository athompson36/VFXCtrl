import SwiftUI

struct PageSelector: View {
    @Binding var selectedPage: EditorPage

    var body: some View {
        HStack {
            ForEach(EditorPage.allCases, id: \.self) { page in
                Button(page.rawValue) { selectedPage = page }
                    .buttonStyle(.borderedProminent)
                    .tint(selectedPage == page ? .accentColor : .gray)
            }
        }
        .padding()
    }
}
