# Future Hardware Controller Concept

## User requirements carried forward

- small OLED for each knob
- larger main OLED display
- navigation encoder and buttons
- full sequencer control with transport and tap tempo
- internal FX control

## Recommended control surface

- 8 endless encoders with push switch
- 8 mini OLEDs, one per encoder
- 1 main OLED, approx 2.4 to 3.5 inch
- 1 navigation encoder with push
- 6 to 9 page buttons
- dedicated transport buttons: Play, Stop, Record, Continue, Tap
- Shift, Compare, Store, Snapshot buttons

## Recommended system split

### Prototype hardware
- USB to Mac companion first
- hardware acts as HID/MIDI controller
- Mac app handles verified SysEx translation

### Standalone later
- MCU or SBC emits SysEx directly
- library/snapshots stored locally
- optional USB host for future integrations

## Candidate electronics

- main brain: Raspberry Pi CM4 / Pi Zero 2 W or Teensy + helper MCU
- mini OLEDs: 0.42 to 0.49 inch monochrome OLEDs per encoder
- main display: larger monochrome or grayscale OLED
- encoders: detented endless with push
- transport: tactile or low-profile mechanical buttons

## Risk notes

Per-knob OLED wiring, refresh budget, and UI bandwidth should be prototyped in software first.
