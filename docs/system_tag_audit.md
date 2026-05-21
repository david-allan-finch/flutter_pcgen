# PCGen System File Tag Audit

**Dart port vs Java PCGen 6.09.08 — all 20 game modes**  
**Generated: 2026-05-21**

Game modes audited: 35e, 3e, 5e, Darwins_World_2, Deadlands, default, Fantasy_Craft,
Gaslight, Immortal, Killshot, Modern, OSRIC, Pathfinder, Pathfinder_2, Pathfinder_PFS,
Sagaborn, Sidewinder, Spycraft, Starfinder, zen_test.

Dart status key:
- **IMPLEMENTED** — case present, value stored and used
- **STORED** — case present, value stored in GameMode but not yet consumed by any UI/engine logic
- **PARTIAL** — case present but subtoken parsing is incomplete or has a known bug
- **STUB** — code path exists but is a no-op (break or comment)
- **NOT LOADED** — no case in the loader; data silently dropped
- **BUG** — handler exists but has a defect that prevents correct operation

---

## 1. `miscinfo.lst`

**Loader:** `lib/src/persistence/lst/game_mode_loader.dart` → `_applyMiscToken()`  
**Orchestrator:** `lib/src/persistence/game_mode_file_loader.dart` → `_loadGameModeMiscInfo()`

