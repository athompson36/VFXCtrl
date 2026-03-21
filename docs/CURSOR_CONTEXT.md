# VFX-SD Editor / Librarian / Programmer — Cursor Context

## Project Overview
This project builds a modern macOS editor/librarian/programmer for the Ensoniq VFX-SD, with the software UI intentionally designed to become the blueprint for a future hardware controller.

The future hardware target is:
- 8 primary encoders
- 1 small OLED per encoder
- 1 larger main OLED
- navigation encoder + navigation buttons
- transport buttons
- tap tempo
- internal FX control
- sequencer control
- patch/program librarian integration through the Mac app first

The software must therefore behave like an instrument control surface, not like a generic spreadsheet editor.

---

## Primary Sources of Truth

### 1. Official MIDI specification
Use the official **Ensoniq VFX-SD MIDI Implementation Specification v2.00** as the canonical source for:
- SysEx packet structure
- command types
- logical parameter byte offsets
- page/slot addressing
- virtual button emulation
- bulk dump sizes
- preset / sequence / track parameter structures

### 2. Owner’s manual
Use the VFX-SD owner’s manual as the canonical source for:
- front-panel workflow
- page names
- conceptual synthesis layout
- UI labels
- programming categories
- performance workflow
- sequencer workflow
- effects workflow

### 3. Empirical captures from this project
Use Andrew’s captured single-program `.syx` dumps as the canonical source for:
- raw transport-layer byte positions inside actual dumps
- OS 2.10 behavior
- real-world nibble packing behavior
- parser validation
- transport offset confirmation

When official logical layout and empirical dump offsets differ, the difference must be preserved and documented, not flattened.

---

## High-Level Architecture

### App layers
1. SwiftUI macOS application shell
2. MIDI transport layer
3. SysEx encode / decode layer
4. Logical patch model
5. Raw dump parser / serializer
6. Librarian database layer
7. UI page model
8. Hardware-mirroring abstraction layer

### Recommended module layout
- `App/`
- `UI/`
- `Pages/`
- `MIDI/`
- `SysEx/`
- `Parser/`
- `Models/`
- `Librarian/`
- `HardwareMirror/`
- `Docs/`
- `Tests/`
- `Fixtures/`

---

## Core Project Principles

### 1. Preserve both logical and transport mappings
There are two valid parameter domains:

#### Logical parameter domain
Defined by the official MIDI spec:
- page number
- slot number
- voice number
- logical byte offset

#### Transport parameter domain
Defined by captured dumps:
- raw `.syx` byte index
- nibble-packed transport bytes
- file-size dependent layout
- empirically observed changed bytes

Never merge these into a single “offset” field without labeling which domain is being used.

### 2. Software-first, hardware-aware
Every UI decision should be evaluated against future hardware use.
If a page cannot be mapped sensibly to:
- 8 knobs
- 8 mini OLEDs
- one central OLED
- page buttons
then the software UI should be revised.

### 3. Instrument-panel first
Do not begin with a spreadsheet editor.
Begin with:
- page-based control
- 6–8 primary parameters per page
- large readable labels
- fast editing
- compare / snapshot / macro workflow

### 4. Conservative SysEx behavior
Vintage Ensoniq gear is timing-sensitive.
All MIDI transmission code must assume:
- safe throttling required
- retries may be required
- logging is essential
- state drift is possible
- OS-specific quirks may exist

---

## Known Device Facts

### Device
- Synth: Ensoniq VFX-SD
- OS confirmed in this project: 2.10

### Verified single-program dump fact
- Single-program dump captured from this synth is 1067 bytes total
- This matches the official MIDI spec

### SysEx header
Standard family header:
- `F0 0F 05 <model_id> <base_midi_channel>`

SysEx tail:
- `F7`

### Nibble packing
The official spec states that data bytes in bulk dumps are transmitted as two 4-bit nibbles:
- high nibble first
- low nibble second

This is why:
- logical byte offsets do not directly equal raw `.syx` byte positions
- some empirical parameter changes appear as one changed byte
- some appear as two changed bytes

---

## Command Types

Use these command types in the transport layer and document them in code comments:

- `00` = Virtual Button Command
- `01` = Error / Status
- `02` = Parameter Change
- `03` = Program Load
- `04` = Poke Byte to RAM / Cartridge (not implemented on VFX-SD)
- `05` = Single Program Dump Request
- `06` = Single Preset Dump Request
- `07` = Parameter Dump Request
- `08` = Dump Everything Request
- `09` = Internal Program Bank Dump Request
- `0A` = Internal Preset Bank Dump Request
- `0B` = Single Sequence Dump Request
- `0D` = Single Sequence Header Dump Request
- `0E` = All Sequence Dump Request

---

## Error / Status Codes

- `00` = NAK
- `01` = INVALID PARAMETER NUMBER
- `02` = INVALID PARAMETER VALUE
- `03` = INVALID BUTTON NUMBER
- `04` = ACK

The app must decode and surface these clearly in the debug console.

---

## Virtual Button Emulation

The official MIDI spec supports virtual front-panel button presses.
This is critically important for future hardware support and for testing panel parity.

