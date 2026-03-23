import AppKit
import SwiftUI

/// Guides FlashFloppy USB-stick `.upd` updates per https://github.com/keirf/FlashFloppy/wiki/Firmware-Update
struct FirmwareUpdateWizardView: View {
    private let service = FlashFloppyReleaseService()

    @State private var isFetching = false
    @State private var isDownloading = false
    @State private var statusMessage: String?
    @State private var errorMessage: String?

    @State private var releaseInfo: FlashFloppyReleaseService.ReleaseZipInfo?
    @State private var artifacts: FlashFloppyReleaseService.ExtractedArtifacts?

    @State private var bootloaderMode = false
    @State private var selectedFirmwareURLs: Set<URL> = []
    @State private var selectedBootloaderURLs: Set<URL> = []

    @State private var showAdvancedDFU = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FlashFloppy firmware (USB .upd)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(VFXTheme.textPrimary)

            Text(
                "Official updates use a FAT USB stick in the Gotek. Remove old .upd files from the stick root, copy the new file(s), then power on with both buttons held until the display shows UPD."
            )
            .font(.caption)
            .foregroundStyle(VFXTheme.textSecondary)
            .fixedSize(horizontal: false, vertical: true)

            Toggle("Bootloader update (risky — see wiki)", isOn: $bootloaderMode)
                .font(.callout)
                .onChange(of: bootloaderMode) { _, _ in
                    syncSelectionDefaults()
                }

            HStack {
                Button("Fetch latest release") {
                    Task { await fetchLatest() }
                }
                .disabled(isFetching || isDownloading)

                if let tag = releaseInfo?.tag {
                    Text(tag)
                        .font(.caption.monospaced())
                        .foregroundStyle(VFXTheme.vfdGreen)
                }
            }

            if let info = releaseInfo {
                Button("Download & unpack") {
                    Task { await downloadAndUnpack(info: info) }
                }
                .disabled(isDownloading || isFetching)
            }

            if let art = artifacts {
                updSelectionList(art)
                Button("Choose USB stick root…") {
                    stageToUSB(artifacts: art)
                }
                .buttonStyle(VFXButtonStyle())
            }

