# VFX-SD Sequencer: MIDI / SysEx Research

Summary of research into the Ensoniq VFX-SD sequencer’s MIDI and SysEx behaviour. Parameters below are **inferred** from manuals, SynthDB, Sound Quest, and standard MIDI unless marked verified.

## Sequencer specs (from public sources)

- **Tracks:** 24 (12 track + 12 song), real- or step-time.
- **Capacity:** 25,000 notes standard, expandable to 75,000.
- **Songs/sequences:** Up to 60.
- **Resolution:** 96 PPQN.
- **Features:** Quantize, punch in/out, MIDI clock sync, SysEx dump/load for track data (v2.00+).
- **Storage:** Sequences/songs and SysEx on 3.5" floppy; sequencer OS loaded from disk.

## Standard MIDI (likely supported)

| Message        | Hex    | Purpose              | Status   |
|----------------|--------|----------------------|----------|
| Timing Clock   | 0xF8   | 24 per quarter note  | inferred |
| Start          | 0xFA   | Play from beginning  | inferred |
| Continue       | 0xFB   | Resume from measure  | inferred |
| Stop           | 0xFC   | Stop playback        | inferred |
| Song Select    | 0xF3   | Song number (0–127)  | inferred |
| Song Position  | 0xF2   | LSB, MSB (0–16383)   | inferred |

## Parameters to expose in UI (SysEx/address TBD)

| Parameter        | Description                    | Typical range | UI type   | Status   |
|-----------------|--------------------------------|---------------|-----------|----------|
| Tempo           | BPM                            | 1–300         | TextField | inferred |
| Song number     | Current song (1–60)            | 1–60          | Picker    | inferred |
| Sequence number | Current sequence (1–60)        | 1–60          | Picker    | inferred |
| Track number    | Current track (1–24)           | 1–24          | Picker    | inferred |
| Loop            | Loop on/off or start/end       | on/off        | Toggle    | inferred |
| Quantize        | Grid (e.g. 1/4, 1/8, 1/16)     | preset list   | Picker    | inferred |
| Click           | Metronome on/off               | on/off        | Toggle    | inferred |
| Transport mode  | Play / Record / Stop           | enum          | Picker    | inferred |
| Clock source    | Internal / MIDI clock          | enum          | Picker    | inferred |
| Tap tempo       | Tap to set tempo               | —             | Button    | inferred |
| Punch in        | Auto punch-in measure          | 0–999         | TextField | inferred |
| Punch out       | Auto punch-out measure         | 0–999         | TextField | inferred |
| Track dump      | Request track SysEx dump       | —             | Button    | to verify |
| Track load      | Send track SysEx to synth      | —             | Button    | to verify |
| Song dump       | Request song/sequence dump    | —             | Button    | to verify |

## References

- SynthDB (synth-db.com): 24-track, 60 songs/sequences, 96 PPQN, track SysEx v2.00+.
- Sound Quest MIDI Quest: VFX-SD sequencer and track data (dump/load).
- sequencer.de: VFX-SD “advanced sequencer”, 12+12 track.
- VFX_SYSEX_SPEC.md: sequencer-related dumps listed; exact message layout not verified.
- Ensoniq VFX-SD v2.10 MIDI Spec (Gearspace) and owner/service manuals for byte-level detail when available.

## Implementation notes

- Transport (Play/Stop/Record/Continue) can be implemented via 0xFA/0xFB/0xFC once response is confirmed.
- Tempo and song/sequence/track selection may be real-time SysEx or system-exclusive; addresses need spec or capture.
- Dump/load buttons remain placeholders until request and response formats are documented or captured.
