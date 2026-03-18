# Live Parameter Adjustment: Research and Requirements

What has to be true for moving a slider in the app to change the sound on the VFX-SD in real time, and what’s missing today.

---

## Troubleshooting: "Live Master Vol doesn't change the synth"

The app **does** send SysEx when you move Master Vol with Live on (enable "Debug: Live logging" on the System page and check the Xcode console for `Live SysEx TX: F0 0F 05 ...`). The synth does **not** change volume because the **message format is a placeholder**. The bytes (command, address, checksum) do not match what the VFX-SD expects.

**To get real volume control:**

1. **Get the correct format** from the VFX-SD v2.10 MIDI Specification (if you have it), or capture SysEx from software that works (e.g. Midi Quest) when you change master volume.
2. **Compare** the captured bytes with what we send (move the slider with debug on and note the `Live SysEx TX:` line).
3. **Update** `LiveSysExBuilder.buildMasterVolume` in `src/midi/LiveSysExBuilder.swift` to use the verified header, command, address, value byte(s), and checksum. See §3.1 below for what's unknown today.

---

## 1. Current state

### 1.1 What happens when you move a control

- **UI → state only.** Every control (Wave, Filter, Amp, Mod, System, etc.) calls `EditorState.set(key, value)`.
- **`EditorState.set()`** updates `controls[key]` and `currentPatch.parameters[key]`, and runs `MacroEngine` for macro keys. It does **not** call any MIDI or SysEx send.
- **No parameter → message layer.** There is no code that turns a `(key, value)` pair into a SysEx (or MIDI) message and no call to `MIDIDeviceManager.sendSysEx(_:)` from the editor.

So **no live parameter adjustment** today: the synth never receives updates when you move a slider.

### 1.2 What already exists

- **MIDI transport:** `MIDIDeviceManager` has CoreMIDI in/out, `sendSysEx(Data)`, a queue, and configurable inter-message delay (default 40 ms). Sending arbitrary SysEx is supported.
- **Patch model:** `VFXPatch.parameters` is `[String: Int]` (e.g. `"filter.cutoff"` → 0–127). Keys match UI and docs.
- **Program dump parsing (partial):** `PatchParser` assumes header `F0 0F 05 ... F7` (Ensoniq 0x0F; model byte 0x05). It does **not** map logical keys to payload offsets; it only stores `raw.0`, `raw.1`, … for the first 256 payload bytes. Checksum is not implemented.
- **Parameter map:** `ParameterMap.swift` has a few sample parameters, all with `address: nil`. No byte offset or real-time message format is defined.
- **Docs:** `VFX_SYSEX_SPEC.md` states that *parameter-addressed real-time edit messages* and exact layouts are **not verified**. `PARAMETER_RESEARCH_WORKFLOW.md` describes dump-based and real-time mapping procedures. `DEVELOPMENT_PLAN.md` Phase 3.3 calls out: “On control change: send real-time SysEx edit (when address verified).”

So the **intent** and **transport** are there; the **message format and key→message wiring** are missing.

---

## 2. How the synth could receive parameter changes

Two main approaches:

### 2.1 Real-time single-parameter SysEx (preferred if supported)

The synth may support a **short SysEx message** that sets one parameter by address, e.g.:

- **Structure (Ensoniq-style, from MR/SQ docs and similar):**  
  `F0` (SysEx) `0F` (Ensoniq) `…` (model/device) `…` (command/address bytes) `value` `checksum?` `F7`.
- **Need from spec or capture:**
  - Exact header after `F0 0F` (model, device ID, “real-time edit” command/sub-id).
  - **Address encoding:** one or more bytes that uniquely identify the parameter (e.g. offset into program/preset memory, or a logical param ID).
  - **Value:** usually one byte (0–127) or two (MSB/LSB) for 14-bit.
  - **Checksum:** algorithm (e.g. XOR of data bytes, or sum & 0x7F, etc.) and which bytes are included.

**Source of truth:** The **VFX-SD v2.10 MIDI Specification** (referenced on Gearspace and elsewhere) is the right place for this. Until that or a capture is available, real-time single-parameter format remains **unknown**.

### 2.2 Full program dump on each change (fallback)

- **Idea:** On every control change, (1) build a full “current program” dump from `currentPatch.parameters` (and any fixed header/padding), (2) send that whole dump to the synth.
- **Pros:** Works as long as the **program dump format** is known (layout + checksum); no separate “real-time edit” spec needed.
- **Cons:** Large messages (~2 KB per program reported), slow (40 ms+ between messages, so rapid slider moves would queue many dumps), and risk of glitches or overload. Best used for “Send” on demand or occasional sync, not for every slider tick.

So **live** feel really wants **2.1**; **2.2** is a fallback once dump layout is verified.

---

## 3. What must be known and built

### 3.1 Message format (real-time path)

| Item | Status | How to get it |
|------|--------|----------------|
| Manufacturer + model header | Partial | Parser uses `F0 0F 05`; confirm with dump capture and/or v2.10 spec. |
| “Real-time parameter” command / sub-id | Unknown | v2.10 spec or test with known-good editor (e.g. Midi Quest) and capture. |
| Address size and encoding | Unknown | Spec, or infer from program dump layout (param offset → same offset in real-time message?). |
| Value size (7-bit vs 14-bit) | Inferred | Most params 0–127 → one byte. |
| Checksum algorithm | Unknown | v2.10 spec or reverse from captures (compare multiple messages). |
| Per-parameter addresses | Unknown | One address per logical parameter (e.g. master vol, filter cutoff); build from spec or dump diff. |

### 3.2 Program dump layout (for fallback or for inferring addresses)

