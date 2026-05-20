# PCGen Flutter Port — Implementation Notes

Running log of design decisions, tradeoffs, and non-obvious choices made during the port of Java PCGen 6.09.08 to Flutter/Dart.

---

## Architecture overview

**Goal:** Full compatibility with Java PCGen data files (LST/PCC) and save files (PCG) while providing a modern Flutter desktop UI.

**Key tradeoff:** Rather than translating every Java class directly (PCGen Java codebase is ~500k LOC), we identify the data-flow paths that matter for the character sheet and implement only those. Stubs return safe defaults for unused paths.

---

## Data model

### `_data` map vs typed fields (`CharacterFacadeImpl`)

**Decision:** Store all character data in a single `Map<String, dynamic> _data` rather than typed fields.

**Why:** The PCG save/load format and the FTL token API both ultimately need a serialisable map. Using a live map means `toJson()` is free (returns `_data` directly) and the FTL engine can read any field via `_data('key')` without explicit getters for every token. Typed fields would require parallel serialisation code.

**Tradeoff:** Loses compile-time type safety inside the map. Mitigated by `_str()`, `_int()` etc. helper getters that cast with safe defaults.

### `selectedAbilities: Map<String, List<String>>`

**Decision:** Store abilities/feats as `{categoryName: [keyName, ...]}` rather than full objects.

**Why:** The PCG format stores `ABILITY:FEAT|CATEGORY:FEAT|KEY:PowerAttack|...` — the category and key are all that's needed for display. Full objects would require dataset lookups at load time, which can fail if sources aren't loaded. The stored key is used to look up the full dataset object at render time when the dataset is available.

**Tradeoff:** DESC/BENEFIT require a dataset lookup at render time. Fallback: the PCG `ABILITY:` line includes `DESC:` which we cache in `abilityDescs` for offline rendering.

### `equippedSlots: Map<String, String>` + `carriedItems: List<String>`

**Decision:** Separate body-slot equipped items (map) from unslotted carried items (list).

**Why:** A single `equippedSlots['Carried'] = key` would overwrite on second carried item. PCGen supports multiple carried items — Java uses a list of EQUIPSET entries. Our separation mirrors that without the full EQUIPSET tree complexity.

**PCG compatibility:** Write back uses the Java EQUIPSET format (0.1.XX ID tree, Equipped/body slot names) so files round-trip correctly with Java PCGen.

---

## LST loading

### `GenericLoader<T>` — single-pass line parser

**Decision:** One loader class handles all object types (Ability, Skill, Equipment, Race, etc.) via a `switch` on the LST token name. Each token maps to a `ListKey`, `StringKey`, `IntegerKey`, or `CDOMObjectKey` and is stored on the CDOM object.

**Why:** PCGen has dozens of object types but their LST syntax is nearly identical — `TOKENNAME:value|TOKENNAME2:value2`. A generic parser avoids per-type boilerplate and makes it easy to add new tokens.

**Tradeoff:** Unknown tokens silently no-op. This is intentional — PCGen LST files contain hundreds of tokens we don't need for basic display.

### `CLASS:` prefix stripping in `PCClassLoader`

**Decision:** `parseLine()` strips the `CLASS:Bard` prefix from the first field and sets the key to `Bard`.

**Why (critical bug):** The Java format uses `CLASS:Bard` as the first token on a class definition line. Our initial loader stored the key as `"CLASS:Bard"`. Characters store class references as `"Bard"`. This meant no class bonuses were ever collected → BAB=0 for every character. Discovered by tracing the bonus accumulator with a multi-class character.

### Multi-line continuation for PCClass

**Decision:** `_currentClass` instance variable persists the current class across continuation lines. `parseLine()` always returns the current class (never null for continuation lines).

**Why:** PCGen class LST files use continuation lines (lines without `CLASS:` prefix) to add more tokens to the same class. Early implementation returned null on continuation, resetting the target.

---

## Bonus engine

### `BonusAccumulator` — per-source-key REPLACE buckets

**Decision:** `add(sourceKey: classKey)` appends the class name to the REPLACE type key, making each class's REPLACE bonuses independent: `Base.REPLACE.Fighter` vs `Base.REPLACE.Rogue`.

**Why:** All class BAB formulas use `TYPE=Base.REPLACE`. Standard REPLACE semantics take the maximum — so only the highest-level class's BAB would count. PCGen's actual Java behaviour stacks REPLACE bonuses from different sources. Our approach gives the same result without implementing PCGen's full stacking-group logic.

**Tradeoff:** REPLACE bonuses from the same source (e.g., two feats both granting `TYPE=Dodge.REPLACE` AC) still compete correctly because they share a source key. Only cross-source stacking is affected.

### `totalOfType(cat, target, type)` for AC components

