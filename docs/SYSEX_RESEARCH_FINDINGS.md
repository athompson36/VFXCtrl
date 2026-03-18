# SysEx Research Findings

Summary of what was found from manuals and online documentation for VFX-SD / Ensoniq real-time parameter (e.g. master volume) messages.

## Quick reference (all found SysEx/MIDI info)

| Item | Value / source |
|------|----------------|
| **Manufacturer** | Ensoniq `0x0F` (byte after F0) |
| **VFX-SD model/family** | `0x05` (from our program dumps: `F0 0F 05 00 00` + payload) |
| **Program dump header** | `F0 0F 05 00 00` … `F7` (see `sysex/notes.md`) |
| **Parameter change command (Fizmo/MR)** | `0x05` = Parameter Change Request; response `0x45` |
| **Fizmo header pattern** | `F0 0F [Family] 01 [Device]` then command byte (Fizmo family = 0x11) |
| **Our current live master vol message** | `F0 0F 05 01 00 05 00 00 [value] F7` (address 00 00 = placeholder) |
| **Master volume address** | Unknown; needs VFX-SD spec or Midi Quest capture |
| **VFX manual (message format)** | VFX Musician’s Manual p.144: “Midi System Exclusive Packet Pieces; Message Format” (open PDF for byte layout) |
| **Gearspace v2.10 thread** | Sequencer dumps only; no parameter-change format |
| **Debug (see bytes we send)** | System page → “Debug: Live logging” on → Xcode console `Live SysEx TX: …` |
| **Troubleshooting** | `docs/TROUBLESHOOTING.md` |

## Gearspace “v2.10 MIDI Spec” thread (checked)

**URL:** [Ensoniq VFX-SD v2.10 MIDI Spec Sysex documentation](https://gearspace.com/board/electronic-music-instruments-and-electronic-music-production/1207457-ensoniq-vfx-sd-v2-10-midi-spec-sysex-documentation.html)

**Content:** The thread is about **sequencer** SysEx (song/sequence/track dumps), not real-time parameter change or master volume. The OP (s9dd, March 2018) is looking for documentation on the **sequencer data format** (e.g. “Appendix A” revision that was “available upon request” from Ensoniq). No one in the thread posts a PDF or the actual v2.10 spec; no parameter-change or data-set message format appears. So this thread does **not** contain the real-time edit / master volume format.

## VFX-SD and VFX user manuals (checked)

- **ManualsLib** – VFX-SD User Manual (258 pp) and VFX Musician’s Manual (175 pp) are listed; pages 173, 192, 194 (SysEx) and VFX page 144 (“Midi System Exclusive Packet Pieces”, “Message Format”) were fetched. The HTML returned is mostly navigation; the **manual body text** (with byte layouts) does not appear in the fetched content (likely in PDF or JS-rendered content). So the actual “Message Format” / “Packet Head/Tail” description was not retrieved.
- **VFX manual page 144** (Ensoniq VFX Musician’s Manual) is titled: “Midi System Exclusive Packet Pieces; Midi System Exclusive Packet Head/Tail; **Message Format**; Receiver Errors” – that is the most promising place for a byte-level SysEx format (possibly shared or similar for VFX-SD). To get it you need to **open the PDF** (e.g. from ManualsLib or synthmanuals.com) and read page 144 (and any Appendix A) and search for “parameter”, “data set”, “real time”, “F0”, “0F”, or “message format”.

## Conclusion from this search

- **Gearspace:** No parameter-change or master-volume format; thread is sequencer-only.
- **Manuals:** Likely contain the format (especially VFX page 144 / Appendix A), but the byte-level description was not found in the HTML we could fetch. **Next step:** Open the VFX or VFX-SD PDF and read the SysEx / Appendix A section; or capture from Midi Quest.

---

## Sources checked (original)

- **sysexdb.com** – VFX-SD listed but no message byte layout.
- **Gearspace** – Thread “Ensoniq VFX-SD v2.10 MIDI Spec Sysex documentation” exists; content not retrieved (timeout). That thread is the most likely place for the actual spec.
- **Midi Quest** – VFX-SD editor sends real-time parameter edits; format not published. Capturing from Midi Quest is a practical way to get the correct bytes.
- **Ensoniq Fizmo MIDI** – [Fizmo SysEx](http://adjustablesquelch.github.io/Ensoniq-Fizmo-Midi/) documents a similar Ensoniq pattern:
  - Header: `F0 0F [Family] 01 [Device]`
  - Command **0x05** = Parameter Change Request (0x45 = Parameter Changed response).
  - Fizmo uses family `0x11`; VFX-SD is often identified with model/family byte **0x05** (matches our program dump `F0 0F 05 00 00`).
- **MR-Rack / MR-61 / MR-76** – Referenced as having “Parameter Change Requests”; MR SysEx spec at synthmanuals.com (fetch timed out). Likely same 0x05 pattern as Fizmo.
- **This repo** – `sysex/notes.md`: program dump = `F0 0F 05 00 00` + payload + `F7`. So bytes after manufacturer/model are `00 00` for (full) program dump.

## Inferred pattern (unverified for VFX-SD)

From Fizmo/MR and the dump header:

| Byte index | Meaning        | Program dump | Parameter change (guess) |
|------------|----------------|--------------|---------------------------|
| 0          | F0             | F0           | F0                        |
| 1          | Ensoniq        | 0F           | 0F                        |
| 2          | Model/Family   | 05 (VFX-SD)  | 05                        |
| 3          | Sub-id / type  | 00           | 01 (?)                    |
| 4          | Device ID      | 00           | 00                        |
| 5          | Command        | (payload)    | **05** = param change (?) |
| 6+         | Data           | payload      | address + value (?)       |

So a **candidate** real-time parameter message is:

`F0 0F 05 01 00 05 [addrHi] [addrLo] [value] F7`

or (if sub-id is not 01):

`F0 0F 05 00 00 05 [addrHi] [addrLo] [value] F7`

**Address for master volume is still unknown.** It might be a 2-byte offset into a “system” or “global” block, or a single byte; it could require a checksum. The only way to know is:

1. VFX-SD v2.10 MIDI Specification (from the Gearspace thread or Ensoniq), or  
2. Capture from Midi Quest (or another editor that works) while changing master volume, then compare with the bytes we send.

## What the app does

- **LiveSysExBuilder** now tries command byte **0x05** (Parameter Change Request) instead of 0x01, with address `00 00` as a placeholder. If the synth still does not respond, the next step is to capture a known-good message and set the exact bytes (and checksum, if any) in `buildMasterVolume`.
- **Debug logging** – With “Debug: Live logging” on, the console shows `Live SysEx TX: ...` so you can compare our message with a capture.

## Next steps

1. Get the VFX-SD v2.10 MIDI spec (e.g. from the Gearspace thread or a manual) and look for “parameter change”, “data set”, or “real-time edit”.
2. Or capture SysEx from Midi Quest while moving master volume; diff that against our `Live SysEx TX` and update `LiveSysExBuilder.buildMasterVolume` to match.
