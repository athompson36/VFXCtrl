# Troubleshooting

## Current focus: Live Master Volume does not change the synth

**Symptom:** With Live enabled on the System page, moving the Master Vol slider no longer freezes the app (pinwheel fixed), but the VFX-SD’s volume does not change.

**Cause:** The SysEx message we send is built from an **unverified format**. The address (and possibly command/checksum) does not match what the VFX-SD expects, so it ignores the message.

**What we send (current):** `F0 0F 05 01 00 05 00 00 [value] F7`  
- Header: Ensoniq `F0 0F`, model `05`, sub-id `01`, device `00`, command `05` (Parameter Change Request, from Fizmo/MR docs).  
- Address: `00 00` (placeholder).  
- Value: 0–127.  
- No checksum in current implementation.

**References:**
- **SysEx/MIDI research and byte layout:** `docs/SYSEX_RESEARCH_FINDINGS.md`
- **Live parameter design and requirements:** `docs/LIVE_PARAMETER_RESEARCH.md`
- **Spec status and live message:** `docs/VFX_SYSEX_SPEC.md`
- **Code:** `src/midi/LiveSysExBuilder.swift` — update `buildMasterVolume` when the real format is known.

**Next steps:**
1. Get the real format from the VFX or VFX-SD manual PDF (e.g. VFX Musician’s Manual p.144 “Message Format”, or Appendix A) and update `LiveSysExBuilder.buildMasterVolume` to match.
2. Or capture SysEx from Midi Quest while moving master volume, compare with our “Live SysEx TX” log (enable “Debug: Live logging” on System page), and copy the exact bytes into `buildMasterVolume`.

---

## Resolved: Pinwheel / freeze when adjusting Live Master Vol

**Was:** App pinwheeled when moving the Master Vol slider with Live on.

**Fixes applied:** Throttled live MIDI sends; moved SysEx send loop off the main thread (`Task.detached`); fixed `MIDISysexSendRequest` completion proc to free only our own allocations (via `SysexSendRefCon`); always publish `objectWillChange` so the slider updates; reduced work in LibrarySidebar (single `TagEngine`) and PatchListView (single `changedKeys` call); quiet send path for live so TX log doesn’t flood.

---

## Resolved: Malloc crash in SysEx completion

**Was:** `malloc: *** error for object 0x...: pointer being freed was not allocated` when sending SysEx.

**Cause:** CoreMIDI can pass a pointer to its own copy of the request into the completion proc. Freeing that pointer was invalid.

**Fix:** Store our allocated buffer and request in a small `SysexSendRefCon`; in the completion proc, use only `completionRefCon` to get that refcon, then free the data pointer, request pointer, and refcon. Never free the `request` parameter passed by CoreMIDI.
