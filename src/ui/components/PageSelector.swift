import SwiftUI

struct PageSelector: View {
    @Binding var selectedPage: EditorPage

    var body: some View {
        HStack(spacing: 8) {
            ForEach(EditorPage.allCases, id: \.self) { page in
                Button(page.rawValue) { selectedPage = page }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(selectedPage == page ? VFXTheme.vfdGreen : VFXTheme.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(selectedPage == page ? VFXTheme.vfdGreen.opacity(0.2) : VFXTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding()
        .background(VFXTheme.panelBackground)
    }
}