| Tag | Format (example) | Modes | Java behaviour | Dart status | Notes |
|-----|-----------------|-------|----------------|-------------|-------|
| `ABILITYCATEGORY` | `ABILITYCATEGORY:FEAT VISIBLE:YES EDITABLE:YES EDITPOOL:YES CATEGORY:FEAT PLURAL:Feats DISPLAYLOCATION:Feats` | all | Registers a game-mode-level AbilityCategory (e.g. FEAT, Internal, Natural Attack) | IMPLEMENTED | Delegates to `AbilityCategoryLoader`; full sub-token parsing |
| `ACFORMULA` | `ACFORMULA:10+DEX` | 35e, Pathfinder | Sets the AC calculation formula string on GameMode | STORED | Stored via `setACFormula()`; not consumed by AC calc engine |
| `ACNAME` | `ACNAME:Armor Class` | all | Sets the label shown for the AC field in the UI | STORED | Stored via `setACName()` |
| `ACTYPE` | `ACTYPE:Total ADD:TOTAL` `ACTYPE:Flatfooted ADD:TOTAL REMOVE:Ability\|… REMOVE:Dodge\|…` | all | Defines named AC breakdown types with lists of bonus types to add and remove; used by the Java AC calculation engine | STORED | `_parseACType()` strips PRE conditions from ADD/REMOVE type lists; stored in `_acTypes` map; not yet wired into Dart AC calculation |
| `ALLOWEDMODES` | `ALLOWEDMODES:35e\|DnD\|LoE` | all | Pipe-delimited set of mode keys accepted by this game mode | IMPLEMENTED | Stored in `allowedModes`; used when selecting game mode for a campaign |
| `ALTHPABBREV` | `ALTHPABBREV:VP` | some | Abbreviation for the alternate HP pool (Vitality/Wound variant) | STORED | Stored via `setALTHPAbbrev()` |
| `ALTHPNAME` | `ALTHPNAME:Vitality Points` | some | Full name for the alternate HP pool | STORED | Stored via `setALTHPName()` |
| `BABATTCYC` | `BABATTCYC:5` | 35e, 5e, Pathfinder | BAB cycle: one extra attack per N BAB points | STORED | Stored via `setBabAttCyc()`; not yet used in attack generation |
| `BABMAXATT` | `BABMAXATT:4` | 35e, 5e, Pathfinder | Maximum number of BAB-derived iterative attacks | STORED | Stored via `setBabMaxAtt()` |
| `BABMINVAL` | `BABMINVAL:1` | 35e, 5e, Pathfinder | Minimum BAB value required to grant an extra attack | STORED | Stored via `setBabMinVal()` |
| `BASEDICE` | `BASEDICE:1d6 UP:2d6,3d6,4d6 DOWN:1d6` | all | Weapon damage die progression table for size-change calculations | STORED | Raw lines appended to `_baseDice` list; no parsed structure; not consumed by equipment resizing |
| `BONUSFEATLEVEL` | *(deprecated)* | old modes | Deprecated alias — see `BONUSFEATLEVELSTARTINTERVAL` | STORED | `setBonusFeatLevels()` |
| `BONUSFEATLEVELSTARTINTERVAL` | `BONUSFEATLEVELSTARTINTERVAL:3\|3` | all | First level + interval for bonus feat grants (modern form) | NOT LOADED | No case in `_applyMiscToken()`; falls to `default: break` |
| `BONUSSTACKS` | `BONUSSTACKS:Defense.Dodge.Circumstance.NotRanged.NotFlatFooted` | all | Dot-delimited bonus types that stack rather than use best-of | STORED | Stored via `setBonusStacks()`; not consumed by bonus accumulator |
| `BONUSSTATLEVEL` | *(deprecated)* | old modes | Deprecated alias — see `BONUSSTATLEVELSTARTINTERVAL` | STORED | `setBonusStatLevels()` |
| `BONUSSTATLEVELSTARTINTERVAL` | `BONUSSTATLEVELSTARTINTERVAL:4\|4` | all | Level + interval for ability score increases (modern form) | NOT LOADED | No case; falls to `default: break` |
| `CHARACTERTYPE` | `CHARACTERTYPE:PC\|NPC\|Monster` | all | Pipe-delimited valid character types for this game mode | STORED | Stored in `_characterTypes2` list |
| `CLASSTYPE` | `CLASSTYPE:PC CRFORMULA:CL ISMONSTER:NO XPPENALTY:YES CRMOD:0 CRMODPRIORITY:1` | all | Defines class types (PC, NPC, Monster, Prestige, Companion) with CR formula and XP penalty flags | STORED | Full `_parseClassType()` with all sub-tokens; stored in `_classTypes`; not yet consumed by class picker |
| `CRSTEPS` | `CRSTEPS:1/2` | 35e, 5e, Pathfinder | Fractional CR step list for XP math | NOT LOADED | Falls to `default: break` |
| `CRTHRESHOLD` | `CRTHRESHOLD:HD` | all | Method used to calculate CR threshold vs monster HD | STORED | Stored via `setCRThreshold()` |
| `CURRENCYUNIT` | `CURRENCYUNIT:Gold Piece` | some | Full name of the currency (display) | STORED | Stored via `setCurrencyUnit()` |
| `CURRENCYUNITABBREV` | `CURRENCYUNITABBREV:gp` | all | Currency abbreviation shown in the UI | STORED | Stored via `setCurrencyUnitAbbrev()` |
| `DAMAGERES` | `DAMAGERES:DR` | 35e, Pathfinder | Label for the damage resistance display field | STORED | Stored via `setDamageResistanceText()` |
| `DEFAULTDATASET` | `DEFAULTDATASET:3.5 RSRD` | 35e | Default source dataset to load with this game mode | STORED | Stored via `setDefaultDataset()` |
| `DEFAULTSPELLBOOK` | `DEFAULTSPELLBOOK:Wizard's Spellbook` | 35e, Pathfinder | Name of the default spellbook granted to arcane spellcasters | STORED | Stored via `setDefaultSpellBook()` |
| `DEFAULTUNITSET` | `DEFAULTUNITSET:Imperial` | all | Name of the UNITSET to use by default | IMPLEMENTED | Stored via `setDefaultUnitSet()`; used by `getUnitSet()` |
| `DEITY` | `DEITY:Deity` | 35e, Pathfinder | UI label for the deity selection field | STORED | Stored via `setDeityTerm()` |
| `DIESIZES` | `DIESIZES:1,2,3,MIN=4,6,8,10,MAX=12,20,100,1000` | all | Valid die sizes for HITDIE bumping; `MIN=n` and `MAX=n` mark the soft/hard caps | BUG | `int.tryParse("MIN=4")` returns null — the MIN= and MAX= cap markers are silently dropped; array stored without them |
| `DISPLAYNAME` | `DISPLAYNAME:3.5 Edition` | some | Human-readable name shown in the campaign selector | IMPLEMENTED | Stored via `setDisplayName()`; shown in the game mode menu |
| `DISPLAYORDER` | `DISPLAYORDER:1` | all | Sort position in the game mode menu | IMPLEMENTED | Stored via `setDisplayOrder()`; used by `sortGameModeList()` |
| `EQSIZEPENALTY` | `EQSIZEPENALTY:35 Size Penalty BONUS:WEAPON\|TOHIT\|…` | 35e | Named equipment size penalty with inline BONUS tokens applied to all weapons | NOT LOADED | Falls to `default: break`; complex — requires inline BONUS evaluation |
| `GAMEMODEKEY` | `GAMEMODEKEY:Pathfinder_RPG` | Pathfinder, Pathfinder_2, Pathfinder_PFS, FantasyCraft, Sagaborn, Starfinder | Provides an alternate key for cross-referencing this game mode from PCC files (the directory name is not always the reference key) | NOT LOADED | No case; falls to `default: break`; affects PCC `GAMEMODE:` lookups |
| `HPABBREV` | `HPABBREV:HP` | all | Abbreviation shown for the hit point field | STORED | Stored via `setHPAbbrev()` |
| `HPNAME` | `HPNAME:Hit Points` | all | Full label for the HP field | STORED | Stored via `setHPName()` |
| `INFOSHEET` | `INFOSHEET:SUMMARY\|preview/summary/35e_info.html.ftl` | all | Maps info sheet type key to its Freemarker template path | STORED | Stored in `_infoSheets` map |
| `LEVELMSG` | `LEVELMSG:Congratulations, you can advance…` | all | Message shown when the character can level up | STORED | Stored via `setLevelUpMessage()` |
| `MAXNONEPICLEVEL` | `MAXNONEPICLEVEL:19` | 35e | Highest level considered non-epic | NOT LOADED | `GameMode._maxNonEpicLevel` field exists but no case in loader |
| `MENUENTRY` | `MENUENTRY:3.5e` | all | Label in the Settings → Campaign menu | IMPLEMENTED | Stored via `setMenuEntry()`; displayed in game mode selector |
| `MONSTERROLEDEFAULT` | `MONSTERROLEDEFAULT:Combat` | 35e, 5e, Pathfinder | Default monster role used when creating monsters | NOT LOADED | Falls to explicit `break` |
| `MONSTERROLES` | `MONSTERROLES:Combat\|Skill\|Bard\|…` | 35e, 5e, Pathfinder | Pipe-delimited list of monster role options for the monster creation dialog | NOT LOADED | Falls to explicit `break` |
| `MOVEFORMULA` | `MOVEFORMULA:…` | some | Formula for computing movement rate | STORED | Stored via `setMoveFormula()` |
| `OUTPUTSHEET` | `OUTPUTSHEET:DEFAULT.PDF\|csheet_fantasy_std_blue.xslt` | all | Maps output sheet type key to template path | STORED | Stored in `_outputSheets` map |
| `PLUSCOST` | `PLUSCOST:WEAPON\|2000*PLUS*PLUS` | Pathfinder, Pathfinder_2, Pathfinder_PFS, FantasyCraft | Formula for magic item enhancement cost by equipment type; pipe: `TYPE\|formula` | NOT LOADED | No case; falls to `default: break`; affects magic item pricing |
| `PREVIEWDIR` | `PREVIEWDIR:d20/fantasy` | all | Base directory for preview sheet templates | STORED | Stored via `setPreviewDir()` |
| `PREVIEWSHEET` | `PREVIEWSHEET:Standard.htm.ftl` | all | Default preview sheet filename | STORED | Stored via `setPreviewSheet()` |
| `RANKMODFORMULA` | `RANKMODFORMULA:…` | some | Formula for the cross-class skill rank modifier | STORED | Stored via `setRankModFormula()` |
| `RANGEPENALTY` | `RANGEPENALTY:-2` | all | Per-range-increment attack penalty | STORED | Stored via `setRangePenalty()` |
| `RESIZABLEEQUIPTYPE` | `RESIZABLEEQUIPTYPE:Shield\|Weapon\|Armor\|Ammunition\|Resizable` | all | Pipe-delimited equipment types that auto-resize for non-Medium characters | STORED | Stored in `_resizableEquipTypes` list |
| `ROLLFORMULA` | `ROLLFORMULA:4d6drop1` | some | Custom dice roll formula for non-standard modes | STORED | Stored via `setRollFormula()` |
| `ROLLHP` | `ROLLHP:1` | some | Whether HP is rolled (1) or fixed at max (0) | STORED | Stored via `setRollHP()` |
| `ROLLMETHOD` | `ROLLMETHOD:4d6 drop lowest SORTKEY:A3 METHOD:roll(4,6,top(3))` | all | Named dice-rolling method with sort key and formula for character creation | IMPLEMENTED | `_parseRollMethod()` stores name + sortKey + method formula in `_rollMethods` list; **previously had duplicate case bug (fixed)** |
| `SHORTRANGE` | `SHORTRANGE:30` | 35e, Pathfinder | Short-range distance in feet | BUG | Loader has `case 'SHORTRANGEDISTANCE':` but file uses `SHORTRANGE:` — the case never fires; distance always uses the field default |
| `SKILLCOST_CLASS` | `SKILLCOST_CLASS:1` | all | Cost in skill points to purchase one rank in a class skill | NOT LOADED | Field exists in GameMode but no case in loader |
| `SKILLCOST_CROSSCLASS` | `SKILLCOST_CROSSCLASS:2` | all | Cost to purchase one rank in a cross-class skill | NOT LOADED | Same |
| `SKILLCOST_EXCLUSIVE` | `SKILLCOST_EXCLUSIVE:0` | all | Cost to purchase one rank in an exclusive (trained-only) skill | NOT LOADED | Same |
| `SKILLMULTIPLIER` | `SKILLMULTIPLIER:4` | all | Skill point multiplier at level 1 (or at specified levels) | PARTIAL | `addSkillMultiplierLevel()` stores raw string; `getSkillMultiplierForLevel()` has a TODO and does not evaluate the stored strings |
| `SPELLBASECONCENTRATION` | `SPELLBASECONCENTRATION:10+SPELLLEVEL+CS` | 35e, Starfinder | Formula for concentration check DC | STORED | Stored via `setSpellBaseConcentration()` |
| `SPELLBASEDC` | `SPELLBASEDC:10+SPELLLEVEL+BASESPELLSTAT` | all | Default spell save DC formula | STORED | Stored via `setSpellBaseDC()` |
| `SPELLRANGE` | `SPELLRANGE:CLOSE\|floor(CASTERLEVEL/2)*5+25` | all | Named spell range formula; format `NAME\|formula` | STORED | Stored in `spellRangeMap` via `addSpellRange()` |
| `SQUARESIZE` | `SQUARESIZE:5` | all | Size of a battle-map square in feet | STORED | Stored via `setSquareSize()` |
| `STATMAX` | `STATMAX:18` | all | Maximum allowed ability score (base) | STORED | Stored via `setStatMax()` |
| `STATMIN` | `STATMIN:3` | all | Minimum allowed ability score | STORED | Stored via `setStatMin()` |
| `TAB` | `TAB:SKILLS NAME:in_skills VISIBLE:NO CONTEXT:tabpages\tabskills.html` | all | Defines a UI tab with localised label key, visibility, and help-context HTML path | PARTIAL | `_parseTab()` reads VISIBLE subtoken and stores per-tab visibility; NAME (localised label key) and CONTEXT (HTML page path) are discarded |
| `TABNAME` | `TABNAME:…` | old modes | Older single tab name tag | STORED | Stored via `setTabName()` |
| `UNITSET` | `UNITSET:Imperial HEIGHTUNIT:ftin HEIGHTFACTOR:1 HEIGHTPATTERN:# DISTANCEUNIT:ft. DISTANCEFACTOR:1 DISTANCEPATTERN:#.## WEIGHTUNIT:lbs. WEIGHTFACTOR:1 WEIGHTPATTERN:#.##` | all | Defines a measurement unit system with all nine formatting parameters | IMPLEMENTED | Full `_parseUnitSet()` with all nine sub-tokens; stored in `_unitSets` map |
| `WEAPONCATEGORY` | `WEAPONCATEGORY:Simple` | all | Registers a weapon proficiency category name | STORED | Stored in `_weaponCategoryNames` |
| `WEAPONNONPROFPENALTY` | `WEAPONNONPROFPENALTY:-4` | all | Attack roll penalty for non-proficiency | STUB | Explicit `break`; no field on GameMode; penalty is not applied |
| `WEAPONREACH` | `WEAPONREACH:(RACEREACH+(max(0,REACH-5)))*REACHMULT` | all | Formula for computing weapon reach | STORED | Stored via `setWeaponReachFormula()` |
| `WEAPONTYPE` | `WEAPONTYPE:Bludgeoning\|B` | all | Weapon damage type name + abbreviation; format `Name\|Abbrev` | STORED | Stored in `_weaponTypeAbbrev2` map |
| `WIELDCATEGORY` | `WIELDCATEGORY:Light HANDS:1 FINESSABLE:Yes SIZEDIFF:-1` | all | Weapon wield category — base definition (HANDS/FINESSABLE/SIZEDIFF) or progression (UP/DOWN/SWITCH) | STORED | Full `_parseWieldCategory()` for base and progression lines; stored in `_wieldCategoryDefs`; SWITCH conditions stored as raw strings, not evaluated |
| `XPAWARD` | `XPAWARD:1/8=50\|1/4=100\|1=400\|2=600\|…` | Pathfinder, Pathfinder_2, Pathfinder_PFS, FantasyCraft, Sagaborn | CR → XP award lookup table; format `CR=XP\|CR=XP\|…` where CR may be a fraction | NOT LOADED | No case; falls to `default: break` |
| `XPENABLED` | `XPENABLED:YES` | all | Whether XP tracking is active for this game mode | IMPLEMENTED | Stored via `setXPEnabled()`; checked when adding XP |

