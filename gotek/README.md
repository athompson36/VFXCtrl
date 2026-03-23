# gotek

Personal workspace for **Ensoniq VFX-SD** Gotek (FlashFloppy) setup: disk library, migration notes from native navigation to **indexed** mode, and vendored FlashFloppy reference files.

**Remote:** [https://github.com/athompson36/gotek](https://github.com/athompson36/gotek)

## Layout

| Path | Purpose |
|------|--------|
| [`docs/`](docs/) | Migration context, Gotek PDFs |
| [`docs/gotek-migration-context.txt`](docs/gotek-migration-context.txt) | Historical migration notes (canonical policy: parent repo `docs/GOTEK_INDEXED_RACK.md`) |
| [`ensoniq-vfx-sd/VFX-SD Backup/`](ensoniq-vfx-sd/VFX-SD%20Backup/) | VFX-SD disk images (`.HFE`, root `.img`), `FF.CFG`, `IMAGE_A.CFG` |
| [`flashfloppy/flashfloppy-3.44/`](flashfloppy/flashfloppy-3.44/) | FlashFloppy release tree (firmware hex, examples, `Host/Ensoniq/IMG.CFG`) |
| [`ensoniq-mirage/`](ensoniq-mirage/) | Separate Mirage material (not part of active VFX-SD migration) |

### Canonical rack build (in repo)

**`ensoniq-vfx-sd/VFX-RACK-BUILD-FF344/`** — FlashFloppy **3.44**, **`indexed-prefix = ""`**, files **`0000_*` … `0163_*`** (no `DSKA` on disk images). **`FF.CFG`** is tuned for **SamplerZone Gotek Extended** (34×19 mm OLED, rotary): manual mount (`autoselect-*-secs = 0`), `ejected-on-startup = yes`, `rotary = full`, readable scroll. See **`FF_CFG_CHANGELOG.md`** and parent **`docs/GOTEK_INDEXED_RACK.md`**.

**Deploy:** `cp 000* FF.CFG` to FAT32 USB root only — **do not** copy `IMG.CFG`, `IMAGE_A.CFG`, or catalogs.

### Refresh filenames + FF.CFG

From **vfx-ctrl** repo root:

```bash
python3 tools/apply_vfx_rack_friendly_indexed_names.py gotek/ensoniq-vfx-sd/VFX-RACK-BUILD-FF344
```

Legacy **`python3 gotek/scripts/build_vfx_rack.py`** may still exist for older experiments; the maintained path is the `tools/` script above.

Checklist: [`docs/VFX-SD-TODO.md`](docs/VFX-SD-TODO.md).

## Clone and push

```bash
git clone https://github.com/athompson36/gotek.git
cd gotek
```

After cloning an empty GitHub repo into this folder, or to connect this tree:

```bash
git init
git remote add origin https://github.com/athompson36/gotek.git
git branch -M main
git add .
git commit -m "Initial commit"
git push -u origin main
```

This repository is about **850 MB** (mostly disk images under `ensoniq-vfx-sd/`). Ensure Git HTTP buffer if needed: `git config --global http.postBuffer 524288000`.

## Licenses

- **`flashfloppy/flashfloppy-3.44/`** — See [`flashfloppy/flashfloppy-3.44/COPYING`](flashfloppy/flashfloppy-3.44/COPYING) (upstream FlashFloppy; includes public-domain/Unlicense portions and noted third-party exceptions).
- Disk images and project notes are personal/archival material unless otherwise marked.
