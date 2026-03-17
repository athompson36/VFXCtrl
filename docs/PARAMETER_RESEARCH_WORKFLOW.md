# Reverse-Engineering Workflow

## Objective
Map every editable VFX-SD parameter to an exact byte offset or real-time edit address without guessing.

## Required tools

- stable MIDI interface
- VFX-SD with SysEx enabled
- this repo's `tools/vfx_sysex_inspector.py`
- optional SysEx utility on Mac for manual send/receive

## Procedure

### A. Dump-based mapping
1. Select a known patch.
2. Send **Current Program** from the VFX-SD.
3. Save as `baseline.syx`.
4. Change exactly one parameter by a known amount.
5. Send Current Program again.
6. Save as `paramname_valueX.syx`.
7. Run the diff tool.
8. Repeat for several values to confirm scaling.

### B. Real-time edit mapping
1. Use a SysEx utility or this app's raw send console.
2. Send candidate edit messages based on the original spec.
3. Start with long delays.
4. Observe whether the synth updates cleanly, errors, or ignores.
5. Mark the message definition as verified only after repeated success.

## Rules

- Never edit more than one synth parameter between captures.
- Always capture a before and after.
- Keep detailed notes in `sysex/notes.md`.
- Use at least three confirmation points before marking an offset verified.

## Safety defaults

- 50 ms initial inter-message delay
- no burst sends
- no auto-repeat while turning software controls
- full dump resend only after single-edit tests are stable
