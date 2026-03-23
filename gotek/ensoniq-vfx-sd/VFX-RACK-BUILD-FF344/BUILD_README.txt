Ensoniq VFX-SD Gotek — FlashFloppy 3.44 indexed rack (SamplerZone Gotek Extended OLED)

Folder: VFX-RACK-BUILD-FF344 (canonical in repo). You may copy the same tree to e.g. ~/Documents/VFX-RACK-BUILD-FF344/ for prep.

Hardware reference: SamplerZone Gotek Extended — 34×19 mm display, rotary encoder standard.
Product: https://samplerzone.com/products/gotek-extended-floppy-emulator

Slots: 164 (0000 … 0163)

Naming: indexed-prefix = "" in FF.CFG → disk files MUST be:
  0000_VFX_SD_OS_2.10.IMG
  0001_Stock_Library_Disk.IMG
  0002_ATW_Colorado_alogdig.HFE
  …

Regenerate / refresh from catalog rules + FF.CFG:
  python3 tools/apply_vfx_rack_friendly_indexed_names.py gotek/ensoniq-vfx-sd/VFX-RACK-BUILD-FF344

Catalog (reference only, not for Gotek): VFX_RACK_CATALOG.json, .md, .csv, DUPLICATES_REPORT.md
FF.CFG history: FF_CFG_CHANGELOG.md

DEPLOY to FAT32 MBR USB root — copy ONLY:
  cp 000* FF.CFG /Volumes/GOTEK/
  sync

Do NOT copy to the stick:
  IMAGE_A.CFG
  IMG.CFG
  *.json, *.md, *.csv, *.txt (except you are not copying those as payloads)
  ._* (AppleDouble), .DS_Store
  *.upd (use Firmware wizard separately; only ONE .upd on root if updating)

FF.CFG summary (FF 3.44 wiki keys only):
  interface=shugart, host=ensoniq, nav-mode=indexed, indexed-prefix="",
  pin34=ready, rotary=full,reverse, oled-font=8x16, autoselect-file-secs=0, autoselect-folder-secs=0,
  ejected-on-startup=no, image-on-startup=init,
  display-type=oled-128x64, display-order=0d,7,1, display-off-secs=255,
  display-scroll-rate=400, display-scroll-pause=1800 (milliseconds).

There is NO autoselect-file= or display-nav-name= in official FlashFloppy — use autoselect-*-secs and display-order.

If step-delay is rejected by an older parser, remove that line from FF.CFG.

Firmware (.upd) bundled next to this folder for convenience — do not deploy both .upd types at once (E02).

Design reference: docs/GOTEK_INDEXED_RACK.md