| Item | Status | How to get it |
|------|--------|----------------|
| Full header (after F0 0F 05) | Partial | Capture “Current Program” from synth; compare with parser. |
| Payload layout (offsets per parameter) | Unknown | Dump-based workflow: baseline dump, change one param, dump again, diff (`tools/vfx_sysex_inspector.py`); repeat for many params. |
| Checksum (position and formula) | Unknown | Same as 3.1. |
| Name / fixed fields | Partial | Parser has a simple name extract; refine with layout. |

### 3.3 App-side components to implement

Once a format is known (either real-time or full dump):

1. **Address map**  
   - **Real-time:** For each `key` used by the UI, store the byte(s) that form the parameter address (and, if needed, which message type/sub-id).  
   - **Full dump:** For each `key`, store the byte offset (and length) in the program payload.  
   - Store in code (e.g. `ParameterMap` or a dedicated `ParameterAddressMap`) and/or in a data file; keep `PARAMETER_MAP.md` / `docs/` in sync.

2. **Checksum**  
   - One function that takes the relevant bytes (per spec) and returns the checksum byte.  
   - Use when **building** any SysEx (real-time or full dump).  
   - Optionally use when **parsing** dumps (already stubbed in `PatchParser`).

3. **Message builder(s)**  
   - **Real-time:** `buildRealTimeEdit(key: String, value: Int) -> Data?` using header + address map + value + checksum.  
   - **Full dump:** `buildProgramDump(from patch: VFXPatch) -> Data?` using header + payload layout from `patch.parameters` (and raw bytes where no key exists) + checksum.  
   - Both must respect the same timing as today (single message per “event” if needed, no burst without testing).

4. **When to send**  
   - **Option A (eager):** In `EditorState.set(key:value:)`, after updating state, look up address for `key`; if found, build message and call `sendSysEx`.  
   - **Option B (UI layer):** Each control’s `set` closure calls `editor.set(...)` and then a separate “send if live” service (e.g. `LiveParameterSender.send(key, value)`).  
   - **Coalescing:** For sliders, consider sending at most every N ms or on release to avoid flooding; queue already has inter-message delay.

5. **Configuration**  
   - “Live edit” on/off (so sliders only update state when disabled).  
   - Choice of “real-time” vs “full dump” if both are implemented.  
   - Use existing `interMessageDelayMs`; consider a separate (stricter) delay for real-time edits if the synth is sensitive.

6. **System vs program scope**  
   - **Program parameters** (wave, filter, amp, mod, etc.) are per patch; real-time edits usually apply to the “current” program on the synth.  
   - **System parameters** (master volume, MIDI base channel, etc.) are global; they may use a **different** SysEx message type or a different “memory” space.  
   - Document which keys are program vs system and which message type/address range each uses.

---

## 4. Research and verification steps (concise)

1. **Obtain v2.10 MIDI Spec**  
   - Get the official (or community) VFX-SD v2.10 MIDI / SysEx document.  
   - Extract: real-time parameter edit message format, address table (or rules), checksum.  
   - If not available, treat “real-time edit” as unsupported until proven by capture.

2. **Capture and diff program dumps**  
   - Follow `PARAMETER_RESEARCH_WORKFLOW.md`: baseline “Current Program” dump, change one parameter (e.g. filter cutoff), dump again, diff with `tools/vfx_sysex_inspector.py`.  
   - Repeat for a set of parameters (wave, filter, amp, mod, system if in same dump) to build an offset table.  
   - Confirm checksum byte(s) and algorithm by varying one byte and checking synth accept/reject or error.

3. **Confirm real-time edit support**  
   - If the spec describes a “parameter change” or “real-time edit” message: build one by hand (e.g. for master volume or filter cutoff), send with 40 ms delay, observe synth.  
   - Alternatively, use an editor that already does live edit (e.g. Midi Quest), capture the SysEx it sends when you move one slider, and reverse the format.

4. **Document and implement**  
   - Add a small “SysEx message reference” doc (or section in `VFX_SYSEX_SPEC.md`) with: header, real-time format (if any), checksum, and a few example addresses.  
   - Implement address map, checksum, and one builder (real-time or full dump).  
   - Wire sends from `EditorState.set` or from a dedicated sender, with live-edit toggle and coalescing if needed.

---

## 5. Dependencies and ordering

- **Live parameter adjustment** depends on:
  1. A **verified** message format (real-time and/or full dump) and **checksum**.
  2. An **address map** from app keys to that format (offsets or real-time addresses).
  3. **Message builder(s)** and a **send path** from parameter changes to `MIDIDeviceManager.sendSysEx`.
  4. **Configuration** (live on/off, delay, optional coalescing).

- **No hard-coded parameter address** should be treated as authoritative until it comes from the spec or from repeated capture/diff (per `VFX_SYSEX_SPEC.md` and the development plan).

- **System parameters** (e.g. master volume) may live in a different SysEx “block” or message type than program parameters; they need to be researched and mapped the same way (spec or capture).

---

## 6. Summary

- **Today:** Sliders only update app state; nothing is sent to the synth.  
- **To get live parameter adjustment:**  
  - Resolve **message format** (real-time single-parameter and/or full program dump) and **checksum** via v2.10 spec or capture/diff.  
  - Build an **address map** (key → address/offset) and **message builder(s)**.  
  - **Send** the resulting SysEx from a parameter-change path (e.g. inside or alongside `EditorState.set`), with live-edit toggle and existing throttling.  
- **System vs program:** Treat system parameters (e.g. master volume) explicitly; they may use different message types or addresses and must be researched and implemented accordingly.

This document can be updated as the v2.10 spec is obtained, captures are analyzed, and real-time or full-dump formats are verified and implemented.
