# VFX-SD System Page

System-level parameters from the Ensoniq VFX-SD user manual (System Control, Master Page, MIDI Control Page, MIDI in Mode, Storage). Organized by **category** and by **data type** for consistent UI treatment.

## Categories and parameters

### 1. Master (manual pp. 101+)

| Parameter      | Key / ID        | Data type   | Range / values        | Notes |
|----------------|-----------------|------------|------------------------|-------|
| Master volume  | sys.masterVol   | numeric    | 0–127                  | Global output level. |
| Tune           | sys.tune        | numeric    | 0–127 (or ±cents TBD)  | Global tune. |
| Touch          | sys.touch       | numeric    | 0–127                  | Touch/aftertouch sensitivity (global or system). |

### 2. MIDI control (manual pp. 105, 107, 40–42)

| Parameter       | Key / ID         | Data type | Range / values                    | Notes |
|-----------------|------------------|-----------|------------------------------------|-------|
| Base channel    | sys.midiBaseCh   | numeric   | 1–16                               | Tx/Rx and SysEx on this channel. |
| MIDI in mode    | sys.midiInMode   | enum      | OMNI / POLY / MULTI                | How the synth receives MIDI. |
| Local control   | sys.localControl | boolean   | on / off                           | Keyboard drives internal sound. |
| SysEx receive   | sys.sysexRx      | boolean   | on / off                           | Accept System Exclusive. |
| XPOS (transpose)| sys.xposEnable   | boolean   | on / off                           | MIDI transpose enable (p. 105). |
| MIDI status     | sys.midiStatus   | enum      | LOCAL / MIDI / BOTH                | Per performance/track in manual; system-level if exposed. |

### 3. Storage / disk (manual pp. 173, 185, 192–195, 28, 81, 119–120)

| Parameter     | Key / ID   | Data type | Range / values | Notes |
|---------------|------------|-----------|----------------|-------|
| Disk SAVE     | —          | action    | button         | Save to 3.5" disk (file type: SEQ/SONG, etc.). |
| Disk LOAD     | —          | action    | button         | Load from disk (incl. SYS-EX DATA). |
| SYS-EX REC    | —          | action    | button         | Receive SysEx from MIDI In and save to disk. |
| File name     | sys.diskName | string  | 11 chars       | Disk file name (when saving/loading). |
| File type     | sys.diskType | enum    | 1-SEQ/SONG, 30-SEQ/SONGS, 60-SEQ/SONGS, SYS-EX DATA | For save/load. |

Storage operations are **actions** (buttons); file name/type are **parameters** when a save/load flow is active. Companion app may show placeholders until disk/SysEx flow is implemented.

### 4. System / global (manual pp. 103–104, 108)

| Parameter        | Key / ID        | Data type | Range / values     | Notes |
|------------------|-----------------|-----------|---------------------|-------|
| System pitch-table | sys.pitchTable | enum    | SYSTEM / ALL-C4 / CUSTOM | Global pitch table. |
| MIDI track names | sys.midiTrkNames | read-only / list | —               | MIDI-TRK-Names page (p. 104). |
| Global controllers (mono) | — | —      | (p. 108)            | Per-mode behavior; document if exposed. |

## Data-type conventions (for UI and rules)

- **Numeric:** 0–127 unless manual specifies otherwise (e.g. Base channel 1–16). Use slider or stepper; show value.
- **Enum:** Fixed set (e.g. OMNI/POLY/MULTI). Use picker/menu; store as index or string per key.
- **Boolean:** on/off, 0/1. Use toggle or two-option picker.
- **String:** e.g. 11-char disk name. Use text field; length limit per manual.
- **Action:** No stored value. Use button; label matches manual (e.g. SYS-EX REC, Disk SAVE).

## State keys (companion app)

System parameters that have a stored value use the `sys.*` prefix. Keys used by the System page:

- `sys.masterVol`, `sys.tune`, `sys.touch`
- `sys.midiBaseCh`, `sys.midiInMode`, `sys.localControl`, `sys.sysexRx`, `sys.xposEnable`, `sys.midiStatus`
- `sys.pitchTable`
- `sys.diskName`, `sys.diskType` (when implemented)

Actions (Disk SAVE, LOAD, SYS-EX REC) do not have keys; they trigger workflows.

## References

- Ensoniq VFX-SD user manual (Manualslib 1036312): System Control / Master Page (101), MIDI Control (105), MIDI in Mode (107), Storage/Disk (173, 185, 192–195), Performance MIDI (40–42).
- SysEx: always on Base Channel; receive/transmit procedures in manual.
