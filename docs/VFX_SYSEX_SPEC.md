# VFX-SD SysEx / MIDI Specification Reference

Source: **Ensoniq VFX-SD MIDI Implementation Specification v2.00** (Appendix A, in `docs/`).

## SysEx Packet Header (Section 2.1)

Every SysEx message to/from the VFX-SD uses this 6-byte header:

| Byte | Value | Meaning |
|------|-------|---------|
| 0 | `F0` | SysEx start |
| 1 | `0F` | Ensoniq manufacturer code |
| 2 | `05` | VFX Family ID |
| 3 | `00` | VFX-SD Model ID |
| 4 | `0n` | Base MIDI channel (0-indexed) |
| 5 | `0x` | Message Type (see below) |

Tail: `F7`

## Nibblization (Section 2.3)

All data bytes within the packet frame are transmitted as two nibblized bytes:
- Hi nibble first: `0000HHHH`
- Lo nibble second: `0000LLLL`

Example: byte `0x7F` (127) -> transmitted as `07 0F`

**Exception:** Message types in the header are NOT nibblized. Command types ARE nibblized (they are data).

## Message Types

| Type | Name | Direction |
|------|------|-----------|
| `00` | Command Message | Both |
| `01` | Error/Status | VFX-SD -> EXT |
| `02` | One Program Dump | Both |
| `03` | All Programs Dump | Both |
| `04` | One Preset Dump | Both |
| `05` | All Presets Dump | Both |
| `09` | Single Sequence Dump | Both |
| `0A` | All Sequence Dump | Both |
| `0B` | Track Parameters | Both |

## Command Types (within Message Type 00)

| Command | Name | Description |
|---------|------|-------------|
| `00` | Virtual Button | Simulate front panel button press |
| `01` | Parameter Change | Edit a single parameter in real-time |
| `02` | Edit Change Status | VFX-SD notifies EXT of multi-param change |
| `05` | Single Program Dump Request | Request current program |
| `06` | Single Preset Dump Request | Request current preset |
| `07` | Track Parameter Dump Request | Request track params |
| `08` | Dump Everything Request | Request all banks + tracks |
| `09` | Internal Program Bank Dump Request | Request all 60 programs |
| `0A` | Internal Preset Bank Dump Request | Request all 20 presets |
| `0B` | Single Sequence Dump | Initiate sequence dump |
| `0D` | Single Sequence Dump Request | Request current sequence |
| `0E` | All Sequence Dump Request | Request all sequences |

## Parameter Change (Command Type 01) — VERIFIED

This is the primary real-time editing command. Format (all nibblized):

```
F0 0F 05 00 [ch] 00           ← header (message type 00)
00 01                          ← command type 01 (nibblized)
[voiceHi] [voiceLo]           ← voice number [0..5] (nibblized)
[pageHi] [pageLo]             ← page number [0..31] (nibblized)
[slotHi] [slotLo]             ← slot number [0..5] (nibblized)
[valHiHi] [valHiLo]           ← value hi byte (nibblized)
[valLoHi] [valLoLo]           ← value lo byte (nibblized)
F7                             ← SysEx end
```

Total: 19 bytes per message.

**Example:** Set Filter #1 Cutoff (page 13, slot 1) to 100 on voice 0, channel 0:
```
F0 0F 05 00 00 00  00 01  00 00  00 0D  00 01  00 00  06 04  F7
```

## Virtual Button (Command Type 00) — VERIFIED

```
F0 0F 05 00 [ch] 00           ← header
00 00                          ← command type 00 (nibblized)
[btnHi] [btnLo]               ← button number (nibblized)
F7
```

Button down = number; button up = number + 96. Send both (with 200-300ms delay between pairs recommended).

Key button numbers: Play=91, Stop=92, Record=89, Wave=29, Pitch=33, Filters=35, LFO=42, Env1=45, Master=25, Write=62, Compare=63.

## Error/Status Codes (Message Type 01)

| Code | Name | Meaning |
|------|------|---------|
| `00` | NAK | Message could not be processed |
| `01` | Invalid Parameter Number | Bad voice/page/slot |
| `02` | Invalid Parameter Value | Value out of range |
| `03` | Invalid Button Number | No such button |
| `04` | ACK | Dump command accepted |

## Bulk Dump Sizes

| Dump | Message Type | Data Bytes | Total with header |
|------|-------------|------------|-------------------|
| One Program | 02 | 1060 | 1067 |
| All Programs (60) | 03 | 63600 | 63607 |
| One Preset | 04 | 96 | 103 |
| All Presets (20) | 05 | 1920 | 1927 |
| Track Parameters | 0B | 287 | 294 |

## Master Volume

**Master volume is NOT a SysEx page/slot parameter.** The VFX-SD responds to:
- **MIDI CC 7** (Volume) on the base channel
- The app sends CC 7 when adjusting `sys.masterVol` with Live enabled.

## MIDI CC Support (from Implementation Chart)

| CC | Function | TX | RX |
|----|----------|----|----|
| 1 | Mod Wheel | Yes | Yes |
| 4 | Foot Controller | Yes | Yes |
| 7 | Volume | Yes | Yes |
| 10 | Pan | Yes | Yes |
| 70 | Momentary Patch Select | Yes | Yes |
| 71 | Timbre Parameter | Yes | Yes |
| 72 | Release Parameter | Yes | Yes |

## Implementation in this project

- `LiveSysExBuilder.swift` — builds Parameter Change, Virtual Button, and CC messages
- `MIDIDeviceManager.swift` — sends SysEx and CC messages, handles sequencer transport
- `ParameterMap.swift` — complete page/slot/range definitions from spec section 5
- Full page/slot table: see `docs/Ensoniq VFX-SD MIDI Implementation Specification v2.00.md` section 5