            if let s = statusMessage {
                Text(s)
                    .font(.caption)
                    .foregroundStyle(VFXTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let e = errorMessage {
                Text(e)
                    .font(.caption)
                    .foregroundStyle(VFXTheme.vfdAmber)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Link("Firmware Update (FlashFloppy wiki)", destination: URL(string: "https://github.com/keirf/FlashFloppy/wiki/Firmware-Update")!)
                .font(.caption)

            DisclosureGroup(isExpanded: $showAdvancedDFU) {
                Text(
                    "Initial programming uses DFU and jumper wiring; macOS sometimes needs a USB hub. Install dfu-util (e.g. Homebrew), use the .dfu file from the release archive, and follow:"
                )
                .font(.caption)
                .foregroundStyle(VFXTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
                Link("Firmware Programming (wiki)", destination: URL(string: "https://github.com/keirf/FlashFloppy/wiki/Firmware-Programming")!)
                    .font(.caption)
                Text(
                    "Example (replace MCU file name):\nsudo dfu-util -a 0 -s :unprotect:force -D dfu/flashfloppy-at415-st105-x.xx.dfu\nsudo dfu-util -a 0 -D dfu/flashfloppy-at415-st105-x.xx.dfu"
                )
                .font(.caption2.monospaced())
                .foregroundStyle(VFXTheme.textSecondary)
                .textSelection(.enabled)
                .padding(.top, 4)
                Button("Copy example commands") {
                    let t = """
                    sudo dfu-util -a 0 -s :unprotect:force -D dfu/flashfloppy-at415-st105-x.xx.dfu
                    sudo dfu-util -a 0 -D dfu/flashfloppy-at415-st105-x.xx.dfu
                    """
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(t, forType: .string)
                }
                .buttonStyle(.borderless)
                .font(.caption)
            } label: {
                Text("Advanced: DFU / initial programming")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(VFXTheme.textSecondary)
            }
        }
        .padding(12)
        .background(VFXTheme.surface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private func updSelectionList(_ art: FlashFloppyReleaseService.ExtractedArtifacts) -> some View {
        let list = bootloaderMode ? art.bootloaderUpds : art.firmwareUpds
        if list.isEmpty {
            Text(bootloaderMode ? "No bootloader .upd found under alt/bootloader in this archive." : "No firmware .upd found in this archive.")
                .font(.caption)
                .foregroundStyle(VFXTheme.vfdAmber)
        } else {
            Text("Select file(s) to copy to the USB root (both universal + legacy is OK if unsure).")
                .font(.caption)
                .foregroundStyle(VFXTheme.textSecondary)
            ForEach(list, id: \.self) { url in
                Toggle(isOn: binding(for: url, bootloader: bootloaderMode)) {
                    Text(url.lastPathComponent)
                        .font(.caption.monospaced())
                }
            }
        }
    }

    private func binding(for url: URL, bootloader: Bool) -> Binding<Bool> {
        Binding(
            get: {
                bootloader ? selectedBootloaderURLs.contains(url) : selectedFirmwareURLs.contains(url)
            },
            set: { on in
                if bootloader {
                    if on { selectedBootloaderURLs.insert(url) } else { selectedBootloaderURLs.remove(url) }
                } else {
                    if on { selectedFirmwareURLs.insert(url) } else { selectedFirmwareURLs.remove(url) }
                }
            }
        )
    }

    private func syncSelectionDefaults() {
        guard let art = artifacts else { return }
        if bootloaderMode {
            selectedBootloaderURLs = Set(art.bootloaderUpds)
            selectedFirmwareURLs = []
        } else {
            selectedFirmwareURLs = Set(art.firmwareUpds)
            selectedBootloaderURLs = []
        }
    }

    @MainActor
    private func fetchLatest() async {
        errorMessage = nil
        statusMessage = nil
        isFetching = true
        defer { isFetching = false }
        do {
            let info = try await service.fetchLatestRelease()
            releaseInfo = info
            artifacts = nil
            statusMessage = "Latest: \(info.zipAssetName)"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func downloadAndUnpack(info: FlashFloppyReleaseService.ReleaseZipInfo) async {
        errorMessage = nil
        statusMessage = nil
        isDownloading = true
        defer { isDownloading = false }
        do {
            let zip = try await service.downloadZip(for: info)
            let art = try service.unzipAndDiscover(zipURL: zip, tag: info.tag)
            artifacts = art
            syncSelectionDefaults()
            statusMessage = "Unpacked to cache. Found \(art.firmwareUpds.count) firmware and \(art.bootloaderUpds.count) bootloader .upd file(s)."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func stageToUSB(artifacts art: FlashFloppyReleaseService.ExtractedArtifacts) {
        errorMessage = nil
        let chosen: [URL] = bootloaderMode
            ? Array(selectedBootloaderURLs).sorted { $0.path < $1.path }
            : Array(selectedFirmwareURLs).sorted { $0.path < $1.path }
        guard !chosen.isEmpty else {
            errorMessage = "Select at least one .upd file."
            return
        }

        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose USB Root"
        panel.title = "FlashFloppy — USB stick root"
        panel.message = "Select the root of your FAT-formatted USB stick (the folder that shows at the top level on the drive)."

        guard panel.runModal() == .OK, let usbRoot = panel.url else { return }
        guard usbRoot.startAccessingSecurityScopedResource() else {
            errorMessage = "Could not access the selected folder."
            return
        }
        defer { usbRoot.stopAccessingSecurityScopedResource() }

        do {
            let existing = try UpdStagingService.listUpdInRoot(of: usbRoot)
            if !existing.isEmpty {
                let names = existing.map(\.lastPathComponent).joined(separator: ", ")
                let alert = NSAlert()
                alert.messageText = "Remove existing .upd files?"
                alert.informativeText = "These will be deleted from the stick root: \(names)"
                alert.addButton(withTitle: "Remove and copy")
                alert.addButton(withTitle: "Cancel")
                guard alert.runModal() == .alertFirstButtonReturn else { return }
            }
            try UpdStagingService.replaceUpdOnUSB(sources: chosen, usbRoot: usbRoot)
            statusMessage = "Copied \(chosen.map(\.lastPathComponent).joined(separator: ", ")). Eject the stick, insert in Gotek, power on with both buttons until UPD, then release."
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