**Decision:** Added to `BonusAccumulator` to sum bonuses of a specific named type (e.g. `NATURALARMOR`, `SHIELD`, `DEFLECTION`) for AC breakdown display.

**Why:** The FTL sheet shows AC components separately. We need `NATURALARMOR` bonus isolated from `ARMOR` bonus. The accumulator already tracks all bonuses; `totalOfType` just filters.

---

## FTL template engine

### Dart re-implementation of FreeMarker subset

**Decision:** Implement the FreeMarker subset used by PCGen sheets in pure Dart (`ftl_engine.dart`). No Java interop, no Dart FFI to Freemarker Java library.

**Why:** FreeMarker is a Java library. Flutter desktop targets don't have JVM access. The PCGen sheets use a small subset of FreeMarker (`#if`, `#list`, `@loop`, `#assign`, `#macro`, `#include`, arithmetic, string builtins). A targeted Dart implementation is feasible and keeps the app self-contained.

**Tradeoff:** FreeMarker edge cases and rarely-used directives may not be supported. We handle only what the actual PCGen sheet templates require. Unknown directives are silently skipped.

### `FtlWidgetSink` — HTML → Flutter widgets without intermediate HTML string

**Decision:** On desktop, the FTL engine writes directly to `FtlWidgetSink` which builds Flutter widgets character-by-character. No HTML string is generated.

**Why:** On mobile (Android/iOS) we use a WebView, which needs an HTML string. On desktop, a WebView requires a real browser process and can't be embedded. Native Flutter widgets are lighter and integrate naturally. The same FTL engine can target either sink.

**Tradeoff:** The HTML→widget parser must handle the same broken/quirky HTML that browsers tolerate. Every edge case we encounter in the PCGen templates requires a fix in `FtlWidgetSink`.

### CSS class parsing from `<head><style>` block

**Decision:** The `<head>` block is NOT skipped — we capture `<style>` content and parse CSS class selectors (`.className { ... }`).

**Why (critical bug):** Early implementation skipped `<head>` with `_mode = _Mode.skip`. The PCGen Standard.htm.ftl defines all font, border, and colour classes in `<head><style>`. Skipping it meant all CSS classes resolved to defaults — cells had wrong fonts, no borders, wrong colours.

**Fix:** Treat `<html>`, `<head>`, `<body>` as no-ops (not skip). Only `<style>` triggers CSS capture mode.

### HTML table implicit close (`<tr>` auto-close)

**Decision:** When a new `<tr>` is opened, any currently open `_RowB` on the stack is automatically closed first. Similarly for `<td>`/`<th>` (closes open `_CellB`), `</tr>` closes open `_CellB` first, `</table>` unwinds all open rows.

**Why (critical bug):** The PCGen Standard.htm.ftl feat table has this structure per loop iteration:
```html
<tr>   ← name row
  <td>name</td><td>source</td>
<tr>   ← bare tr (no close)
<tr>   ← desc row
  <td>desc</td></tr>
<tr>   ← benefit row
  <td>benefit</td></tr>
```
That's 4 `<tr>` opens, 2 `</tr>` closes. Browsers auto-close the previous `<tr>` when a new one starts. Our renderer accumulated 12+ unclosed `_RowB` nodes on the stack. `_TableB` never received any rows → returned null → feat table invisible.

**Tradeoff:** The auto-close logic must not cross table boundaries (don't close a `_RowB` from an outer table when processing an inner table's `<tr>`). We use type checks (`_top is _RowB`, `_top is _TableB`) to stop at the right level.

### `PcgenTokenContext` — FreeMarker function bridge

**Decision:** `PcgenTokenContext` implements `FtlContext` and dispatches `pcstring(token)` / `pcvar(token)` / `pcboolean(token)` to the PCGen token resolver. All token logic lives in `pcgen_token_api.dart`; the FTL engine only knows about context functions.

**Why:** Clean separation of template evaluation from PCGen data access. The same FTL engine could work with any context.

---

## PCGen token API

### Token dispatcher — `switch(parts[0])`

**Decision:** Split the token on `.` and dispatch on `parts[0]`. Nested tokens (e.g. `STAT.0.MOD`, `WEAPON.3.TOTALHIT`) delegate to sub-methods.

**Why:** PCGen's export token namespace is hierarchical: the first word identifies the category (STAT, WEAPON, SKILL, etc.), subsequent parts identify index and field. A single switch handles all top-level categories efficiently.

**Tradeoff:** Tokens with spaces (e.g. `FOLLOWERTYPE.ANIMAL COMPANION.0.NAME`) split incorrectly at the space. We work around this by searching for the first numeric part as the index separator rather than assuming a fixed position.

### `countdistinct()` arithmetic suffix handling

