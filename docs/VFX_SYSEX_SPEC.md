# VFX-SD SysEx / MIDI Notes

## Verified from currently reviewed public sources

### Publicly supported categories
The VFX-SD exposes SysEx workflows for at least:

- current program send
- internal program banks send
- current preset send
- internal preset banks send
- sequencer-related dumps
- receiving SysEx dumps when SysEx reception is enabled

These categories are visible in the public VFX-SD and SD-1 manuals and in current Sound Quest product documentation.

## What is NOT yet verified in this repo

- exact manufacturer / model byte layout for each message
- exact program dump layout
- exact bank dump layout
- exact parameter-addressed real-time edit messages
- exact checksum rules
- exact message types for sequencer transport or FX changes

## Engineering stance

This repo separates message definitions into:

- `verified`: observed in a real capture or original spec
- `inferred`: plausible, but not yet capture-proven
- `unknown`: placeholder only

## Working assumptions for implementation

1. The app must support raw SysEx capture and replay.
2. The app must permit custom message templates during reverse engineering.
3. No hard-coded parameter address should be treated as authoritative until verified.

## Safe transport rules

- throttle outbound SysEx
- support adjustable inter-message delay
- support single-message mode
- log every send and receive event
- support replay from capture files
