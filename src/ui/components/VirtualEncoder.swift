import SwiftUI

struct VirtualEncoder: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    /// Doubled from typical caption (~12pt) for readability.
    private static let valueFontSize: CGFloat = 24
    private static let labelFontSize: CGFloat = 20

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .strokeBorder(VFXTheme.knobRing, lineWidth: 2)
                Circle()
                    .strokeBorder(VFXTheme.knobRingHighlight.opacity(0.6), lineWidth: 1)
                    .padding(2)
                Text("\(value)")
                    .font(.system(size: Self.valueFontSize, weight: .medium, design: .monospaced))
                    .foregroundStyle(VFXTheme.vfdGreen)
            }
            .frame(width: 72, height: 72)
            Stepper(label, value: $value, in: range)
                .labelsHidden()
            Text(label)
                .font(.system(size: Self.labelFontSize, weight: .medium))
                .foregroundStyle(VFXTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue("\(value)")
        .accessibilityHint("Adjustable from \(range.lowerBound) to \(range.upperBound)")
    }
}