---

## 2. `statsandchecks.lst`

**Loader:** `lib/src/persistence/lst/stats_and_checks_loader.dart`

Each line: first-column token identifies the object type, remaining tab-delimited tokens are sub-tokens applied via a dispatcher stub.

| Tag | Format | Modes | Java behaviour | Dart status | Notes |
|-----|--------|-------|----------------|-------------|-------|
| `BONUSSPELLLEVEL` | `BONUSSPELLLEVEL:1 BASESTATSCORE:12 STATRANGE:8` | 35e, 3e, Pathfinder | Defines bonus spell slots per ability score; BASESTATSCORE = minimum score for 1 bonus slot, STATRANGE = score range per additional slot | PARTIAL | `BonusSpellInfo` object created and name registered; sub-tokens `BASESTATSCORE` and `STATRANGE` are NOT dispatched — only the object shell exists |
| `STATNAME` | `STATNAME:STR ABB:STR STATMOD:floor(SCORE/2)-5 DEFINE:… BONUS:…` | old modes only | Deprecated — defines an ability score with all sub-tokens (ABB, STATMOD, DEFINE, BONUS, etc.) | PARTIAL | `PCStat` created and name registered; all sub-tokens dropped |
| `CHECKNAME` | `CHECKNAME:Fortitude ABB:Fort BONUS:…` | old modes only | Deprecated — defines a saving throw | PARTIAL | `PCCheck` created and name registered; all sub-tokens dropped |
| `ALIGNMENTNAME` | `ALIGNMENTNAME:Lawful Good ABB:LG` | old modes only | Deprecated — defines an alignment value | PARTIAL | `PCAlignment` created and name registered; all sub-tokens dropped |

