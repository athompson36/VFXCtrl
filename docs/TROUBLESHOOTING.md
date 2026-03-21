# Troubleshooting

## Resolved: Live Master Volume does not change the synth

**Was:** Moving Master Vol slider with Live on sent a wrong SysEx format that the synth ignored.

**Root cause:** We used a Fizmo/MR-guessed SysEx format (`F0 0F 05 01 00 05 00 00 [val] F7`). The VFX-SD master volume is NOT a SysEx page/slot parameter at all -- it responds to **MIDI CC 7** (Volume).

**Fix:** `LiveSysExBuilder` now sends MIDI CC 7 for `sys.masterVol` via `MIDIDeviceManager.sendCC()`. The correct format was found in the official VFX-SD MIDI Implementation Specification v2.00 (already in `docs/`). See `docs/VFX_SYSEX_SPEC.md`.

---

## Resolved: SysEx Parameter Change format was wrong

**Was:** LiveSysExBuilder used a Fizmo-inferred format (`F0 0F 05 01 00 05 [addr] [val] F7`).

**Root cause:** The correct format from the official spec is Command Type 01 with nibblized data and page/slot/voice addressing (19 bytes total). All data bytes must be nibblized (split into two 4-bit nibble bytes). See spec section 3.1.2.

**Fix:** `LiveSysExBuilder` now builds proper nibblized Parameter Change messages using the page/slot/voice model from section 5 of the spec. Over 100 parameters are mapped and support live editing.

---

## Resolved: Pinwheel / freeze when adjusting Live Master Vol

**Was:** App pinwheeled when moving the Master Vol slider with Live on.

**Fixes applied:** Throttled live MIDI sends; moved SysEx send loop off the main thread (`Task.detached`); fixed `MIDISysexSendRequest` completion proc to free only our own allocations (via `SysexSendRefCon`); always publish `objectWillChange` so the slider updates; reduced work in LibrarySidebar (single `TagEngine`) and PatchListView (single `changedKeys` call); quiet send path for live so TX log doesn't flood.

---

## Resolved: Malloc crash in SysEx completion

**Was:** `malloc: *** error for object 0x...: pointer being freed was not allocated` when sending SysEx.

**Cause:** CoreMIDI can pass a pointer to its own copy of the request into the completion proc. Freeing that pointer was invalid.

**Fix:** Store our allocated buffer and request in a small `SysexSendRefCon`; in the completion proc, use only `completionRefCon` to get that refcon, then free the data pointer, request pointer, and refcon. Never free the `request` parameter passed by CoreMIDI.
