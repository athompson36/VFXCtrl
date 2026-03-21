# Cursor Rules — VFX-SD Project

## Purpose
These rules govern all code, docs, and design decisions for the Ensoniq VFX-SD editor/librarian/programmer project.

---

## Rule 1 — Preserve Two Mappings
Always preserve:
1. official logical parameter mapping
2. empirical raw dump mapping

Do not collapse them into one unlabeled offset system.

---

## Rule 2 — Never Trust Raw Byte Positions Alone
Raw `.syx` byte positions are transport-layer observations only.
Do not use them as the sole source of truth for live parameter editing.
Use the official page/slot/voice model for outgoing real-time edits.

---

## Rule 3 — Keep Original Dumps Immutable
Never overwrite, normalize, trim, or modify original captured `.syx` files.
All parsing must operate on copied data structures in memory.

---

## Rule 4 — Isolate Nibble Packing
Any nibble pack/unpack logic must live in isolated utility functions with unit tests.
Do not scatter nibble decoding logic throughout UI or model code.

---

## Rule 5 — Build a Hardware-Mirroring UI
All editor pages must be designed to translate cleanly to:
- 8 encoders
- 8 mini OLED labels
- 1 central OLED
- page navigation buttons
- transport controls

Do not build a desktop UI that cannot later become the hardware UI.

---

## Rule 6 — Instrument Panel First
Prioritize a page-based, performance-oriented UI over a giant spreadsheet or inspector wall.

Good:
- Wave page
- Filter page
- Env page
- LFO page
- FX page
- Sequencer page

Bad:
- giant undifferentiated form as primary interface

---

## Rule 7 — Use Conservative MIDI Timing
Default all MIDI/SysEx operations to conservative timing.
No burst-send behavior unless explicitly enabled for testing.
All send paths should support configurable delays.

---

## Rule 8 — Log Everything in Dev Builds
In development builds, log:
- timestamp
- direction (send/receive)
- hex payload
- decoded command type
- decoded status/error meaning

Make logs easy to inspect and export.

---

## Rule 9 — Dynamic FX Labels
FX parameters are algorithm-dependent.
Do not hardcode one universal FX parameter label set.
Resolve labels dynamically from the selected effect type.

---

## Rule 10 — Page Labels Must Fit Small Displays
Every exposed parameter should have:
- a full display label
- a short OLED-safe label

Design with future hardware text limits in mind.

---

## Rule 11 — Always Version Findings
Any empirical mapping or behavior note must be tagged with:
- synth model
- OS version if known
- dump type
- confidence level

---

## Rule 12 — Test Against Fixtures
Every parser or serializer change must be validated against known fixture dumps.
Do not refactor parser logic without regression tests.

---

## Rule 13 — Separate Transport, Logic, and UI
Keep these separate:
- raw MIDI transport
- SysEx encoding/decoding
- logical patch model
- UI presentation
- librarian persistence

No tight coupling.

---

## Rule 14 — Prefer Explicit Names
Prefer names like:
- `logicalByteOffset`
- `rawDumpOffset`
- `pageNumber`
- `slotNumber`
- `voiceIndex`

Avoid vague names like:
- `offset`
- `param`
- `value2`

---

## Rule 15 — Make Reverse Engineering Auditable
Any newly inferred mapping should include:
- source dump files
- compared files
- changed byte(s)
- claimed parameter
- confidence note

Keep this visible in docs or generated mapping tables.

---

## Rule 16 — Preserve Manual Terminology
When naming pages and controls, prefer real VFX-SD panel/manual terminology:
- Wave
- Pitch
- Pitch Mod
- Filters
- Output
- LFO
- Env1
- Env2
- Env3
- Effects
- Key Zone
- Patch Select
- Release
- Seq Control
- Edit Song
- Edit Track

---

## Rule 17 — Sequencer Support Is In Scope
Do not design the app as “patch-only.”
Sequencer transport and button emulation are in scope because the MIDI spec supports relevant virtual buttons.

---

## Rule 18 — Build for Library Scale
Design the librarian to handle:
- many single-program captures
- bulk dumps
- favorites
- tags
- live sets
- comparison workflows
- future Gotek-oriented organization

---

## Rule 19 — No Silent Data Loss
If parsing encounters unknown fields, preserve them.
Unknown bytes or fields must round-trip intact unless explicitly edited.

---

## Rule 20 — Favor Deterministic Serialization
Whenever serializing data back to SysEx:
- preserve unchanged unknown fields
- preserve canonical order
- avoid lossy transforms
- ensure byte-stable output where possible

---

## Rule 21 — Make Value Formatting Explicit
For each parameter, define:
- numeric range
- bipolar / unipolar
- enum labels if applicable
- packed-field behavior
- display formatter

Do not leave formatting implicit in UI code.

---

## Rule 22 — Build With Confidence Levels
Mappings and features should be labeled:
- official
- empirically confirmed
- inferred
- unknown

This prevents accidental overclaiming.

---

## Rule 23 — Keep Docs Current
Whenever a parameter is newly confirmed, update:
- mapping spreadsheet or table
- empirical mapping doc
- parser tests
- UI binding notes if applicable

---

## Rule 24 — Optimize for Real Use
The end result must be fast enough and clear enough that Andrew could realistically use it to:
- edit buried parameters quickly
- manage patches
- prepare curated banks
- define a future hardware layout

---

## Rule 25 — The Software Defines the Hardware
Treat the software control model as the prototype for the hardware controller.
The hardware should emerge from proven software page layouts, not the other way around.
