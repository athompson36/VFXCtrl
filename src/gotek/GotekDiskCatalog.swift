import Foundation

struct GotekDiskCatalogEntry: Identifiable, Hashable {
    var id: Int { diskNumber }
    let diskNumber: Int
    let sourceCollection: String
    let subCollection: String
    let diskName: String
    let soundCategory: String
    let compatibility: String
    let notes: String
}

enum GotekDiskCatalog {
    /// Loads bundled `VFX_SD_GOTEK_CATALOG.csv` (see Package resources).
    static func loadFromBundle() -> [GotekDiskCatalogEntry] {
        guard let url = Bundle.module.url(forResource: "VFX_SD_GOTEK_CATALOG", withExtension: "csv") else {
            return []
        }
        return (try? parse(csvFile: url)) ?? []
    }

    static func parse(csvFile url: URL) throws -> [GotekDiskCatalogEntry] {
        let data = try Data(contentsOf: url)
        guard let text = String(data: data, encoding: .utf8) else { return [] }
        return parse(csvString: text)
    }

    static func parse(csvString: String) -> [GotekDiskCatalogEntry] {
        var rows: [GotekDiskCatalogEntry] = []
        let lines = csvString.split(whereSeparator: \.isNewline)
        guard let first = lines.first else { return rows }
        let header = first.split(separator: ",").map { String($0) }
        guard header.count >= 7, header[0].contains("Disk") else { return rows }

        for line in lines.dropFirst() {
            let lineStr = String(line)
            guard !lineStr.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            let parts = splitCSVLine(lineStr)
            guard parts.count >= 7, let num = Int(parts[0].trimmingCharacters(in: .whitespaces)) else { continue }
            rows.append(
                GotekDiskCatalogEntry(
                    diskNumber: num,
                    sourceCollection: parts[1],
                    subCollection: parts[2],
                    diskName: parts[3],
                    soundCategory: parts[4],
                    compatibility: parts[5],
                    notes: parts[6]
                )
            )
        }
        return rows
    }

    /// Handles simple CSV; joins any extra trailing fields into `notes`.
    private static func splitCSVLine(_ line: String) -> [String] {
        let parts = line.split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
        guard parts.count > 7 else { return parts }
        let head = Array(parts.prefix(6))
        let noteBody = parts.dropFirst(6).joined(separator: ",")
        return head + [noteBody]
    }
}