**Note:** 35e and 5e put their STAT/SAVE/ALIGNMENT data in data-level LST files loaded via `STAT:`, `SAVE:`, `ALIGNMENT:` PCC tags, not in `statsandchecks.lst`. The `statsandchecks.lst` in 35e only contains `BONUSSPELLLEVEL` rows.

---

## 3. `level.lst`

**Loader:** `lib/src/persistence/lst/level_loader.dart`

| Tag | Format | Modes | Java behaviour | Dart status | Notes |
|-----|--------|-------|----------------|-------------|-------|
| `XPTABLE` | `XPTABLE:Default` | all | Names a new XP table; allows multiple tracks (Fast/Medium/Slow) | IMPLEMENTED | Stored in GameMode XP table map |
| `LEVEL` | `LEVEL:1` or `LEVEL:LEVEL` | all | Level number or formula for the row | IMPLEMENTED | Stored as string; `LEVEL:LEVEL` is the formula-style row used by 35e |
| `MINXP` | `MINXP:0` or `MINXP:(LEVEL*LEVEL-LEVEL)*500` | all | Minimum XP to reach this level; may be a formula | IMPLEMENTED | Stored as string; formula evaluation deferred to runtime |
| `MAXCLASSSKILLRANK` | `MAXCLASSSKILLRANK:LEVEL+3` | 5e, some | Max class skill rank formula | IMPLEMENTED | Stored as string |
| `MAXCROSSSKILLRANK` | `MAXCROSSSKILLRANK:(LEVEL+3)/2` | 5e, some | Max cross-class skill rank formula | IMPLEMENTED | Stored as string |
| `CSKILLMAX` | `CSKILLMAX:LEVEL+ClassSkillMax+3` | 35e, 3e, Pathfinder | Alias for `MAXCLASSSKILLRANK` used in formula-row style | NOT LOADED | No case in `level_loader.dart`; max skill ranks never set for 35e |
| `CCSKILLMAX` | `CCSKILLMAX:(LEVEL+CrossClassSkillMax+3)/2` | 35e, 3e, Pathfinder | Alias for `MAXCROSSSKILLRANK` used in formula-row style | NOT LOADED | Same |

