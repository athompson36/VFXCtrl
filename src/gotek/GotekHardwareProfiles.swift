import Foundation

// MARK: - Gotek unit families (visual + notes; no copyrighted photos — SF Symbols as stand-ins)

/// FlashFloppy-compatible Gotek families (see Gotek Models wiki).
struct GotekUnitFamily: Identifiable, Hashable, Sendable {
    let id: String
    /// Short label in the UI.
    let title: String
    /// Typical PCB / marketing identifiers.
    let typicalModels: String
    /// SF Symbol shown as a visual stand-in for the unit style.
    let symbolName: String
    /// Bullets from FlashFloppy wiki / hardware mods.
    let notes: [String]
    let wikiURL: String
    /// Optional retail product page (e.g. pre-built / cased Gotek).
    let vendorProductURL: String?

    static let all: [GotekUnitFamily] = [
        GotekUnitFamily(
            id: "samplerzone_gotek_extended",
            title: "SamplerZone Gotek Extended",
            typicalModels: "34×19 mm OLED (larger than Gotek I/II); rotary included; taller case",
            symbolName: "rectangle.on.rectangle",
            notes: [
                "Retail build from SamplerZone: extended case for instruments taller than ~24.5 mm; includes a 34 mm × 19 mm display and rotary encoder as standard.",
                "In-repo VFX-RACK-BUILD-FF344 FF.CFG: oled-128x64, oled-font 8x16, display-order 0d,7,1, rotary full,reverse (CW = higher slot), autoselect off (see docs/GOTEK_INDEXED_RACK.md).",
                "Sold pre-configured per host (e.g. Ensoniq VFX-SD); FlashFloppy wiki uses display-order (not display-nav-name) for name + status rows.",
                "Without-display option replaces the OLED with a cover; you lose the filename readout.",
            ],
            wikiURL: "https://github.com/keirf/FlashFloppy/wiki/Gotek-Models",
            vendorProductURL: "https://samplerzone.com/products/gotek-extended-floppy-emulator"
        ),
        GotekUnitFamily(
            id: "classic_3digit",
            title: "Classic 3-digit + buttons",
            typicalModels: "SFR1M44…, SFRC922D (STM32F105 or AT32F415)",
            symbolName: "circle.grid.3x3.fill",
            notes: [
                "Two buttons for image prev/next; display shows slot / track activity.",
                "Usually jumper at S0 for Shugart hosts (move factory S1 → S0 if needed).",
                "Straight floppy ribbon (no twist) except IBM PC special cases — see FlashFloppy Host Platforms.",
            ],
            wikiURL: "https://github.com/keirf/FlashFloppy/wiki/Gotek-Models",
            vendorProductURL: nil
        ),
        GotekUnitFamily(
            id: "oled_kc30_415",
            title: "OLED + rotary (KC30, AT32F415)",
            typicalModels: "SFRKC30.AT2, SFRKC30.AT3, SFRKC30.AT4",
            symbolName: "dial.medium.fill",
            notes: [
                "Rotary encoder (often KC30 header: CLK/DT/SW per Hardware Mods wiki).",
                "SFRKC30.AT2 may lack a JC jumper pad — set interface = ibmpc in FF.CFG if you need IBM-PC mode.",
                "SFRKC30.AT2 does not support Disk Change Reset via the SWCLK mod (wiki).",
            ],
            wikiURL: "https://github.com/keirf/FlashFloppy/wiki/Hardware-Mods#kc30-rotary-header",
            vendorProductURL: nil
        ),
        GotekUnitFamily(
            id: "oled_kc30_435",
            title: "OLED + rotary (AT32F435 / FF+)",
            typicalModels: "SFRKC30.AT4.35",
            symbolName: "memorychip.fill",
            notes: [
                "384kB SRAM — recommended for demanding HFE / caching (FlashFloppy+).",
                "MOR strap can connect motor sense for realistic ready timing (see Hardware Mods → Motor Signal).",
                "KC30 rotary header same wiring as other KC30 boards.",
            ],
            wikiURL: "https://github.com/keirf/FlashFloppy/wiki/Gotek-Models#artery-at32f435",
            vendorProductURL: nil
        ),
        GotekUnitFamily(
            id: "at3_no_rotary_header",
            title: "AT32F415 (no rotary pin header)",
            typicalModels: "SFRC922AT3",
            symbolName: "rectangle.split.3x1.fill",
            notes: [
                "No classic rotary header — wiki suggests wiring encoder to PA13/PA14 on the programming port, or use buttons.",
            ],
            wikiURL: "https://github.com/keirf/FlashFloppy/wiki/Gotek-Models#artery-at32f415",
            vendorProductURL: nil
        ),
    ]
}

// MARK: - Ensoniq hosts (FlashFloppy Host Platforms → Ensoniq)

/// Per [Host Platforms: Ensoniq](https://github.com/keirf/FlashFloppy/wiki/Host-Platforms#ensoniq).
struct EnsoniqHostProfile: Identifiable, Hashable, Sendable {
    let id: String
    let displayName: String
    /// FF.CFG keys to merge (values as stored in parsed map, including quotes where needed).
    let ffCfgEntries: [String: String]
    /// Rear jumper block: S0 / S1 / JC / MO guidance.
    let jumperSteps: [String]
    let wikiNotes: [String]
    /// Hints for VFX-CTRL library / USB export (not sent to hardware).
    let libraryBackupHints: String

    /// Keys applied when merging into an existing FF.CFG draft.
    static let mergeKeys: Set<String> = [
        "host", "interface", "pin02", "pin34", "chgrst",
    ]

