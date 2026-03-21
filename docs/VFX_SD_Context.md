
# VFX‑SD + Gotek Context Reference

## Synth Architecture Constraints
- 6 voice polyphony
- Internal ROM waveform + Transwave set (no user waveform import)
- Patches stored in 60‑program banks
- Performance mode uses layered voices reducing polyphony
- SysEx timing sensitive — must throttle bursts

## MIDI / SysEx Notes
- Device header: F0 0F 05 <ID>
- Patch dumps large (~2–4k bytes)
- Recommend ≥20ms inter‑message delay
- Some parameters may require full patch resend

## Gotek Emulator Constraints
- HFE image format recommended
- Folder depth should remain shallow
- Indexed navigation fastest workflow
- OLED shows ~16 characters → use short disk names
- Avoid >999 images per root
- Prefer categorized root folders

## Recommended Folder Layout
00_FACTORY  
01_ROM  
02_TRANSWAVE  
03_PAD  
04_KEYS  
05_BASS  
06_LEAD  
07_SPLIT  
08_FX  
09_COMMERCIAL  
10_ARCHIVE  

## Patch Organization Strategy
Cursor should:
- Tag patches by category
- Detect duplicates via SysEx hash
- Build curated 60‑patch performance banks
- Maintain “LIVE_SET” virtual collection
- Preserve original disk source metadata

## Sequencer / FX Considerations
- Sequencer dumps separate from patch banks
- Internal FX are performance level dependent
- Tap tempo control via MIDI clock preferable

## Future Hardware Programmer Goals
- 8 encoder pages mirrored from software
- Small OLED per encoder for parameter/value
- Main OLED navigation display
- Transport + tap tempo
- Macro layer for brightness/motion/space
