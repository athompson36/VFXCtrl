import SwiftUI

/// System page: Master, MIDI control, Storage, and System global parameters (see docs/VFX_SYSTEM_PAGE.md).
/// Controls are organized by category and by data type (numeric, enum, boolean, action).
struct SystemPage: View {
    @EnvironmentObject private var editor: EditorState
    @AppStorage(EditorState.liveEditEnabledKey) private var liveEditEnabled: Bool = false
    @AppStorage(LiveDebugLog.defaultsKey) private var verboseLiveDebug: Bool = false

    /// Shown in custom pickers / sliders above; full map grid lists the rest.
    private static let handledInCustomUI: Set<String> = [
        "sys.masterVol", "sys.tune", "sys.touch",
        "sys.midiBaseCh", "sys.midiInMode", "sys.localControl", "sys.sysexRx", "sys.xposEnable",
        "sys.midiStatus", "sys.pitchTable",
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                liveToggle
                debugLogToggle
                masterSection
                midiSection
                storageSection
                systemSection
                otherSystemParameters
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(VFXTheme.surface)
    }

    private var liveToggle: some View {
        Toggle(isOn: $liveEditEnabled) {
            Text("Live")
                .foregroundStyle(VFXTheme.textPrimary)
            Text("Send parameter changes to synth (e.g. Master Vol)")
                .font(.caption)
                .foregroundStyle(VFXTheme.textSecondary)
        }
        .toggleStyle(.switch)
        .tint(VFXTheme.vfdGreen)
    }

    private var debugLogToggle: some View {
        Toggle(isOn: $verboseLiveDebug) {
            Text("Debug: Live logging")
                .foregroundStyle(VFXTheme.textPrimary)
            Text("Verbose logs to Xcode console when adjusting Live params")
                .font(.caption)
                .foregroundStyle(VFXTheme.textSecondary)
        }
        .toggleStyle(.switch)
        .tint(VFXTheme.vfdGreen)
    }

