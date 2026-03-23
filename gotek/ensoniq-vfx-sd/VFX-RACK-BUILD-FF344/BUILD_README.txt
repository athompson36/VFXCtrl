Ensoniq VFX-SD Gotek — FlashFloppy 3.44 indexed rack (friendly names, no DSKA prefix)

Folder: VFX-RACK-BUILD-FF344 (canonical in repo). You may copy the same tree to e.g. ~/Documents/VFX-RACK-BUILD-FF344/ for prep.

Slots: 164 (0000 … 0163)

Naming: indexed-prefix = "" in FF.CFG → disk files MUST be:
  0000_VFX_SD_OS_2.10.IMG
  0001_Stock_Library_Disk.IMG
  0002_ATW_Colorado_alogdig.HFE
  …

Regenerate / refresh from catalog rules + FF.CFG:
  python3 tools/apply_vfx_rack_friendly_indexed_names.py gotek/ensoniq-vfx-sd/VFX-RACK-BUILD-FF344

Catalog (reference only, not for Gotek): VFX_RACK_CATALOG.json, .md, .csv, DUPLICATES_REPORT.md

DEPLOY to FAT32 MBR USB root — copy ONLY:
  cp 000* FF.CFG /Volumes/GOTEK/
  sync

Do NOT copy to the stick:
  IMAGE_A.CFG
  IMG.CFG
  *.json, *.md, *.csv, *.txt (except you are not copying those as payloads)
  ._* (AppleDouble), .DS_Store
  *.upd (use Firmware wizard separately; only ONE .upd on root if updating)

FF.CFG is tuned for: interface=shugart, host=ensoniq, nav-mode=indexed, indexed-prefix="",
  pin34=ready, display-type=auto, image-on-startup=init, motor-delay=200, autoselect-file-secs=2.
  FlashFloppy 3.x uses autoselect-file-secs (seconds), not autoselect-file=yes.

If step-delay is rejected by an older parser, remove that line from FF.CFG.

Firmware (.upd) bundled next to this folder for convenience — do not deploy both .upd types at once (E02).

Design reference: docs/GOTEK_INDEXED_RACK.md