**Decision:** The FTL template passes `countdistinct("ABILITIES","CATEGORY=FEAT",...)-1` as a single string to `pcvar()`. We strip the `-1` suffix (after the last `)`) before parsing the count function.

**Why:** The FTL expression `pcvar('countdistinct(...)-1')` has the arithmetic inside the string argument to `pcvar`. Our `_resolve()` receives the whole string. Without suffix handling, the count returned is N instead of N-1, causing the loop to run one extra iteration with an out-of-bounds index.

### `countdistinct()` TYPE= filter for ability categories

**Decision:** `countdistinct("ABILITIES","CATEGORY=Special Ability","TYPE=SpecialAttack",...)` is handled by a general handler that extracts CATEGORY=, TYPE=, and ASPECT= filters in sequence.

**Why:** The Standard.htm.ftl has ~20 distinct ability sections (SpecialAttack, SpecialQuality, RacialTrait, ClassFeature, Condition, NaturalAttack, ChannelingOutput, etc.), each using countdistinct with different TYPE= values. Hard-coding each category would be unmaintainable. The general handler handles all of them.

**Tradeoff:** TYPE= filter requires a dataset lookup per ability to read its type list. For characters with many abilities this could be slow. In practice PCGen characters have tens of abilities, not thousands, so it's acceptable.

### `EQ.Not.Coin.NOT.Gem` vs `EQUIP`

**Decision:** Both `EQ` and `EQUIP` dispatch to `_equipItem()`. The numeric index is found by scanning parts for the first parseable integer rather than assuming a fixed position.

**Why (critical bug):** The Standard.htm.ftl equipment table uses `EQ.Not.Coin.NOT.Gem.0.NAME` format. Our dispatcher only handled `EQUIP`. All equipment tokens returned `''`, making the entire equipment section blank. Fixed by adding `case 'EQ':` alongside `case 'EQUIP':`.

### `ABILITYALL.X.DESC` fallback to `abilityDescs`

**Decision:** When the dataset doesn't have a description for an ability, fall back to the `DESC:` text captured from the PCG `ABILITY:` line.

**Why:** PCGen saves the description inline in the PCG file: `ABILITY:FEAT|...|DESC:text`. The dataset object also has the description. We try dataset first (canonical), fall back to PCG line (always available even if dataset not loaded or desc not in LST).

### `WEIGHT.LIGHT/MEDIUM/HEAVY` — STR-based encumbrance

**Decision:** Approximate carry limits as `STR × 3.33 / 6.67 / 10` lbs. STR score approximated from `getStatModByAbb('STR') × 2 + 10`.

**Why:** The d20 encumbrance table (PHB p162) is non-linear for extreme STR values. For typical play (STR 8–22), the linear approximation is accurate. Implementing the full lookup table adds complexity with minimal real-world benefit.

**Tradeoff:** STR > 22 or < 1 will be slightly wrong. Acceptable for a character sheet display.

---

## PCG save/load

### Java-compatible EQUIPSET tree

**Decision:** Write equipment as the standard PCGen EQUIPSET tree: root node `0.1`, equipped body-slot items as `0.1.01`, `0.1.02`, etc., with standard slot names (`Equipped`, `Carried`, `Armor`, `Primary Hand`, etc.).

**Why:** Early implementation invented a `LOCATION:` token which Java PCGen doesn't understand. Java PCGen uses a hierarchical EQUIPSET with specific ID patterns. Files must round-trip correctly so users can switch between the Flutter port and Java PCGen.

### `ABILITY:` lines — all categories stored

**Decision:** `_readAbility()` stores every ABILITY: line's key under its CATEGORY, not just feats.

**Why:** The template renders many ability categories (Special Ability, Regional, Internal, etc.). Storing all categories means `_abilitiesForCat('Special Ability')` etc. work without special-casing each one.

### Biographical fields — previously ignored

**Decision:** `PERSONALITYTRAIT1/2`, `SPEECHPATTERN`, `PHOBIAS`, `INTERESTS`, `CATCHPHRASE` are now stored from the PCG file rather than being dropped.

**Why:** These fields were explicitly listed as `break; // explicitly ignored` in the early parser. The FTL template outputs PERSONALITY1, CATCHPHRASE etc. on the character sheet. Fixing the parser was a one-liner per field.

---

## Rendering decisions

### Three-path table rendering in `FtlWidgetSink`

**Decision:** Tables use one of three paths:
1. **Flutter `Table` widget** — balanced tables with no colspan/rowspan or percentage widths
2. **Flex rows** — tables with percentage widths (`width="20%"`) or colspan/rowspan
3. **Col-0 rowspan special case** — leftmost cell spans rows (used in stat block layout)