    // MARK: - Master (numeric 0–127)
    private var masterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Master")
            if liveEditEnabled {
                Text("Master Vol sends MIDI CC 7. Tune and Touch send SysEx Parameter Change (page 0). See official MIDI spec v2.00.")
                    .font(.caption)
                    .foregroundStyle(VFXTheme.textSecondary)
            }
            HStack(alignment: .firstTextBaseline, spacing: 16) {
                numericRow("Master Vol", key: "sys.masterVol", range: 0...127)
                numericRow("Tune", key: "sys.tune", range: 0...255)
                touchPickerRow
            }
        }
    }

    // MARK: - MIDI control (base ch 1–16, enums, booleans)
    private var midiSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("MIDI Control")
            HStack(alignment: .firstTextBaseline, spacing: 20) {
                HStack(spacing: 8) {
                    Text("Base Ch")
                        .foregroundStyle(VFXTheme.textPrimary)
                        .frame(width: 56, alignment: .leading)
                    Picker("", selection: Binding(
                        get: {
                            let raw = editor.controls["sys.midiBaseCh", default: 0]
                            // Migrate legacy patches that stored 1…16 instead of 0…15
                            let zeroBased = (1...16).contains(raw) ? raw - 1 : raw
                            return min(15, max(0, zeroBased)) + 1
                        },
                        set: { editor.set("sys.midiBaseCh", value: $0 - 1) }
                    )) {
                        ForEach(1...16, id: \.self) { n in Text("Ch \(n)").tag(n) }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 72)
                }
                HStack(spacing: 8) {
                    Text("In Mode")
                        .foregroundStyle(VFXTheme.textPrimary)
                        .frame(width: 56, alignment: .leading)
                    Picker("", selection: Binding(
                        get: { min(4, max(0, editor.controls["sys.midiInMode", default: 0])) },
                        set: { editor.set("sys.midiInMode", value: $0) }
                    )) {
                        Text("Omni").tag(0)
                        Text("Poly").tag(1)
                        Text("Multi").tag(2)
                        Text("Mono A").tag(3)
                        Text("Mono B").tag(4)
                    }
                    .pickerStyle(.menu)
                    .frame(width: 100)
                }
                toggleRow("Local", key: "sys.localControl")
                toggleRow("SysEx Rx", key: "sys.sysexRx")
                toggleRow("XPOS", key: "sys.xposEnable")
                HStack(spacing: 8) {
                    Text("Pgm chg")
                        .foregroundStyle(VFXTheme.textPrimary)
                        .frame(width: 56, alignment: .leading)
                    Picker("", selection: Binding(
                        get: { min(2, max(0, editor.controls["sys.midiStatus", default: 0])) },
                        set: { editor.set("sys.midiStatus", value: $0) }
                    )) {
                        Text("Local").tag(0)
                        Text("MIDI").tag(1)
                        Text("Both").tag(2)
                    }
                    .pickerStyle(.menu)
                    .frame(width: 72)
                }
            }
        }
    }

    // MARK: - Storage (actions; placeholders until disk/SysEx flow exists)
    private var storageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Storage / Disk")
            Text("Disk and SysEx operations are performed on the hardware. Buttons below are placeholders for future workflow.")
                .font(.caption)
                .foregroundStyle(VFXTheme.textSecondary)
            HStack(spacing: 12) {
                Button("Disk SAVE") { }
                    .buttonStyle(VFXButtonStyle())
                    .disabled(true)
                Button("Disk LOAD") { }
                    .buttonStyle(VFXButtonStyle())
                    .disabled(true)
                Button("SYS-EX REC") { }
                    .buttonStyle(VFXButtonStyle())
                    .disabled(true)
            }
        }
    }

    // MARK: - System / global (pitch table enum)
    private var systemSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("System")
            HStack(alignment: .firstTextBaseline, spacing: 16) {
                HStack(spacing: 8) {
                    Text("System pitch table")
                        .foregroundStyle(VFXTheme.textPrimary)
                        .frame(width: 120, alignment: .leading)
                    if let labels = ParameterEnumLabels.labels(forKey: "sys.pitchTable", minValue: 0, maxValue: 1) {
                        Picker("", selection: Binding(
                            get: { min(1, max(0, editor.controls["sys.pitchTable", default: 0])) },
                            set: { editor.set("sys.pitchTable", value: $0) }
                        )) {
                            ForEach(0...1, id: \.self) { v in
                                Text(labels[v]).tag(v)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 120)
                    }
                }
            }
        }
    }

    /// Remaining system / master SysEx parameters from the official map (pages 0–4, etc.).
    private var otherSystemParameters: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("All system parameters")
            Text("Remaining items from the system/master MIDI map (pages 0–4, etc.). Master, tune, touch, and common MIDI pickers are excluded above.")
                .font(.caption)
                .foregroundStyle(VFXTheme.textSecondary)
            ParameterDefinitionsPage(page: .system, excludeKeys: Self.handledInCustomUI, scrolls: false)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(VFXTheme.vfdGreen)
    }

    private var touchPickerRow: some View {
        HStack(spacing: 8) {
            Text("Touch")
                .foregroundStyle(VFXTheme.textPrimary)
                .frame(width: 72, alignment: .leading)
            if let labels = ParameterEnumLabels.labels(forKey: "sys.touch", minValue: 0, maxValue: 4) {
                Picker("", selection: Binding(
                    get: { min(4, max(0, editor.controls["sys.touch", default: 0])) },
                    set: { editor.set("sys.touch", value: $0) }
                )) {
                    ForEach(0...4, id: \.self) { v in
                        Text(labels[v]).tag(v)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 120)
            }
        }
    }

    private func numericRow(_ label: String, key: String, range: ClosedRange<Int>) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .foregroundStyle(VFXTheme.textPrimary)
                .frame(width: 72, alignment: .leading)
            Slider(
                value: Binding(
                    get: { Double(min(range.upperBound, max(range.lowerBound, editor.controls[key, default: range.lowerBound]))) },
                    set: { editor.set(key, value: Int($0.rounded())) }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound)
            )
            .tint(VFXTheme.vfdGreen)
            .frame(width: 100)
            Text("\(min(range.upperBound, max(range.lowerBound, editor.controls[key, default: range.lowerBound])))")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(VFXTheme.textSecondary)
                .frame(width: 36, alignment: .trailing)
        }
    }

    private func toggleRow(_ label: String, key: String) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .foregroundStyle(VFXTheme.textPrimary)
                .frame(width: 56, alignment: .leading)
            Toggle("", isOn: Binding(
                get: { (editor.controls[key, default: 0]) != 0 },
                set: { editor.set(key, value: $0 ? 1 : 0) }
            ))
            .toggleStyle(.switch)
            .tint(VFXTheme.vfdGreen)
            .labelsHidden()
        }
    }
}
