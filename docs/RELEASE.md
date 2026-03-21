# Release process (macOS) — draft

Use with [`TODO.md`](../TODO.md) Phase **7.8–7.9** and [`PRODUCTION_CHECKLIST.md`](./PRODUCTION_CHECKLIST.md).

## 1. Version

- Bump version in Xcode / target settings (or add when migrating from SPM-only to `.xcodeproj`).
- Pre-1.0: follow **`CHANGELOG.md`** (semantic `0.y.z` for package/tags).
- Record changes in `CHANGELOG.md` and paste the section into the GitHub Release body.

## 2. Build

- Archive **Release** configuration.
- Confirm minimum macOS matches `Package.swift` / README.

## 3. Sign & notarize

1. **Developer ID Application** certificate installed.
2. Enable **Hardened Runtime**; trim entitlements to what you need (MIDI does not require network by default).
3. `codesign` the `.app` (or use Xcode “Sign to Run Locally” → export for distribution per Apple’s current docs).
4. Submit for **notarization** (`notarytool` or Xcode Organizer).
5. **Staple** the ticket: `xcrun stapler staple VFXCtrl.app`

Apple’s steps change over time — follow [Notarizing macOS software](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution) when you ship.

## 4. Ship

- Zip or DMG the stapled app.
- Attach release notes: known issues, Phase 0 hardware assumptions, link to `GOTEK_COMPATIBILITY_AUDIT.md`.

## 5. Optional

- **Sparkle** or manual download page.
- Privacy policy if you add analytics or crash reports.
