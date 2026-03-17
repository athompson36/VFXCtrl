#!/usr/bin/env python3
from pathlib import Path
import csv

rows = [
    ["page", "parameter", "address", "status", "notes"],
    ["Wave", "wave.select", "", "unknown", "Needs verification"],
    ["Filter", "filter.cutoff", "", "unknown", "Needs verification"],
    ["Amp", "amp.attack", "", "unknown", "Needs verification"],
    ["Sequencer", "seq.tempo", "", "unknown", "Needs verification"],
    ["FX", "fx.mix", "", "unknown", "Needs verification"],
]

out = Path('data/parameter_map_template.csv')
out.parent.mkdir(parents=True, exist_ok=True)
with out.open('w', newline='') as f:
    writer = csv.writer(f)
    writer.writerows(rows)
print(out)