    static let all: [EnsoniqHostProfile] = [
        EnsoniqHostProfile(
            id: "vfx_sd_sd1",
            displayName: "VFX / VFX-SD / SD-1 (Shugart floppy)",
            ffCfgEntries: [
                "host": "ensoniq",
                "interface": "shugart",
                "pin02": "auto",
                "pin34": "ready",
            ],
            jumperSteps: [
                "Start with jumper at S0 only (factory often ships on S1 — move to S0).",
                "Use a straight 34-pin ribbon (no twist) for Ensoniq unless your cable plant is already twisted for PC — then see Host Platforms general notes (MO vs S0).",
                "If the drive is not seen, try S1 only, or JC + S0, or JC + S1 (wiki general troubleshooting).",
            ],
            wikiNotes: [
                "FlashFloppy groups VFX-era machines with host = ensoniq for 800k / 1.6MB-style IMG handling.",
                "Wiki explicitly lists SD-1: S0, Shugart, no extra FF.CFG lines — VFX-SD is treated the same Shugart pattern in this app.",
            ],
            libraryBackupHints:
                "VFX-CTRL’s 60 programs per bank limit matches the VFX-SD internal RAM bank when exporting .syx. Use indexed or bank.json exports for predictable restore order; keep OS/library images in slots 0000 / 0001. For SamplerZone Extended OLED, keep 000N_ suffixes short; use Floppy Emulator → Apply recommended (VFX-SD rack + extended OLED) for FF.CFG."
        ),
        EnsoniqHostProfile(
            id: "eps",
            displayName: "EPS / EPS 16-Plus",
            ffCfgEntries: [
                "host": "ensoniq",
                "interface": "shugart",
                "pin02": "auto",
                "pin34": "ready",
                "chgrst": "delay-3",
            ],
            jumperSteps: [
                "Jumper at S0 only (typical).",
            ],
            wikiNotes: [
                "chgrst = delay-3 requires FlashFloppy v3.3a+ for reliable disk-change detection.",
            ],
            libraryBackupHints:
                "EPS SysEx and bank sizes differ from VFX-SD — use the EPS manual for program/bank counts. Export loose .syx with short names; confirm host = ensoniq and chgrst on the stick."
        ),
        EnsoniqHostProfile(
            id: "asr_ts_mr61",
            displayName: "ASR-10 / TS series / MR-61",
            ffCfgEntries: [
                "host": "ensoniq",
                "interface": "ibmpc-hdout",
                "pin02": "auto",
                "pin34": "ready",
            ],
            jumperSteps: [
                "Jumper at S0 only.",
            ],
            wikiNotes: [
                "These hosts need IBM-PC interface with density-select → interface = ibmpc-hdout in FF.CFG.",
            ],
            libraryBackupHints:
                "Sampler workflows often mix floppy images and SysEx dumps — keep image names under control for indexed mode; use separate USB folders if mixing .IMG and .syx."
        ),
        EnsoniqHostProfile(
            id: "mirage_sq80",
            displayName: "Mirage / SQ-80 (880kB IMG)",
            ffCfgEntries: [
                "host": "ensoniq",
                "interface": "shugart",
                "pin02": "auto",
                "pin34": "ready",
            ],
            jumperSteps: [
                "Try S0 first; follow general Ensoniq troubleshooting if needed.",
            ],
            wikiNotes: [
                "880kB Mirage / SQ-80 IMG layouts may need examples/Host/Ensoniq/IMG.CFG from the FlashFloppy distribution (geometry).",
                "This is separate from the VFX numeric rack workflow, which intentionally omits IMG.CFG on the stick.",
            ],
            libraryBackupHints:
                "Prefer HFE or wiki-approved IMG pipelines for Mirage/SQ-80; VFX-CTRL remains SysEx-centric for patch librarian tasks."
        ),
        EnsoniqHostProfile(
            id: "generic_ensoniq",
            displayName: "Other Ensoniq (try Shugart + ensoniq)",
            ffCfgEntries: [
                "host": "ensoniq",
                "interface": "shugart",
                "pin02": "auto",
                "pin34": "ready",
            ],
            jumperSteps: [
                "S0 first; then S1, JC+S0, JC+S1 per wiki if the host does not see the drive.",
            ],
            wikiNotes: [
                "Confirm your exact model on the FlashFloppy Host Platforms page; some lines need ibmpc-hdout or chgrst tweaks.",
            ],
            libraryBackupHints:
                "Match export layout to whatever floppy navigation mode you configured (indexed vs native folders)."
        ),
    ]

    static func profile(id: String) -> EnsoniqHostProfile? {
        all.first { $0.id == id }
    }
}

// MARK: - Merge into FF.CFG map

enum GotekEnsoniqSetupMerge {
    /// Merges `host` / `interface` / `pin02` / `pin34` / `chgrst` from the selected Ensoniq profile.
    static func mergeHostProfile(
        into entries: [String: String],
        profile: EnsoniqHostProfile,
        replace: Bool
    ) -> [String: String] {
        var out = entries
        if replace {
            for k in EnsoniqHostProfile.mergeKeys where profile.ffCfgEntries[k] == nil {
                out.removeValue(forKey: k)
            }
        }
        for (k, v) in profile.ffCfgEntries {
            guard EnsoniqHostProfile.mergeKeys.contains(k) else { continue }
            if replace || out[k] == nil {
                out[k] = v
            }
        }
        return out
    }
}