**Why:** Flutter's `Table` widget requires all rows to have the same number of cells and doesn't support colspan/rowspan. Percentage-width cells need flex sizing. The flex path handles these but is more complex to build.

### `_InlineStyle` stack for text properties

**Decision:** Inline text properties (color, font size, weight, style, decoration) are pushed/popped in a stack as `<font>`, `<b>`, `<span>` tags open/close.

**Why:** PCGen sheets use nested inline formatting extensively. A stack correctly handles nesting and lets the innermost style override the outer while restoring the correct state on close.

### `display:none` cells preserved as `SizedBox.shrink()`

**Decision:** Cells with `display:none` CSS produce a `SizedBox.shrink()` cell that preserves table structure (correct column count) but takes no space.

**Why:** Some PCGen sheet sections conditionally hide cells (EPIC stats, etc.) via `display:none`. Dropping the cell entirely would shift all subsequent columns left, breaking alignment. A zero-size placeholder preserves the column slot.

### `_hasPercentWidths` routes to flex path

**Decision:** Tables where any cell has a percentage width (`width="20%"`) automatically use the flex path.

**Why:** The stat block table (`STAT.N.NAME/SCORE/MOD` etc.) uses five equal `width="20%"` columns. Flutter's `Table` widget ignores width hints from HTML and would size columns by content, making the ABILITY NAME column much wider than the SCORE columns. Flex path gives equal widths.

---

## Build log of notable decisions

| Build | Decision |
|-------|----------|
| 080 | Stop skipping `<head>` — needed for CSS `<style>` capture |
| 081 | `valign`, `cellpadding`, `display:none` support; fix color inheritance in cells |
| 082 | `_hasPercentWidths` → flex path; `hiddenCols` eliminates EPIC column waste |
| 083 | Full CSS property coverage: padding, margin, line-height, opacity, white-space, border-radius |
| 084 | `<blockquote>`, `<u>`, `<sup>`, `<sub>`, CSS `#id` selectors, `<font size="N">` |
| 085 | AC components (NATURALARMOR, SHIELD, DEFLECTION, DODGE, SIZE), SPELLFAILURE, MAXDEX, HASVAR, CLASSSK, ACPv, `totalOfType()` |
| 086 | Full spell system; `<input type="checkbox">` → ☐; PLUS enhancement bonus synthesis |
| 087 | Fix operator precedence: `?? -1 >= 0` → `((x as num?)?.toInt() ?? -1) >= 0` |
| 088 | Fix spell caster level (class own levels + prestige bonus); case-insensitive ability category lookup; DESC/BENEFIT from dataset; ASPECT values from ASPECT_LIST |
| 089 | Fix regex raw string: `r'aspect=([^,"\']+)'` has literal `\'` terminating string → `r'aspect=([^,"]+)'` |
| 090 | `<tr>` auto-close (browser implicit behavior); countdistinct arithmetic suffix; DESC falls back to PCG abilityDescs |
| 091 | `case 'EQ':` missing from dispatcher → equipment blank; LOCATION/CHARGES/CHECKBOXES fields; TOTAL.WEIGHT/VALUE; `<td>`/`<th>` auto-close |
| 092 | Fix `</td>` to unwind inner block elements before closing cell; separate `</tr>` from `</p>`/`</div>` close handler (they incorrectly shared a body); `</ul>` closes open `<li>` first |
| 093 | Biographical tokens (DESC, PERSONALITY1/2, CATCHPHRASE, SPEECHTENDENCY, INTERESTS, PHOBIAS, RESIDENCE); WEIGHT.LIGHT/MEDIUM/HEAVY encumbrance; GOLD.TRUNC; NOTE, TEMPBONUS, SPECIALABILITY, SPECIALLIST, PROHIBITEDLIST, ABILITYLIST, FOLLOWERTYPE, EQTYPE tokens; COUNT[SA/TEMPBONUSNAMES]; countdistinct generalised with CATEGORY+TYPE+ASPECT filters |

---

## Known limitations and future work

- **`ADDSPELLLEVEL` on feats** — increases caster level for specific spell lists; not yet implemented
- **`SERVESAS:RACE`** — PF2e race alternate matching; stub
- **`LoadContext` reset** — switching campaigns of the same game mode mid-session may leave stale data
- **Encumbrance limits** — linear approximation; exact for STR 1–22, slightly off for extremes
- **Companion stats** — `FOLLOWERTYPE` returns from `companions` list in `_data`; full companion character objects not implemented
- **Temp bonus restoration** — active temp bonuses from save file are loaded but not re-evaluated on character reload
- **EQTYPE filter** — gear type matching is substring-based; may over-match for some type names
- **FTL** — `#switch`, `#recover`, `#attempt`, `?api` builtins not implemented (not used in PCGen sheets)
