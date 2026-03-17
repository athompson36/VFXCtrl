import SwiftUI

struct MacroKnob: View {
    let label: String
    @Binding var value: Int

    var body: some View {
        VirtualEncoder(label: label, value: $value, range: 0...127)
    }
}
