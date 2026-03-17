# Macro Knob Mapping

Each macro drives one or more parameters. Mappings are **inferred** for UI consistency; real SysEx addresses are TBD.

| Macro     | Primary target      | Secondary / notes        |
|-----------|---------------------|--------------------------|
| Brightness| filter.cutoff        | filter.resonance (value/4) |
| Motion    | motion.amount        | lfo1.depth (value/2)     |
| Weight    | amp.level            | amp.attack (inverse)     |
| Attack    | amp.attack           | amp.decay (+20)          |
| Space     | fx.mix               | fx.feedback               |
| Width     | wave.pan             | perf.detune              |
| Dirt      | filter.cutoff (add)  | filter.env               |
| Animate   | lfo1.rate            | lfo2.rate                |

When parameter addresses are verified, single-parameter or multi-parameter SysEx edits can be sent from the macro handlers.
