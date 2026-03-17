# MIDI / SysEx Timing Safety

Real-world reports indicate the VFX-SD can reject or mishandle some SysEx transfers unless timing is conservative.

## Default safe values for v1

- inter-message delay: 40 ms
- control coalescing window: 25 ms
- max burst count: 1 until verified
- replay pacing: manual / conservative

## App requirements

- user-adjustable delay
- per-device profile storage
- emergency stop for sends
- log all MIDI traffic with timestamps
- optional checksum bypass in raw-tool mode only