Key logical button numbers:

- 15 = Up / INC
- 16 = Down / DEC
- 17–22 = Soft keys 0–5
- 24 = Master
- 25 = MIDI Control
- 27 = Prog/Mixer
- 33 = Wave
- 34 = Pitch
- 35 = Pitch Mod
- 37 = Filters
- 40 = Output
- 42 = LFO
- 45 = Env1
- 48 = Env2
- 50 = Env3
- 51 = Effects (Programming)
- 60 = Select Voice
- 61 = Copy
- 62 = Write
- 63 = Compare
- 64 = Value
- 65 = Pan
- 66 = Volume
- 67 = Transpose
- 68 = Key Zone
- 69 = Release
- 70 = Patch Select
- 73 = MIDI (Performance)
- 76 = Effects (Performance)
- 80 = Multi A
- 81 = Multi B
- 83 = Replace Program
- 84 = Edit Song
- 85 = Seq Control
- 86 = Edit Track
- 89 = Record
- 91 = Play
- 92 = Stop

Design implication:
- future hardware can use a hybrid model of direct parameter edits + virtual panel control
- sequencer transport is realistic
- UI tests can use virtual buttons for parity verification

---

## Program Dump Structure

### Logical structure
The official spec defines a repeating voice-block structure:

- Voice 1 = logical bytes `0..82`
- Voice 2 = logical bytes `83..165`
- Voice 3 = logical bytes `166..248`
- Voice 4 = logical bytes `249..331`
- Voice 5 = logical bytes `332..414`
- Voice 6 = logical bytes `415..497`

Program-level region begins at:
- `498` = program name
- `509..512` = program patch values
- `513` = program glitch / pitch-table switch
- `514` = program delay time
- `515` = delay rate / global bend range packed field
- `516` = resync
- `517` = timbre
- `518` = release
- `519..526` = effect parameters
- `527` = FX1 mix
- `528` = FX2 mix
- `529` = effect select

### Important consequence
Parser code must understand:
- voice-local parameters
- repeated voice blocks
- program-global fields
- nibble-packed fields
- hybrid packed/unpacked storage

---

## Key Logical Parameter Areas

### Envelopes
Voice-local envelope groups exist for:
- Env1
- Env2
- Env3

Important logical attack positions:
- Env1 Attack Time = logical byte 2 in voice block, page 21 slot 1 in the page/slot model
- Env2 Attack Time = logical byte 16 in voice block, page 24 slot 1
- Env3 Attack Time = logical byte 29 in voice block, page 27 slot 1

### Filters
Important logical filter positions:
- Filter 1 Cutoff = logical byte 49, page 13 slot 1
- Filter 2 Cutoff = logical byte 54/55 region depending on interpretation of packed lines from the spec sheet; keep exact sheet transcription in docs and code comments
- Filter pages must support:
  - type
  - cutoff
  - keyboard modulation
  - mod source
  - mod amount
  - ENV2 modulation

### LFO
Important logical LFO fields:
- LFO Depth
- LFO Restart
- LFO Speed Mod Amount
- LFO Delay Time
- Waveshape packed fields

### Wave / TransWave
Important logical fields:
- Wave Mod Source / packed field
- Wave Mod Amount
- Wave Start Index
- Wave Source Rate

### Output / Mixer
Important logical fields include:
- Volume Mod Amount
- Pan
- Pan Mod Amount
- Mixer Curve
- Mixer Scale
- Velocity Threshold

---

## Confirmed Empirical Mapping From This Project

These are confirmed from controlled single-program dump diffs on Andrew’s synth and must be preserved in the codebase as verified transport references.

- Env1 Attack -> raw dump offset `175`
- Env2 Attack -> raw dump offsets `202–203`
- Env3 Attack -> raw dump offsets `229–230`
- Filter 1 Low Pass Cutoff -> raw dump offset `271`
- Filter 2 High Pass Cutoff -> raw dump offset `281`
- LFO Rate -> raw dump offset `317`
- Transwave Start -> raw dump offset `327`

### Interpretation
This proves:
- the dump parser must support nibble-packed translation
- some parameters surface as one changed transport byte
- some parameters surface as two changed transport bytes
- direct raw-byte editing is not a reliable substitute for the logical parameter model

---

## MIDI Timing and Safety

### Default assumptions
- device is timing-sensitive
- bulk dumps are more fragile than short commands
- inter-message delay should default to conservative values
- logging is mandatory during development

### Recommended initial defaults
- parameter-change delay: 20 ms
- button-command delay: 20 ms
- request-response timeout: conservative and configurable
- burst sends: disabled by default
- retries: opt-in and logged

### Required transport features
- sent packet log
- received packet log
- timestamped packet log
- status/error decoding
- configurable delay
- hex view
- “dry run” encode preview
- saved capture export

---

## Librarian Design Requirements

The app is not just an editor.
It is also a librarian and future set-builder for a Gotek-based workflow.

Required librarian capabilities:
- import `.syx`
- import bulk dumps
- preserve original files
- preserve metadata
- tag patches
- favorites
- live-set collections
- duplicate detection
- compare two patches
- display source dump / source disk metadata
- later: bank curation for Gotek organization

