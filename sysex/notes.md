# Capture Notes

Put your real VFX-SD capture notes here.

**Setup:** VFX-SD powered up, MIDI channel 1. Mac Studio ↔ VFX via **Roland UM-ONE** (USB–MIDI).

**Observed program dump format (from patch_dump_01.syx):**
- Start: `F0 0F 05 00 00` (SysEx start, Ensoniq 0x0F, message type 0x05)
- Payload: remaining bytes until end
- End: `F7`
- Parser uses this to validate and extract payload; name is guessed from first 16 bytes of payload if ASCII.

Suggested naming:
- baseline_current_program.syx
- cutoff_040.syx
- cutoff_080.syx
- attack_010.syx