**Critical:** 35e uses `CSKILLMAX`/`CCSKILLMAX` on a single formula row; the loader only knows `MAXCLASSSKILLRANK`/`MAXCROSSSKILLRANK`. Max skill rank data is never loaded for 35e.

---

## 4. `load.lst`

**Loader:** `lib/src/persistence/lst/load_info_loader.dart`

| Tag | Format | Modes | Java behaviour | Dart status | Notes |
|-----|--------|-------|----------------|-------------|-------|
| `SIZEMULT` | `SIZEMULT:F\|0.125` | all | Size abbreviation → carrying capacity multiplier; format `Abbrev\|factor` | BUG | Case `'SIZEMULT'` is in the switch but the switch iterates all tab-delimited fields — there is no `SIZEMULT:` top-level line; the file has `SIZEMULT:F\|0.125` as full-line tokens and they ARE matched. However the stored key is the size code not a structured object — the data is stored but not usable as a size→multiplier lookup |
| `LOAD` | `LOAD:1\|10` | all | STR score → maximum carry weight lookup table; format `STRscore\|pounds` | NOT LOADED | No case for `'LOAD'` in the switch; entire carrying capacity table is ignored |
| `LOADMULT` | `LOADMULT:4` | all | Multiplier applied to loads above STR 29 | BUG | Loader has `case 'LOADMULTIPLIER'` (wrong key — file uses `LOADMULT`) — never matches |
| `ENCUMBRANCE` | `ENCUMBRANCE:Light\|1/3\|\|0` | all | Encumbrance category name, fraction-of-max-load, speed modifier, skill penalty | NOT LOADED | No case for `'ENCUMBRANCE'`; all load categories are silently dropped |

**Critical:** The `load.lst` is effectively useless. `LOAD` table and `ENCUMBRANCE` categories are never stored. `LOADMULT` has a key mismatch. The entire encumbrance system has no data backing it.

---

## 5. `sizeAdjustment.lst`

**Loader:** `lib/src/persistence/lst/size_adjustment_loader.dart`

The 35e and 5e files are nearly empty (comment-only). The `zen_test` mode has a complete implementation showing the full format.

| Tag | Format | Modes | Java behaviour | Dart status | Notes |
|-----|--------|-------|----------------|-------------|-------|
| `SIZENAME` | `SIZENAME:M ABB:M DISPLAYNAME:Medium ISDEFAULTSIZE:Y SIZENUM:050` | zen_test, others | First-column key — names and registers the size category | BUG | Loader reads `fields[0]` as the name but does not strip the `SIZENAME:` prefix; `SizeAdjustment` is registered with key `"SIZENAME:M"` not `"M"` |
| `ABB` | `ABB:M` | zen_test | One-letter size abbreviation | NOT LOADED | Token dispatch is `// TODO`; never applied |
| `DISPLAYNAME` | `DISPLAYNAME:Medium` | zen_test | Human-readable size name | NOT LOADED | Same TODO |
| `ISDEFAULTSIZE` | `ISDEFAULTSIZE:Y` | zen_test | Marks this size as the default for new characters | NOT LOADED | Same TODO |
| `SIZENUM` | `SIZENUM:050` | zen_test | Numeric sort key (used as integer comparison for size relationships) | NOT LOADED | Same TODO |
| `BONUS` | `BONUS:COMBAT\|AC\|8\|TYPE=Size` `BONUS:SKILL\|Hide\|16\|TYPE=SIZE` `BONUS:LOADMULT\|TYPE=SIZE\|0.125\|…` | zen_test | Size-based bonuses to AC, attacks, skills, item cost/weight, carry capacity | NOT LOADED | All BONUS sub-tokens dropped |
| `ABILITY` | `ABILITY:Internal\|AUTOMATIC\|SIZE_MASTER` | zen_test | Grants the `SIZE_MASTER` internal ability which drives size-dependent logic | NOT LOADED | Dropped |

---

## 6. `equipmentslots.lst`

**Loader:** `lib/src/persistence/lst/equip_slot_loader.dart`

