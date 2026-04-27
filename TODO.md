# Flutter PCGen — TODO

Based on port audit (April 2026). ~70–75% complete. Domain model and UI framework are largely done;
the app is not yet functional because data loading is unimplemented and the character creation flow
is incomplete.

---

## Blocking: Data Loading

Nothing works end-to-end until game data can actually be read from disk.

- [x] Implement `SystemLoader` / `LstSystemLoader.loadSystemResources()` — runs `GameModeFileLoader` then `CampaignFileLoader`
- [x] Wire `app.dart` initialization to real loaders (replaced placeholder `Future.delayed` timers)
- [x] Implement `CampaignLoader.loadCampaignLstFile()` — parses all .pcc tokens, builds `CampaignSourceEntry` lists, resolves sub-campaign dependencies
- [x] Add `LstLineFileLoader.loadLstFile(dynamic, Uri)` — enables `TraitLoader`/`LocationLoader` to load via bare URI
- [x] Add trait, location, equip-slot loading to `GameModeFileLoader._loadGameModeFiles()`
- [ ] Implement `PersistenceManager` — wire up LST file I/O via the persistence/lst infrastructure
- [ ] Resolve asset paths on each platform (use `path_provider` for data directory lookup)

## Blocking: Character Creation Flow

- [x] Implement source selection dialog — `AdvancedSourceSelectionPanel` shows real campaigns from `Globals`, grouped by game mode with checkboxes and search filter
- [x] Wire Load button — calls `SourceFileLoader` with selected campaigns; dialog shows spinner and closes on completion
- [x] Wire `PCGenFrame.showSourceSelectionDialog()` to real dialog (was a stub snackbar)
- [x] Call `startPCGenFrame()` from `initState` so source selection auto-shows on launch
- [x] Implement `SourceFileLoader._collectFileEntries()` — harvests all `FILE_*` lists from selected campaigns
- [ ] Implement new-character wizard / campaign chooser
- [ ] Implement `util/chooser` — the chooser dialogs used throughout character building
  (race chooser, class chooser, feat chooser, skill allocator, etc.)

## Core Gaps

- [ ] Implement `base/calculation` — the variable/modifier calculation framework
  (may partially overlap with `formula/`; audit overlap before starting)
- [ ] Complete `formula/` — currently mostly interface stubs (~24 lines/file avg);
  flesh out solver, function evaluation, operator implementations
- [ ] Complete `util/` — only enumerations exist; add missing helpers used across the codebase
- [ ] Implement `util/fop` — XSL-FO / PDF export (or decide on a Flutter-native alternative)

## GUI

- [ ] Wire character sheet tabs to real loaded data (tabs exist but models are not populated)
- [ ] Implement preferences UI (shell exists in `gui3/`, needs actual preference binding)
- [ ] Implement source management UI (add/remove/enable sources)
- [ ] Implement kit application dialog
- [ ] Audit `gui2/` for any tabs that are structural shells without real logic

## Testing

- [ ] Add unit tests for core game mechanics (bonus calculation, prerequisite evaluation, spell slots)
- [ ] Add unit tests for LST token parsing once loaders are implemented
- [ ] Add integration tests for character create → save → load round-trip
- [ ] Expand `widget_test.dart` beyond the smoke test

## Polish / Later

- [ ] Implement character save/load (`.pcg` file format)
- [ ] Implement character export (HTML/PDF output sheets via the `output/` system)
- [ ] Platform testing: verify file I/O and asset paths work on Android and iOS
- [ ] Add error handling for missing or malformed data files
- [ ] Decide on `util/fop` strategy — port FOP, use a Dart PDF lib, or drop PDF support

---

## Done (port audit findings)

- [x] Full domain model — `cdom/`, `core/` (~95%+ coverage vs Java)
- [x] All 19 character sheet tabs — stateful Flutter widgets in `gui2/tabs/`
- [x] Facade layer — complete abstraction over game data
- [x] Output/publish system — character sheet model factories and channels
- [x] Plugin message architecture — `pluginmgr/` functional
- [x] Rules engine structure — token library, persistence registry
- [x] Logging system
- [x] Preloader splash screen with progress bar