### Data model guidance
Each stored patch record should include:
- UUID
- display name
- raw original sysex blob
- parsed logical patch model
- source file name
- source capture date
- source synth OS if known
- confidence flags for parameters
- tags
- notes
- favorite flag

---

## UI / UX Requirements

### Primary page model
Freeze software pages around future hardware needs.

Recommended page set:
1. Wave
2. Motion / Mod
3. Filter
4. Env1 / Amp
5. Env2 / Env3
6. LFO
7. Output / Mixer
8. Performance
9. FX
10. Sequencer / Transport

### Per-page design goals
Each page should expose:
- 6–8 primary controls
- clear labels
- live value readout
- low-friction adjustment
- visual grouping that can map to encoder OLED labels later

### Do not do
- giant all-parameter form as the primary UI
- ambiguous unlabeled packed-field editing
- raw-byte editing as the main workflow

### Do do
- page tabs / page buttons
- patch name always visible
- voice selection always visible when relevant
- compare / revert
- last-sent parameter readout
- MIDI activity indicator
- transport strip for sequence-related pages

---

## Future Hardware Translation Layer

The software must include a hardware-mirror abstraction layer from the beginning.

This abstraction should describe:
- page
- encoder index
- label
- short OLED label
- long label
- logical parameter binding
- current displayed value
- display formatter
- min / max / enum metadata

This allows the same data model to feed:
- SwiftUI UI widgets
- future per-encoder OLED labels
- the main OLED summary screen

### Future hardware controls
Planned future hardware surface:
- 8 encoders
- 8 mini OLEDs
- 1 larger main OLED
- navigation encoder
- transport buttons
- compare
- snapshot
- tap tempo
- page buttons
- FX access
- sequencer access

---

## Sequencer / Transport Relevance

Because the spec supports virtual button emulation for:
- Edit Song
- Seq Control
- Edit Track
- Record
- Play
- Stop

…the future hardware version can plausibly provide full sequencer transport and related panel workflow support.

Software must therefore reserve:
- transport control models
- virtual button send helpers
- sequencer-oriented page definitions
- timing-safe repeated button behavior

---

## Effects Requirements

The project must support:
- program effect select
- FX1 mix
- FX2 mix
- effect parameter blocks
- effect-set-dependent parameter labeling

Important complication:
The spec indicates that effect parameter names are dependent on the selected effect type / set.

This means:
- FX UI cannot be hardcoded as one universal set of labels
- FX UI must be dynamically labeled by selected effect algorithm

The data model should allow:
- effect algorithm enum
- parameter set resolver
- displayed labels based on algorithm
- dynamic value formatting

---

## Development Workflow Rules

### Parsing rules
- Never discard original raw sysex bytes
- Always parse into a logical model and preserve the source bytes
- Keep parser tests with fixed fixture dumps
- Keep nibble-pack / unpack functions isolated and unit tested

### Mapping rules
- Track official logical mapping separately from empirical transport mapping
- Every confirmed new parameter must be entered in both domains
- Every uncertain mapping must carry a confidence label

### UI rules
- UI labels should prefer owner’s-manual page names and synth panel terminology
- Use language that can later fit on small OLEDs
- Design page labels with short forms and long forms

### MIDI rules
- Never send unthrottled burst messages by default
- All outgoing SysEx must be logged in dev builds
- Decode and surface ACK/NAK / invalid parameter errors visibly

### File rules
- Do not mutate fixture files
- Preserve uploaded captures untouched
- Place generated artifacts in clearly named folders
- Name fixtures with parameter-change descriptions

---

## Suggested Folder Layout

```text
vfx-ctrl/
  docs/
    CURSOR_CONTEXT.md
    CURSOR_RULES.md
    MIDI_SPEC_NOTES.md
    EMPIRICAL_MAPPING.md
    UI_PAGES.md
  fixtures/
    sysex/
      single_program/
      bulk_dumps/
  src/
    app/
    midi/
    sysex/
    parser/
    models/
    librarian/
    ui/
    hardwaremirror/
  tests/
    parser/
    midi/
    ui/
```

---

## Immediate Next Technical Priorities

1. Build nibble pack/unpack helpers
2. Parse the 1067-byte single-program dump into a structured model
3. Add the confirmed empirical offsets
4. Implement single-program request / receive
5. Implement parameter-change sender
6. Map additional high-value parameters:
   - Filter 1 resonance / type
   - Filter 2 resonance / type
   - LFO depth
   - LFO delay
   - wave select / wave class
   - output level
   - pan
   - FX select
7. Build first Wave / Filter / Env / LFO pages
8. Build compare / revert model
9. Build librarian store
10. Add transport / virtual-button helpers

---

## Long-Term Outcome

By following this context correctly, the project should produce:
- a reliable VFX-SD macOS editor
- a searchable patch librarian
- a future-proof hardware control abstraction
- a direct path to a semi-knob-per-function VFX-SD programmer
- a transport- and FX-capable future hardware controller
