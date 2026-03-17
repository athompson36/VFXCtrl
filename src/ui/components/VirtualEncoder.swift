import SwiftUI

struct VirtualEncoder: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().strokeBorder(.secondary, lineWidth: 2)
                Text("\(value)")
                    .font(.caption.monospacedDigit())
            }
            .frame(width: 72, height: 72)
            Stepper(label, value: $value, in: range)
                .labelsHidden()
            Text(label)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
    }
}