| Tag | Format | Modes | Java behaviour | Dart status | Notes |
|-----|--------|-------|----------------|-------------|-------|
| `NUMSLOTS` | `NUMSLOTS:DEFAULT HEAD:1 HANDS:2 TORSO:1 LEGS:2 SHIELD:1 [VEHICLE:1]` | all | Defines the count for each body region; `VEHICLE:1` appears in Modern and Starfinder | NOT LOADED | No `case 'NUMSLOTS'` in the loader; body region counts are never stored |
| `EQSLOT` | `EQSLOT:Head CONTAINS:Headgear=1 NUMBER:HEAD` | all | Defines one equipment slot — the type of items it can hold and which body region count to use | BUG | Loader has `case 'SLOTNAME'` not `case 'EQSLOT'`; the slot name from the first column is never extracted; all slots are discarded with empty names |
| `CONTAINS` | `CONTAINS:Headgear=1\|Helmet=1` | all | Pipe-delimited item types and max counts for this slot | PARTIAL | Types stored via `addContainedType()`; the `=N` count suffix is not extracted |
| `NUMBER` | `NUMBER:HEAD` | all | Body region key for this slot's count | IMPLEMENTED | Stored in `eqSlot.slotNumType`; but the parent slot is usually discarded due to `EQSLOT` bug |
| `HANDS` | *(sub-token of NUMSLOTS)* | all | Count for the HANDS region | NOT LOADED | Part of NUMSLOTS line; NUMSLOTS not loaded |
| `HEAD` | *(sub-token of NUMSLOTS)* | all | Count for the HEAD region | NOT LOADED | Same |
| `TORSO` | *(sub-token of NUMSLOTS)* | all | Count for the TORSO region | NOT LOADED | Same |
| `LEGS` | *(sub-token of NUMSLOTS)* | all | Count for the LEGS region | NOT LOADED | Same |
| `SHIELD` | *(sub-token of NUMSLOTS)* | all | Count for the SHIELD region | NOT LOADED | Same |
| `RINGS` | *(sub-token of NUMSLOTS)* | some | Count for ring slots | NOT LOADED | Same |
| `VEHICLE` | *(sub-token of NUMSLOTS)* | Modern, Starfinder | Count for vehicle slots | NOT LOADED | Same |

---

## 7. `pointbuymethods_system.lst`

**Loader:** `lib/src/persistence/lst/point_buy_loader.dart`

| Tag | Format | Modes | Java behaviour | Dart status | Notes |
|-----|--------|-------|----------------|-------------|-------|
| `STAT` | `STAT:8 COST:8` | all | Maps a stat score to its point-buy cost; `STAT:n` is the score, `COST:n` is the point cost | BUG | Loader expects `STAT:n=cost` format (`eqIdx = value.indexOf('=')`); file uses tab-separated `STAT:n COST:n`; the `=` is never found; all stat costs are silently dropped |
| `METHOD` | `METHOD:Standard Campaign POINTS:80` | all | Defines a named point-buy method with a total point budget | BUG | Loader has `case 'POINTBUYMETHOD'` not `case 'METHOD'`; and POINTS: is a separate sub-token not a suffix on METHOD: — double mismatch; methods are never registered |

**Critical:** The entire `pointbuymethods_system.lst` file is silently discarded due to two key-name mismatches. The UI falls back to hardcoded values (25-point buy with a hardcoded cost array).

---

## 8. `rules.lst`

**Loader:** `lib/src/persistence/game_mode_file_loader.dart` → `_parseRuleCheckLine()`

| Tag | Format | Modes | Java behaviour | Dart status | Notes |
|-----|--------|-------|----------------|-------------|-------|
| `NAME` | `NAME:LoadPenaltyToAcAndSkills` | all | Display label for this rule; Java looks up the language bundle first, falls back to this string | NOT STORED | Line header is consumed during parse but the display name is not stored |
| `@NAME` | `@NAME:WordsOfPower PARM:WORDSOFPOWER DEFAULT:YES` | Pathfinder | Optional/plugin rule; `@` prefix means the rule is only active when a supporting dataset is loaded | NOT LOADED | No handling for `@NAME` prefix; treated same as `NAME` — falls through the same parser but the @ distinction is lost |
| `VAR` | `VAR:SYS_LDPACSK` | all | Variable key for rules referenced from LST BONUS/PRE tokens | IMPLEMENTED | Stored in `SettingsHandler._ruleCheckMap` with DEFAULT value if not already set by user |
| `PARM` | `PARM:CLASSPRE` | all | Hardcoded Java parameter key (engine behaviour, not LST variable) | IMPLEMENTED | Same storage as VAR |
| `DEFAULT` | `DEFAULT:Yes` | all | Default ON/OFF state for this rule | IMPLEMENTED | Parsed as bool; drives `SettingsHandler.setRuleCheck()` |
| `EXCLUDE` | `EXCLUDE:DAMAGE_VW` | all | Key of a mutually exclusive rule (creates radio-button pair) | NOT STORED | Parsed out of tokens but not stored; exclusion groups are not enforced |
| `DESC` | `DESC:Apply Load Penalty…` | all | Human-readable description shown in the house rules dialog | NOT STORED | Not stored |

---

## 9. `codeControl.lst`

**Loader:** `lib/src/persistence/game_mode_file_loader.dart` → `_loadCodeControlFile()`

| Tag | Format | Modes | Java behaviour | Dart status | Notes |
|-----|--------|-------|----------------|-------------|-------|
| `ALIGNMENTFEATURE` | `ALIGNMENTFEATURE:YES` | all | Enables or disables the alignment system for this game mode | IMPLEMENTED | Stored via `setAlignmentFeature()`; not yet wired to hide alignment UI panels |
| `DOMAINFEATURE` | `DOMAINFEATURE:YES` | all | Enables or disables the cleric domain system | IMPLEMENTED | Stored via `setDomainFeature()`; not yet wired to hide domain UI |
| `FACE` | `FACE:Face` | Pathfinder, Pathfinder_PFS, Starfinder | Label for the "facing" combat stat in Pathfinder (replaces the reach/facing system) | NOT LOADED | No case in `_loadCodeControlFile()`; silently dropped |
| `STATINPUT` | `STATINPUT:STATSCORE` | Starfinder | Controls how the ability score input method works (score vs modifier entry) | NOT LOADED | No case; Starfinder uses modifier-first input which is ignored |
| `STATMODSAVE` | `STATMODSAVE:Save_StatBonus` | Starfinder | Variable name used to compute the stat-modifier contribution to saves | NOT LOADED | No case; Starfinder's save formula differs from 35e/5e |

