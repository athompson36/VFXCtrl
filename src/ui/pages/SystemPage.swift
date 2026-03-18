import SwiftUI

/// System page: Master, MIDI control, Storage, and System global parameters (see docs/VFX_SYSTEM_PAGE.md).
/// Controls are organized by category and by data type (numeric, enum, boolean, action).
struct SystemPage: View {
    @EnvironmentObject private var editor: EditorState
    @AppStorage(EditorState.liveEditEnabledKey) private var liveEditEnabled: Bool = false
    @AppStorage(LiveDebugLog.defaultsKey) private var verboseLiveDebug: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                liveToggle
                debugLogToggle
                masterSection
                midiSection
                storageSection
                systemSection
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
                Text("Live Master Vol uses a placeholder SysEx format; the synth may not change volume until the format is verified from the VFX-SD MIDI spec or a capture (see docs/LIVE_PARAMETER_RESEARCH.md).")
                    .font(.caption)
                    .foregroundStyle(VFXTheme.textSecondary)
            }
            HStack(alignment: .firstTextBaseline, spacing: 16) {
                numericRow("Master Vol", key: "sys.masterVol")
                numericRow("Tune", key: "sys.tune")
                numericRow("Touch", key: "sys.touch")
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
                        get: { min(16, max(1, editor.controls["sys.midiBaseCh", default: 1])) },
                        set: { editor.set("sys.midiBaseCh", value: $0) }
                    )) {
                        ForEach(1...16, id: \.self) { n in Text("\(n)").tag(n) }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 56)
                }
                HStack(spacing: 8) {
                    Text("In Mode")
                        .foregroundStyle(VFXTheme.textPrimary)
                        .frame(width: 56, alignment: .leading)
                    Picker("", selection: Binding(
                        get: { min(2, max(0, editor.controls["sys.midiInMode", default: 0])) },
                        set: { editor.set("sys.midiInMode", value: $0) }
                    )) {
                        Text("OMNI").tag(0)
                        Text("POLY").tag(1)
                        Text("MULTI").tag(2)
                    }
                    .pickerStyle(.menu)
                    .frame(width: 80)
                }
                toggleRow("Local", key: "sys.localControl")
                toggleRow("SysEx Rx", key: "sys.sysexRx")
                toggleRow("XPOS", key: "sys.xposEnable")
                HStack(spacing: 8) {
                    Text("Status")
                        .foregroundStyle(VFXTheme.textPrimary)
                        .frame(width: 44, alignment: .leading)
                    Picker("", selection: Binding(
                        get: { min(2, max(0, editor.controls["sys.midiStatus", default: 0])) },
                        set: { editor.set("sys.midiStatus", value: $0) }
                    )) {
                        Text("LOCAL").tag(0)
                        Text("MIDI").tag(1)
                        Text("BOTH").tag(2)
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
                    Text("Pitch Table")
                        .foregroundStyle(VFXTheme.textPrimary)
                        .frame(width: 80, alignment: .leading)
                    Picker("", selection: Binding(
                        get: { min(2, max(0, editor.controls["sys.pitchTable", default: 0])) },
                        set: { editor.set("sys.pitchTable", value: $0) }
                    )) {
                        Text("SYSTEM").tag(0)
                        Text("ALL-C4").tag(1)
                        Text("CUSTOM").tag(2)
                    }
                    .pickerStyle(.menu)
                    .frame(width: 100)
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(VFXTheme.vfdGreen)
    }

    private func numericRow(_ label: String, key: String) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .foregroundStyle(VFXTheme.textPrimary)
                .frame(width: 72, alignment: .leading)
            Slider(
                value: Binding(
                    get: { Double(editor.controls[key, default: 0]) },
                    set: { editor.set(key, value: Int($0.rounded())) }
                ),
                in: 0...127
            )
            .tint(VFXTheme.vfdGreen)
            .frame(width: 100)
            Text("\(editor.controls[key, default: 0])")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(VFXTheme.textSecondary)
                .frame(width: 28, alignment: .trailing)
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
