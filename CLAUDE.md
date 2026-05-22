# Flutter PCGen — Claude Code Instructions

## Project

Flutter/Dart desktop port of Java PCGen 6.09.08 (open-source tabletop RPG character manager).
- **Repo:** github.com/david-allan-finch/flutter_pcgen (git, branch: master)
- **Working dir:** `/home/david/Projects/pcgen/flutter_pcgen`
- **Java PCGen source** (for reference): `/home/david/Projects/pcgen/pcgen`
- **Java PCGen characters** (example PCG files): `/home/david/Projects/pcgen/characters`
- **Primary platform:** Windows desktop (David tests there); Linux dev machine
- **Owner:** David Allan

## Standard Procedures

### Before starting work
- Always run `git status` to check the actual repo state — never assume from session metadata.

### After making changes
1. Run `dart analyze` — fix any new errors before committing.
2. Increment `kBuildNumber` in `lib/src/version.dart`.
3. Commit with message format: `Build NNN: short description of what changed`
4. Push immediately after committing.

### Commit message format
```
Build 156: use native PREVIEWVAR format and show session changes in history

One paragraph explaining the why, not the what.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

### Never do
- Silence stub debug messages by returning `'0'`, removing prints, or suppressing errors.
  Stubs exist to reveal missing data — implement the feature or leave the stub visible.
- Skip `dart analyze` before committing.
- Commit without incrementing the build number.

## Architecture

```
lib/src/
  gui2/
    tabs/               — Tab panels (summary, skills, spells, history, …)
    csheet/
      html_sheet_panel.dart     — Active sheet: FTL → FtlWidgetSink → Flutter widgets
      ftl_widget_renderer.dart  — Converts FTL output to native Flutter widgets
    facade/
      character_facade_impl.dart — Main character model (source of truth)
    app_state.dart      — Global ValueNotifiers (currentCharacter, loadedDataSet)
  io/
    pcg_character_io.dart       — PCG v2 save/load (Java PCGen compatible)
    freemarker/
      ftl_engine.dart           — FreeMarker template engine
      pcgen_token_api.dart      — Token resolution (STAT.N, WEAPON.N.TOHIT, etc.)
  persistence/lst/              — LST file parsers (GenericLoader<T>, PCClassLoader, …)
  rules/                        — Bonus engine (ParsedBonus, BonusAccumulator, FormulaEvaluator)
  core/                         — Domain objects (PCClass, PCStat, PCSkill, …)

preview/d20/fantasy/            — FTL character sheet templates
  Standard.htm.ftl              — Main sheet template
  common/common-spells.ftl      — Spell section (included by Standard)
system/gameModes/               — Game mode definitions (35e, Pathfinder, 5e, …)
characters/                     — Example PCG character files for testing
```

## Key Facts

### Character sheet rendering path
`HtmlSheetPanel` → FTL engine → `PcgenTokenContext` → `FtlWidgetSink` → Flutter widgets.
`CharacterSheetPanel` is dead code — not imported anywhere, ignore it.

### PCG file format
Java PCGen v2 format. Our Flutter extensions use `FLUTTERPCG_` prefix (ignored by Java PCGen).
Sheet input variables (HP, spell slots, ammo checkboxes) use the native Java tag:
```
PREVIEWVAR:key|value
```
This matches `IOConstants.TAG_PREVIEWSHEETVAR` in Java's `PCGVer2Creator/PCGVer2Parser`.

### Version / build number
```dart
// lib/src/version.dart
const int kBuildNumber = 156;   // increment on every commit
const int kVersionMajor = 7;
const int kVersionMinor = 0;
const String kVersionQualifier = 'alpha';
```

### Bonus accumulator
BAB and attack bonuses come from `BonusAccumulator`, not hardcoded formulas.
`getBABInt()` = `_bonusAcc.totalInt('COMBAT', 'BASEAB')`.
`STAT.N.SCORE` → `getEffectiveScore()` (includes BONUS:STAT bonuses).
`STAT.N.NOTEMP` / `NOEQUIP` → `getScoreBase()` (base score only, no bonuses).

### Skill visibility
PCGen VISIBLE flag on skills:
- `VISIBLE:YES` — show everywhere
- `VISIBLE:DISPLAY` — GUI tabs only, not on the export/sheet
- `VISIBLE:EXPORT` — sheet/print only, not in GUI tabs
- `VISIBLE:NO` — hide everywhere

### Stat abbreviation lookup
`_abbToStatKey` map in `CharacterFacadeImpl` maps abbreviation (`'STR'`) → full stat key name.
Populated in `rebuildBonuses()` from dataset stats' `getAbb()`.

### Java PCGen reference
When investigating how Java PCGen handles something, look in:
- `/home/david/Projects/pcgen/pcgen/code/src/java/pcgen/io/` — PCG read/write
- `/home/david/Projects/pcgen/pcgen/code/src/java/pcgen/io/IOConstants.java` — all tag names
- `/home/david/Projects/pcgen/pcgen/code/src/java/pcgen/gui2/csheet/` — sheet panel/JS bridge
- `/home/david/Projects/pcgen/pcgen/code/src/java/pcgen/core/` — core domain objects
