# VFX-SD Companion App: Capability Audit

Audit of all editor pages against VFX-SD hardware limits and `.cursor/rules/vfx-sd-capabilities.mdc`. Each page’s controls are checked for value ranges, parameter counts, and consistency with the manual and PARAMETER_MAP.md.

---

## 1. Wave (8 controls)

| Key           | UI range | Audit note |
|---------------|----------|------------|
| wave.select   | 0–127    | OK. VFX has 109 (or 141) waves; 0–127 sufficient. |
| wave.coarse   | 0–127    | OK. |
| wave.fine     | 0–127    | OK. |
| wave.octave   | 0–127    | Verify: manual may specify smaller range (e.g. ±2 oct). |
| wave.level    | 0–127    | OK. |
| wave.velocity | 0–127    | OK. |
| wave.keytrack | 0–127    | OK. |
| wave.pan      | 0–127    | OK. |

**Result:** Consistent. Optional: confirm octave range in manual and clamp if needed.

---

## 2. Motion (8 controls)

| Key              | UI range | Audit note |
|------------------|----------|------------|
| motion.position  | 0–127    | OK. |
| motion.amount    | 0–127    | OK. |
| motion.source    | 0–127    | OK. |
| lfo1.rate        | 0–127    | OK. |
| lfo1.depth       | 0–127    | OK. |
| lfo2.rate        | 0–127    | Manual states **1 LFO per voice**. Confirm whether “LFO2” is a second LFO or same LFO’s second parameter; align labels/count with manual. |
| modwheel.depth   | 0–127    | OK. |
| aftertouch.depth | 0–127    | OK. |

**Result:** Ranges OK. Documented: 1 LFO per voice; lfo1/lfo2 keys kept for layout, mapping TBD.

---

## 3. Filter (8 controls)

| Key             | UI range | Audit note |
|-----------------|----------|------------|
| filter.cutoff   | 0–127    | OK. |
| filter.resonance| 0–127    | OK. |
| filter.env      | 0–127    | OK. |
| filter.velocity | 0–127    | OK. |
| filter.keytrack | 0–127    | OK. |
| filter.mode     | 0–127    | OK. |
| filter.source   | 0–127    | OK. |
| filter.alt      | 0–127    | OK. |

**Result:** Consistent.

---

## 4. Amp (8 controls)

| Key          | UI range | Audit note |
|--------------|----------|------------|
| amp.attack   | 0–127    | OK. |
| amp.decay    | 0–127    | OK. |
| amp.sustain  | 0–127    | OK. |
| amp.release  | 0–127    | OK. |
| amp.velocity | 0–127    | OK. |
| amp.level    | 0–127    | OK. |
| amp.keyscale | 0–127    | OK. |
| amp.alt      | 0–127    | OK. |

**Result:** Consistent.

---

## 5. Mod (routing + global amounts)

| Item | Current implementation | VFX-SD rule | Audit result |
|------|------------------------|-------------|--------------|
| Routing | **2 slots** (ModTwoSlotView): mod.src1, mod.dest1, mod.depth1, mod.src2, mod.dest2, mod.depth2; source 0–14, dest 0–9, depth 0–127. | **2 slots only**: Src1→Dest1 (Depth1), Src2→Dest2 (Depth2). Canonical keys. | **OK.** |
| Pedal   | mod.pedal 0–127. | Global amount. | OK. |
| Pressure| mod.pressure 0–127. | Global amount. | OK. |

**Result:** Mod page uses 2-slot UI and canonical keys; compliant with capability rule.

---

## 6. Performance (8 controls)

| Key           | UI range | Audit note |
|---------------|----------|------------|
| perf.split    | 0–127    | OK (key number). |
| perf.balance  | 0–127    | OK. |
| perf.detune   | 0–127    | OK. |
| perf.zonelow  | 0–127    | OK. |
| perf.zonehigh | 0–127    | OK. |
| perf.vellow   | 0–127    | OK. |
| perf.velhigh  | 0–127    | OK. |
| perf.transpose| 0–127    | OK. |

