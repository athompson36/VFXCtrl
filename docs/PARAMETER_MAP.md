# Parameter Catalog and Address Map

This file is intentionally split into a **parameter inventory** and an **address table**.

The inventory is comprehensive enough to drive UI design now.
The address table only marks fields as verified when proven.

## Legend

- status = `verified`
- status = `inferred`
- status = `unknown`

## Program parameter inventory

### Wave page
- patch name
- voice/layer select
- waveform / transwave select
- octave
- coarse tune
- fine tune
- output level
- velocity sensitivity
- key tracking
- stereo placement / pan if available

### Motion page
- transwave start/position
- scan amount
- scan source
- LFO 1 rate
- LFO 1 depth
- LFO 2 rate
- mod wheel amount
- aftertouch amount

### Filter page
- cutoff
- resonance
- filter env amount
- keyboard tracking
- velocity to filter
- envelope source / routing where applicable

### Amp page
- attack
- decay
- sustain
- release
- velocity to amp
- scaling / key tracking if applicable

### Mod page
- source 1
- destination 1
- depth 1
- source 2
- destination 2
- depth 2
- pedal amount
- pressure amount

### Performance page
- split point
- layer balance
- detune/spread
- key zones
- velocity zones
- mono/poly mode if patch-scoped
- transpose
- patch volume offsets

### Sequencer page
- play
- stop
- record
- continue
- locate / song select if supported
- tempo
- tap tempo derivation in app
- track/multi recall if supported

### FX page
- effect select if patch-scoped
- effect wet/dry
- delay time
- feedback
- chorus depth/rate
- reverb amount/type if exposed

## Address table

| UI Group | Parameter | Address / Offset | Status | Evidence |
|---|---|---:|---|---|
| Wave | waveform / transwave select | TBD | unknown | original spec or capture needed |
| Wave | coarse tune | TBD | unknown | original spec or capture needed |
| Wave | fine tune | TBD | unknown | original spec or capture needed |
| Wave | level | TBD | unknown | original spec or capture needed |
| Motion | scan amount | TBD | unknown | original spec or capture needed |
| Motion | LFO rate | TBD | unknown | original spec or capture needed |
| Motion | LFO depth | TBD | unknown | original spec or capture needed |
| Filter | cutoff | TBD | unknown | original spec or capture needed |
| Filter | resonance | TBD | unknown | original spec or capture needed |
| Filter | env amount | TBD | unknown | original spec or capture needed |
| Amp | attack | TBD | unknown | original spec or capture needed |
| Amp | decay | TBD | unknown | original spec or capture needed |
| Amp | sustain | TBD | unknown | original spec or capture needed |
| Amp | release | TBD | unknown | original spec or capture needed |
| Performance | split point | TBD | unknown | original spec or capture needed |
| Performance | balance | TBD | unknown | original spec or capture needed |
| FX | FX parameters | TBD | unknown | original spec or capture needed |
| Sequencer | transport / tempo | TBD | unknown | original spec or capture needed |

## How to fill this in

1. Capture a baseline program dump.
2. Change one parameter on the synth.
3. Capture again.
4. Diff the payloads.
5. Confirm the changed byte with at least two more values.
6. Mark status = verified.
