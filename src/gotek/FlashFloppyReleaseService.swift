import Foundation

// MARK: - GitHub API

private struct GitHubReleaseDTO: Decodable {
    let tag_name: String
    let assets: [Asset]
    struct Asset: Decodable {
        let name: String
        let browser_download_url: String
    }
}

/// Fetches FlashFloppy release ZIPs from GitHub, unpacks locally, discovers `.upd` artifacts.
final class FlashFloppyReleaseService {
    struct ReleaseZipInfo: Equatable {
        var tag: String
        var zipAssetName: String
        var zipDownloadURL: URL
    }

    struct ExtractedArtifacts: Equatable {
        /// Firmware `.upd` files outside `alt/bootloader` (typically universal + legacy).
        var firmwareUpds: [URL]
        /// `.upd` files under `alt/bootloader`.
        var bootloaderUpds: [URL]
        var extractedRoot: URL
    }

    enum ServiceError: LocalizedError, Equatable {
        case httpStatus(Int)
        case invalidResponse
        case noZipAsset
        case unzipFailed(Int32)
        case unzipMissingBinary
        case noFirmwareUpdInArchive

        var errorDescription: String? {
            switch self {
            case .httpStatus(let c): return "GitHub request failed (HTTP \(c))."
            case .invalidResponse: return "Unexpected response from GitHub."
            case .noZipAsset: return "No flashfloppy-*.zip asset in the latest release."
            case .unzipFailed(let code): return "Unzip failed (exit \(code))."
            case .unzipMissingBinary: return "Could not find /usr/bin/unzip."
            case .noFirmwareUpdInArchive: return "Release archive contained no firmware .upd files."
            }
        }
    }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Parses `GET /repos/keirf/flashfloppy/releases/latest` JSON. Exposed for unit tests.
    static func parseLatestReleaseJSON(_ data: Data) throws -> ReleaseZipInfo {
        let dto = try JSONDecoder().decode(GitHubReleaseDTO.self, from: data)
        let zip = dto.assets.first { asset in
            let n = asset.name.lowercased()
            return n.hasPrefix("flashfloppy-") && n.hasSuffix(".zip")
        }
        guard let zip else { throw ServiceError.noZipAsset }
        guard let url = URL(string: zip.browser_download_url) else { throw ServiceError.invalidResponse }
        return ReleaseZipInfo(tag: dto.tag_name, zipAssetName: zip.name, zipDownloadURL: url)
    }

    private static let latestReleaseAPI = URL(string: "https://api.github.com/repos/keirf/flashfloppy/releases/latest")!

    func fetchLatestRelease() async throws -> ReleaseZipInfo {
        var req = URLRequest(url: Self.latestReleaseAPI)
        req.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        req.setValue("VFXCtrl/1.0", forHTTPHeaderField: "User-Agent")
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw ServiceError.invalidResponse }
        guard (200 ... 299).contains(http.statusCode) else { throw ServiceError.httpStatus(http.statusCode) }
        return try Self.parseLatestReleaseJSON(data)
    }

    /// Cache: `Application Support/VFXCtrl/FlashFloppyCache/<tag>/`
    func cacheBaseDirectory() throws -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let dir = base.appendingPathComponent("VFXCtrl", isDirectory: true)
            .appendingPathComponent("FlashFloppyCache", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func downloadZip(for info: ReleaseZipInfo) async throws -> URL {
        let root = try cacheBaseDirectory()
        let tagDir = root.appendingPathComponent(info.tag, isDirectory: true)
        try FileManager.default.createDirectory(at: tagDir, withIntermediateDirectories: true)
        let localZip = tagDir.appendingPathComponent(info.zipAssetName)
        if FileManager.default.fileExists(atPath: localZip.path) {
            return localZip
        }
        var req = URLRequest(url: info.zipDownloadURL)
        req.setValue("VFXCtrl/1.0", forHTTPHeaderField: "User-Agent")
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
            throw ServiceError.invalidResponse
        }
        try data.write(to: localZip)
        return localZip
    }

    func unzipAndDiscover(zipURL: URL, tag: String) throws -> ExtractedArtifacts {
        let root = try cacheBaseDirectory()
        let tagDir = root.appendingPathComponent(tag, isDirectory: true)
        let extractDir = tagDir.appendingPathComponent("extracted", isDirectory: true)
        if FileManager.default.fileExists(atPath: extractDir.path) {
            try FileManager.default.removeItem(at: extractDir)
        }
        try FileManager.default.createDirectory(at: extractDir, withIntermediateDirectories: true)
        try Self.runUnzip(zipPath: zipURL.path, destination: extractDir.path)
        let (fw, bl) = Self.classifyUpds(under: extractDir)
        return ExtractedArtifacts(firmwareUpds: fw, bootloaderUpds: bl, extractedRoot: extractDir)
    }

    private static func classifyUpds(under root: URL) -> (firmware: [URL], bootloader: [URL]) {
        var firmware: [URL] = []
        var bootloader: [URL] = []
        guard let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return (firmware, bootloader) }
        for case let u as URL in enumerator {
            guard (try? u.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true else { continue }
            guard u.pathExtension.lowercased() == "upd" else { continue }
            let p = u.path
            if p.contains("/alt/bootloader/") {
                bootloader.append(u)
            } else {
                firmware.append(u)
            }
        }
        let sort: (URL, URL) -> Bool = { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
        return (firmware.sorted(by: sort), bootloader.sorted(by: sort))
    }

    private static func runUnzip(zipPath: String, destination: String) throws {
        let unzip = "/usr/bin/unzip"
        guard FileManager.default.fileExists(atPath: unzip) else { throw ServiceError.unzipMissingBinary }
        let p = Process()
        p.executableURL = URL(fileURLWithPath: unzip)
        p.arguments = ["-q", "-o", zipPath, "-d", destination]
        try p.run()
        p.waitUntilExit()
        guard p.terminationStatus == 0 else { throw ServiceError.unzipFailed(p.terminationStatus) }
    }

    // MARK: - Stage latest firmware to USB

    /// Fetches the latest release, ensures ZIP is local and extracted, returns main firmware `.upd` URLs (not bootloader).
    func prepareLatestFirmwareUpds() async throws -> (tag: String, firmwareUpds: [URL]) {
        let info = try await fetchLatestRelease()
        let zipURL = try await downloadZip(for: info)
        let art = try unzipAndDiscover(zipURL: zipURL, tag: info.tag)
        guard !art.firmwareUpds.isEmpty else {
            throw ServiceError.noFirmwareUpdInArchive
        }
        return (info.tag, art.firmwareUpds)
    }

    /// Copies all main firmware `.upd` files from the latest release to the USB root (removes existing root `*.upd` first).
    func stageLatestFirmwareUpds(to usbRoot: URL) async throws {
        let (_, urls) = try await prepareLatestFirmwareUpds()
        try UpdStagingService.replaceUpdOnUSB(sources: urls, usbRoot: usbRoot)
    }
}