**Result:** Consistent. Optional: document preset = 3 programs if we expose program/layer count.

---

## 7. Sequencer (sub-pages)

| Parameter / key   | UI range / type      | Doc range (VFX_SEQUENCER_SYSEX) | Audit note |
|------------------|----------------------|----------------------------------|------------|
| seq.tempo        | 1–300 (TextField)    | 1–300                            | OK. |
| seq.clockSource  | 0/1 (Picker)         | Internal/MIDI                     | OK. |
| seq.song         | 1–60 (Picker)        | 1–60                             | **Range OK.** Issue: loadPatch defaults missing keys to **0**; 0 is outside 1–60. Picker uses `default: 1` in getter, so display shows 1 but stored value can be 0. |
| seq.sequence     | 1–60 (Picker)        | 1–60                             | Same as seq.song: default 0 on load, should be 1. |
| seq.track        | 1–24 (Picker)        | 1–24                             | Same: default 0 on load, should be 1. |
| seq.quant        | 0–6 (Picker)         | preset list                      | OK. |
| seq.loop         | 0/1 (Toggle)         | on/off                           | OK. |
| seq.click        | 0/1 (Toggle)         | on/off                           | OK. |
| seq.punchIn      | 0–999                | 0–999                            | OK. |
| seq.punchOut     | 0–999                | 0–999                            | OK. |

**Result:** Sequencer ranges match docs. Fix: ensure seq.song, seq.sequence, seq.track default to **1** (not 0) when loading a patch so stored value is always in valid range.

---

## 8. FX (8 controls)

| Key     | UI range | Audit note |
|---------|----------|------------|
| fx.type | 0–127    | OK. VFX has 15 effects; 0–127 covers. |
| fx.mix  | 0–127    | OK. |
| fx.time | 0–127    | OK. |
| fx.feedback | 0–127 | OK. |
| fx.depth| 0–127    | OK. |
| fx.rate | 0–127    | OK. |
| fx.tone | 0–127    | OK. |
| fx.alt  | 0–127    | OK. |

**Result:** Consistent.

---

## 9. Macro (8 controls)

| Key             | UI range | Audit note |
|-----------------|----------|------------|
| macro.brightness| 0–127    | OK. Maps to filter. |
| macro.motion    | 0–127    | OK. |
| macro.weight    | 0–127    | OK. |
| macro.attack    | 0–127    | OK. |
| macro.space     | 0–127    | OK. |
| macro.width     | 0–127    | OK. |
| macro.dirt      | 0–127    | OK. |
| macro.animate   | 0–127    | OK. |

**Result:** Consistent.

---

## Cross-cutting

| Item | Audit note |
|------|------------|
| PageGrid | All pages using PageGrid use a single range **0...127**. No per-parameter range; custom views (e.g. Seq) handle other ranges. OK for now; extend only if other params need non–0–127. |
| EditorState loadPatch | Defaults any missing key to **0**. For seq.song, seq.sequence, seq.track, 0 is invalid; should default to **1**. |
| Docs | VFX_MODULATION_MATRIX.md still says “unknown: … full 15×10 vs. limited slots”. Rule and audit say 2 slots; update doc to match. |

---

## Summary

| Page    | Status   | Action |
|---------|----------|--------|
| Wave    | OK       | Optional: verify octave range. |
| Motion  | OK       | Verify LFO count (1 vs 2); align UI/docs. |
| Filter  | OK       | — |
| Amp     | OK       | — |
| **Mod** | **OK** | 2-slot UI and canonical keys implemented. |
| Perf    | OK       | Optional: document 3-program limit. |
| Seq     | OK       | Default song/sequence/track to 1 on load (done in loadPatch). |
| FX      | OK       | — |
| Macro   | OK       | — |

*\*Seq ranges correct; fix defaults only.*