---

## 10. `migration.lst`

**Loader:** `lib/src/persistence/lst/migration_loader.dart` — **class exists but is never invoked**

`GameModeFileLoader._loadGameModeFiles()` does not call `_loadMigrationFile()`.

| Tag | Format | Modes | Java behaviour | Dart status | Notes |
|-----|--------|-------|----------------|-------------|-------|
| `ABILITY` | `ABILITY:Category\|OldKey NEWKEY:NewKey MAXVER:6.00.01 MAXDEVVER:6.01.08` | all | Renames an ability when loading a character saved with PCGen ≤ MAXVER | NOT LOADED | Loader class complete but never called |
| `EQUIPMENT` | `EQUIPMENT:OldKey NEWKEY:NewKey MAXVER:6.4.00` | all | Renames an equipment item | NOT LOADED | Same |
| `RACE` | `RACE:OldRaceName NEWKEY:NewRaceName MAXVER:…` | all | Renames a race | NOT LOADED | Same |
| `SOURCE` | `SOURCE:Old Source NEWKEY:New Source MAXVER:…` | all | Renames a source book reference | NOT LOADED | Same |
| `NEWKEY` | *(sub-token)* | all | The replacement key | NOT LOADED | Handled in loader class `_applyToken()` but class is never instantiated at load time |
| `MAXVER` | `MAXVER:6.00.01` | all | Only apply if save file PCGen version ≤ this (release version) | NOT LOADED | Same |
| `MAXDEVVER` | `MAXDEVVER:6.01.08` | all | Only apply if save file PCGen version ≤ this (dev version) | NOT LOADED | Same |
| `NEWCATEGORY` | `NEWCATEGORY:Combat` | some | New category for migrated categorised objects | NOT LOADED | Same |

---

## 11. `bio/biosettings.lst`

**Loader:** `lib/src/persistence/lst/bio_set_loader.dart`

| Tag | Format | Modes | Java behaviour | Dart status | Notes |
|-----|--------|-------|----------------|-------------|-------|
| `AGESET` | `AGESET:0\|Adulthood BONUS:STAT\|STR,CON,DEX\|-1 …` | all with bio/ dir | Defines an age bracket by index and name; sub-tokens (BONUS, etc.) applied to characters in that bracket | PARTIAL | Index and name parsed correctly; `bioSet.addToAgeMap()` called; BONUS and other sub-tokens are not dispatched |
| `REGION` | `REGION:None` or `REGION:Khorvaire` | some | Sets the current region context for subsequent RACENAME lines | IMPLEMENTED | Sets internal `_region` variable to null for "NONE" or to the region string |
| `RACENAME` | `RACENAME:Human% CLASS:Barbarian[BASEAGEADD:1d4] SEX:Male[BASEHT:58 BASEWT:130 …]\|Female[…] BASEAGE:15 MAXAGE:34 AGEDIEROLL:5d4 HAIR:Blond\|Brown EYES:Blue SKINTONE:Tanned` | all with bio/ dir | Associates bio data (height, weight, age, appearance options) with a race pattern | PARTIAL | Tab-delimited sub-tokens stored verbatim as raw strings in `bioSet`; never parsed into structured height/weight/age/appearance data |

Sub-tokens on `RACENAME` lines (all NOT LOADED — stored as raw strings only):

| Sub-token | Meaning |
|-----------|---------|
| `CLASS` | Age category add formula by class |
| `SEX` | Per-sex height/weight/appearance dice data |
| `BASEAGE` | Base age for this category |
| `MAXAGE` | Maximum age for this category |
| `AGEDIEROLL` | Dice formula for age variation |
| `HAIR` | Pipe-delimited hair colour options |
| `EYES` | Pipe-delimited eye colour options |
| `SKINTONE` | Pipe-delimited skin tone options |

---

## 12. `bio/traits.lst`

**Loader:** `lib/src/persistence/lst/trait_loader.dart`

| Section | Modes | Dart status |
|---------|-------|-------------|
| `[TRAIT]` | all | IMPLEMENTED |
| `[SPEECH]` | all | IMPLEMENTED |
| `[PHRASE]` | all | IMPLEMENTED |
| `[PHOBIA]` | all | IMPLEMENTED |
| `[INTERESTS]` | all | IMPLEMENTED |
| `[HAIRSTYLE]` | all | IMPLEMENTED |
| `[HAIRLENGTH]` | default, Fantasy_Craft | NOT LOADED — section header not recognised by `TraitLoader`; hair length options silently dropped |

---

## 13. `bio/locations.lst`

**Loader:** `lib/src/persistence/lst/location_loader.dart`

| Section | Modes | Dart status |
|---------|-------|-------------|
| `[LOCATION]` | all | IMPLEMENTED |
| `[BIRTHPLACE]` | all | IMPLEMENTED |
| `[CITY]` | all | IMPLEMENTED |

All three sections fully implemented across all game modes.

---

## 14. `tips.txt`

No loader in the Dart codebase. Java loaded this via `TipOfTheDayLoader`.

| Format | Dart status |
|--------|-------------|
| Plain text lines (one tip per line); `#` comments ignored | NOT LOADED — `SettingsHandler` has `getLastTipShown()` / `setShowTipOfTheDay()` fields but no tip content loader exists |

