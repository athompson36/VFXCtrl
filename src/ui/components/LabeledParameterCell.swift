import SwiftUI

/// One parameter cell: **menu picker** with human-readable names when `ParameterEnumLabels` defines them;
/// otherwise **`VirtualEncoder`** for continuous values.
struct LabeledParameterCell: View {
    @EnvironmentObject private var editor: EditorState

    let definition: ParameterDefinition

    private var clampedBinding: Binding<Int> {
        Binding(
            get: {
                let v = editor.controls[definition.key, default: definition.minValue]
                return min(definition.maxValue, max(definition.minValue, v))
            },
            set: { editor.set(definition.key, value: $0) }
        )
    }

    var body: some View {
        if let labels = ParameterEnumLabels.labels(
            forKey: definition.key,
            minValue: definition.minValue,
            maxValue: definition.maxValue
        ) {
            enumPicker(labels: labels)
        } else {
            VirtualEncoder(
                label: definition.shortLabel,
                value: clampedBinding,
                range: definition.minValue...definition.maxValue
            )
        }
    }

    private func enumPicker(labels: [String]) -> some View {
        VStack(spacing: 10) {
            // Single VFD-green line: parameter identity. Current option appears only in the menu control
            // (no duplicate green value line or third short-label row).
            Text(definition.label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(VFXTheme.vfdGreen)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
                .frame(minHeight: 36)
                .frame(maxWidth: .infinity)
            Picker(definition.shortLabel, selection: clampedBinding) {
                ForEach(definition.minValue...definition.maxValue, id: \.self) { raw in
                    Text(labels[raw - definition.minValue]).tag(raw)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .help(definition.label + (definition.note.isEmpty ? "" : " — \(definition.note)"))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(definition.label)
        .accessibilityValue(currentLabel(labels: labels))
    }

    private func currentLabel(labels: [String]) -> String {
        let raw = min(definition.maxValue, max(definition.minValue, editor.controls[definition.key, default: definition.minValue]))
        let i = raw - definition.minValue
        guard labels.indices.contains(i) else { return "\(raw)" }
        return labels[i]
    }
}