---

## Gaps by Priority

### P1 — Breaks core character data (implement now)

| # | What | File | Fix |
|---|------|------|-----|
| 1 | `SHORTRANGE` key mismatch | `game_mode_loader.dart:140` | Rename `case 'SHORTRANGEDISTANCE'` → `case 'SHORTRANGE'` (one line) |
| 2 | `CSKILLMAX`/`CCSKILLMAX` not loaded | `level_loader.dart` | Add alias cases; 35e max skill ranks are never set |
| 3 | `EQSLOT` key mismatch — all slots discarded | `equip_slot_loader.dart` | Add `case 'EQSLOT'` that sets slot name; equipment slot system has no data |
| 4 | `SizeAdjustment` name includes tag prefix | `size_adjustment_loader.dart` | Strip `SIZENAME:` prefix before registering; also dispatch sub-tokens |
| 5 | Point-buy loader format mismatch | `point_buy_loader.dart` | Rewrite parser: `STAT:n\tCOST:n` and `METHOD:name\tPOINTS:n` format |
| 6 | `LOAD`/`LOADMULT`/`ENCUMBRANCE` not loaded | `load_info_loader.dart` | Rewrite loader to handle all three token types; encumbrance system has no data |
| 7 | `DIESIZES` MIN=/MAX= lost | `game_mode_loader.dart` | Strip `MIN=`/`MAX=` prefix before `int.tryParse()`; store min/max markers |
| 8 | `GAMEMODEKEY` not loaded | `game_mode_loader.dart` | Add case; affects PCC `GAMEMODE:` lookups for Pathfinder and others |

### P2 — Significant missing features

| # | What | File | Fix |
|---|------|------|-----|
| 9 | `BONUSFEATLEVELSTARTINTERVAL`/`BONUSSTATLEVELSTARTINTERVAL` not loaded | `game_mode_loader.dart` | Add cases; feat/stat gain schedules undefined for all modes |
| 10 | `SKILLCOST_CLASS/CROSSCLASS/EXCLUSIVE` not loaded | `game_mode_loader.dart` | Add three cases; skill cost always uses defaults regardless of game mode |
| 11 | `migration.lst` loader never invoked | `game_mode_file_loader.dart` | Add `_loadMigrationFile()` call; old character files silently fail to migrate |
| 12 | `NUMSLOTS` not loaded | `equip_slot_loader.dart` | Add case; body slot counts never set |
| 13 | `BonusSpellInfo` sub-tokens not dispatched | `stats_and_checks_loader.dart` | Implement BASESTATSCORE/STATRANGE token dispatch; bonus spells always wrong |
| 14 | `SizeAdjustment` BONUS sub-tokens dropped | `size_adjustment_loader.dart` | Dispatch BONUS tokens; size modifiers to AC/skills/encumbrance never applied |
| 15 | `XPAWARD` not loaded | `game_mode_loader.dart` | Add case; Pathfinder/Pathfinder_2 XP awards have no data |

### P3 — Lower urgency / UI features

| # | What | File | Fix |
|---|------|------|-----|
| 16 | `AGESET` BONUS sub-tokens not applied | `bio_set_loader.dart` | Dispatch BONUS; age-category stat modifiers (Middle Age: -1 STR etc.) not applied |
| 17 | `RACENAME` sub-tokens stored raw | `bio_set_loader.dart` | Parse CLASS/SEX/BASEAGE/MAXAGE/AGEDIEROLL/HAIR/EYES/SKINTONE into structured data |
| 18 | `TAB:` NAME and CONTEXT sub-tokens discarded | `game_mode_loader.dart` | Store localised label key and help-context HTML path |
| 19 | `[HAIRLENGTH]` section not loaded | `trait_loader.dart` | Add section to the recognised set |
| 20 | `WEAPONNONPROFPENALTY` discarded | `game_mode_loader.dart` | Store and apply non-proficiency attack penalty |
| 21 | `PLUSCOST` not loaded | `game_mode_loader.dart` | Add case; magic item enhancement pricing missing for Pathfinder |
| 22 | `CRSTEPS`/`MONSTERROLES`/`MONSTERROLEDEFAULT` not loaded | `game_mode_loader.dart` | Add cases; CR/monster creation dialog data missing |
| 23 | `MAXNONEPICLEVEL` not loaded | `game_mode_loader.dart` | Add case; epic level threshold always defaults to 20 |
| 24 | `FACE`/`STATINPUT`/`STATMODSAVE` not loaded (Pathfinder/Starfinder) | `game_mode_file_loader.dart` | Add cases to `_loadCodeControlFile()` |
| 25 | `tips.txt` not loaded | new loader needed | Create `TipOfTheDayLoader`; optional QoL feature |
| 26 | Point-buy/roll-method data not used in summary UI | `summary_info_tab.dart` | Read `GameMode.getRollMethods()` and `getPointBuyStatCosts()` instead of hardcoded arrays |
| 27 | `ACTYPE` data not consumed by AC calculation | `summary_info_tab.dart` + engine | Wire `GameMode.getAllACTypes()` into AC calculation |
| 28 | `ALIGNMENTFEATURE`/`DOMAINFEATURE` not wired to UI | `pc_gen_frame.dart` | Hide alignment/domain panels when `isAlignmentFeatureEnabled()` is false |
| 29 | `@NAME` optional rule prefix not recognised | `game_mode_file_loader.dart` | Treat `@NAME` same as `NAME` but mark rule as optional |
