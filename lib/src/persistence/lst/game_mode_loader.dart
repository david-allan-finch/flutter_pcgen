//
// Copyright 2001 (C) Greg Bingleman <byngl@hotmail.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.persistence.lst.GameModeLoader

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_pcgen/src/core/ability_category.dart';
import 'package:flutter_pcgen/src/core/game_mode.dart';
import 'package:flutter_pcgen/src/persistence/lst/ability_category_loader.dart';

// Track which stub tokens have already been reported so we only print once.
final _reportedStubs = <String>{};

// ---------------------------------------------------------------------------
// Token helpers — parse tab-delimited subtokens into a map
// ---------------------------------------------------------------------------

Map<String, String> _subtokens(String rest) {
  final m = <String, String>{};
  for (final tok in rest.split('\t')) {
    final t = tok.trim();
    if (t.isEmpty) continue;
    final c = t.indexOf(':');
    if (c <= 0) continue;
    m[t.substring(0, c).toUpperCase()] = t.substring(c + 1);
  }
  return m;
}

/// Utility class (no instances) that parses individual lines from game mode
/// configuration files (miscinfo.lst, statsandchecks.lst, etc.).
final class GameModeLoader {
  GameModeLoader._();

  // ---------------------------------------------------------------------------
  // miscinfo.lst line parsing
  // ---------------------------------------------------------------------------

  /// Parses one line from a miscinfo.lst file and applies it to [gameMode].
  ///
  /// Lines are tab-delimited. The first token is KEY:firstValue; subsequent
  /// tokens are subtokens that only apply to multi-value tokens.
  static void parseMiscGameInfoLine(
      GameMode gameMode, String aLine, Uri source, int lineNum) {
    if (aLine.isEmpty || aLine.startsWith('#')) return;

    final colonIdx = aLine.indexOf(':');
    if (colonIdx < 0) return;

    final key = aLine.substring(0, colonIdx).trim();
    final rest = aLine.substring(colonIdx + 1); // everything after KEY:
    final firstTab = rest.indexOf('\t');
    final value = (firstTab > 0 ? rest.substring(0, firstTab) : rest).trim();
    if (value.isEmpty && !_multiTokenKeys.contains(key)) return;

    _applyMiscToken(gameMode, key, value, aLine);
  }

  // Keys that carry their data in subtokens (the first value may be empty or
  // just the name; the rest is in tab-separated KEY:VAL pairs).
  static const _multiTokenKeys = {
    'TAB', 'ROLLMETHOD', 'CLASSTYPE', 'UNITSET', 'ACTYPE',
    'WIELDCATEGORY', 'BASEDICE', 'WEAPONTYPE',
  };

  static void _applyMiscToken(GameMode gm, String key, String value, String fullLine) {
    switch (key) {
      case 'ACFORMULA':
        gm.setACFormula(value);
      case 'ALLOWEDMODES':
        for (final m in value.split('|')) {
          if (m.trim().isNotEmpty) gm.addAllowedMode(m.trim());
        }
      case 'ALTHPABBREV':
        gm.setALTHPAbbrev(value);
      case 'ALTHPNAME':
        gm.setALTHPName(value);
      case 'BABMAXATT':
        gm.setBabMaxAtt(int.tryParse(value) ?? gm.getBabMaxAtt());
      case 'BABMINVAL':
        gm.setBabMinVal(int.tryParse(value) ?? gm.getBabMinVal());
      case 'BABATTCYC':
        gm.setBabAttCyc(int.tryParse(value) ?? gm.getBabAttCyc());
      case 'BONUSFEATLEVEL':
        gm.setBonusFeatLevels(value);
      case 'BONUSSTATLEVEL':
        gm.setBonusStatLevels(value);
      case 'CRTHRESHOLD':
        gm.setCRThreshold(value);
      case 'CURRENCYUNIT':
        gm.setCurrencyUnit(value);
      case 'CURRENCYUNITABBREV':
        gm.setCurrencyUnitAbbrev(value);
      case 'DAMAGERES':
        gm.setDamageResistanceText(value);
      case 'DEFAULTSPELLBOOK':
        gm.setDefaultSpellBook(value);
      case 'DEFAULTUNITSET':
        gm.setDefaultUnitSet(value);
      case 'DEITY':
        gm.setDeityTerm(value);
      case 'DISPLAYNAME':
        gm.setDisplayName(value);
      case 'DISPLAYORDER':
        gm.setDisplayOrder(int.tryParse(value) ?? gm.getDisplayOrder());
      case 'DIESIZES':
        // Format: 1,2,3,MIN=4,6,8,10,MAX=12,20,100,1000
        // MIN= marks the soft minimum; MAX= marks the hard maximum cap.
        // Strip these prefixes before parsing so int.tryParse succeeds.
        final sizes = value.split(',').map((s) {
          var t = s.trim();
          if (t.startsWith('MIN=')) t = t.substring(4);
          else if (t.startsWith('MAX=')) t = t.substring(4);
          return int.tryParse(t);
        }).whereType<int>().toList();
        if (sizes.isNotEmpty) gm.setDieSizes(sizes);
      case 'HPABBREV':
        gm.setHPAbbrev(value);
      case 'HPNAME':
        gm.setHPName(value);
      case 'LEVELMSG':
        gm.setLevelUpMessage(value);
      case 'MENUENTRY':
        gm.setMenuEntry(value);
      case 'MOVEFORMULA':
        gm.setMoveFormula(value);
      case 'RANKMODFORMULA':
        gm.setRankModFormula(value);
      case 'ROLLHP':
        gm.setRollHP(int.tryParse(value) ?? gm.getRollHP());
      case 'ROLLFORMULA':
        gm.setRollFormula(value);
      case 'SHORTRANGE':
      case 'SHORTRANGEDISTANCE':
        gm.setShortRangeDistance(int.tryParse(value) ?? gm.getShortRangeDistance());
      case 'SKILLMULT':
      case 'SKILLMULTIPLIER':
        gm.addSkillMultiplierLevel(value);
      case 'SPELLBASECONCENTRATION':
        gm.setSpellBaseConcentration(value);
      case 'SPELLBASEDC':
        gm.setSpellBaseDC(value);
      case 'SPELLRANGE':
        // format: NAME|FORMULA
        final pipe = value.indexOf('|');
        if (pipe > 0) {
          gm.addSpellRange(value.substring(0, pipe), value.substring(pipe + 1));
        }
      case 'STATMAX':
        gm.setStatMax(int.tryParse(value) ?? gm.getStatMax());
      case 'STATMIN':
        gm.setStatMin(int.tryParse(value) ?? gm.getStatMin());
      case 'TABNAME':
        gm.setTabName(value);
      case 'PREVIEWDIR':
        gm.setPreviewDir(value);
      case 'PREVIEWSHEET':
        gm.setPreviewSheet(value);
      case 'WEAPONREACH':
      case 'WEAPONREACHFORMULA':
        gm.setWeaponReachFormula(value);
      case 'XPENABLED':
        gm.setXPEnabled(value.toLowerCase() != 'no');
      case 'ABILITYCATEGORY':
        // ABILITYCATEGORY:FEAT  VISIBLE:YES  EDITABLE:YES  ... — register game-mode
        // level ability categories (e.g. FEAT, Internal) so that ability LST files
        // can reference them by name during source loading.
        _parseAbilityCategory(value, fullLine);

      // -----------------------------------------------------------------------
      // Newly implemented tokens
      // -----------------------------------------------------------------------

      case 'ACNAME':
        gm.setACName(value);

      case 'BONUSSTACKS':
        gm.setBonusStacks(value);

      case 'RANGEPENALTY':
        gm.setRangePenalty(int.tryParse(value) ?? 0);

      case 'SQUARESIZE':
        gm.setSquareSize(int.tryParse(value) ?? 5);

      case 'DEFAULTDATASET':
        gm.setDefaultDataset(value);

      case 'RESIZABLEEQUIPTYPE':
        for (final t in value.split('|')) {
          if (t.isNotEmpty) gm.addResizableEquipType(t.trim());
        }

      case 'CHARACTERTYPE':
        for (final t in value.split('|')) {
          if (t.isNotEmpty) gm.addCharacterType2(t.trim());
        }

      case 'WEAPONCATEGORY':
        gm.addWeaponCategoryName(value);

      case 'WEAPONNONPROFPENALTY':
        // TODO: store on GameMode and apply as attack penalty for non-proficiency
        if (kDebugMode && _reportedStubs.add('WEAPONNONPROFPENALTY')) {
          // ignore: avoid_print
          print('PCGen STUB: game mode WEAPONNONPROFPENALTY=$value (not yet applied to combat rolls)');
        }

      case 'WEAPONTYPE':
        // WEAPONTYPE:Name|Abbrev
        final pipe = value.indexOf('|');
        if (pipe > 0) {
          gm.addWeaponTypeName(value.substring(0, pipe), value.substring(pipe + 1));
        } else {
          gm.addWeaponTypeName(value, value);
        }

      case 'TAB':
        // TAB:KEY  NAME:localised  [VISIBLE:NO]  CONTEXT:...
        _parseTab(gm, value, fullLine);

      case 'ROLLMETHOD':
        // ROLLMETHOD:Name  SORTKEY:xx  METHOD:formula
        _parseRollMethod(gm, value, fullLine);

      case 'CLASSTYPE':
        // CLASSTYPE:Name  CRFORMULA:x  ISMONSTER:YES/NO  XPPENALTY:YES/NO  CRMOD:n  CRMODPRIORITY:n
        _parseClassType(gm, value, fullLine);

      case 'UNITSET':
        // UNITSET:Name  HEIGHTUNIT:x  HEIGHTFACTOR:n  ...
        _parseUnitSet(gm, value, fullLine);

      case 'ACTYPE':
        // ACTYPE:Name  ADD:Type1|Type2  REMOVE:Type3|Type4
        _parseACType(gm, value, fullLine);

      case 'WIELDCATEGORY':
        // WIELDCATEGORY:Name  HANDS:n  FINESSABLE:Yes  SIZEDIFF:n
        // OR: WIELDCATEGORY:Name  UP:Cat1|Cat2  DOWN:Cat3  (progression rules)
        _parseWieldCategory(gm, value, fullLine);

      case 'BASEDICE':
        // BASEDICE:1d6  UP:2d6,3d6  DOWN:1d6
        gm.addBaseDice(fullLine.trim());

      case 'INFOSHEET':
        // INFOSHEET:TYPE|path
        {
          final pipe = value.indexOf('|');
          if (pipe > 0) {
            gm.addInfoSheet(value.substring(0, pipe), value.substring(pipe + 1));
          }
        }

      case 'OUTPUTSHEET':
        // OUTPUTSHEET:TYPE|path  or  OUTPUTSHEET:DIRECTORY|dir
        {
          final pipe = value.indexOf('|');
          if (pipe > 0) {
            gm.addOutputSheet(value.substring(0, pipe), value.substring(pipe + 1));
          }
        }

      case 'MONSTERROLES':
      case 'MONSTERROLEDEFAULT':
      case 'CRSTEPS':
        // TODO: store on GameMode for monster/XP calculation
        if (kDebugMode && _reportedStubs.add(key)) {
          // ignore: avoid_print
          print('PCGen STUB: game mode $key (not yet stored; first value: $value)');
        }

      case 'EQSIZEPENALTY':
        // TODO: parse inline BONUS tokens and apply to equipment size penalty system
        if (kDebugMode && _reportedStubs.add('EQSIZEPENALTY')) {
          // ignore: avoid_print
          print('PCGen STUB: game mode EQSIZEPENALTY (complex inline BONUS — not yet evaluated)');
        }

      case 'MAXNONEPICLEVEL':
        gm.setMaxNonEpicLevel(int.tryParse(value) ?? 20);

      case 'GAMEMODEKEY':
        // Alternate reference key for this game mode (used in PCC GAMEMODE: lookups)
        gm.setGameModeKey(value);

      case 'BONUSFEATLEVELSTARTINTERVAL':
        gm.setBonusFeatLevels(value);

      case 'BONUSSTATLEVELSTARTINTERVAL':
        gm.setBonusStatLevels(value);

      case 'SKILLCOST_CLASS':
        gm.setSkillCostClass(int.tryParse(value) ?? 1);

      case 'SKILLCOST_CROSSCLASS':
        gm.setSkillCostCrossClass(int.tryParse(value) ?? 2);

      case 'SKILLCOST_EXCLUSIVE':
        gm.setSkillCostExclusive(int.tryParse(value) ?? 0);

      case 'PLUSCOST':
        // PLUSCOST:TYPE|formula  — enhancement cost formula by equipment type
        {
          final pipe = value.indexOf('|');
          if (pipe > 0) {
            gm.addPlusCost(value.substring(0, pipe).trim(),
                           value.substring(pipe + 1).trim());
          }
        }

      case 'XPAWARD':
        // XPAWARD:CR=XP|CR=XP|…  where CR may be a fraction like 1/4
        for (final entry in value.split('|')) {
          final eq = entry.indexOf('=');
          if (eq > 0) {
            final crStr = entry.substring(0, eq).trim();
            final xp = int.tryParse(entry.substring(eq + 1).trim());
            if (xp != null) {
              // Store fractional CRs as scaled integers (CR*8 so 1/8=1, 1/4=2, 1/2=4, 1=8…)
              final crInt = _parseCRToInt(crStr);
              if (crInt != null) gm.addXPaward(crInt, xp);
            }
          }
        }

      default:
        if (kDebugMode && _reportedStubs.add(key)) {
          // ignore: avoid_print
          print('PCGen STUB: game mode unknown token $key (first value: $value)');
        }
    }
  }

  /// Converts a CR string (possibly a fraction like "1/4" or "1/2") to a
  /// scaled integer (multiplied by 8 so all standard CRs are whole numbers).
  static int? _parseCRToInt(String cr) {
    final slash = cr.indexOf('/');
    if (slash > 0) {
      final num = int.tryParse(cr.substring(0, slash).trim());
      final den = int.tryParse(cr.substring(slash + 1).trim());
      if (num != null && den != null && den != 0) {
        return (num * 8 ~/ den); // e.g. 1/4 → 2, 1/2 → 4, 1/8 → 1
      }
      return null;
    }
    final n = int.tryParse(cr.trim());
    return n != null ? n * 8 : null;
  }

  static void _parseTab(GameMode gm, String name, String fullLine) {
    final subs = _subtokens(fullLine.substring(fullLine.indexOf(':') + 1));
    final visible = subs['VISIBLE']?.toUpperCase() != 'NO';
    gm.setTabVisible(name, visible);
  }

  static void _parseRollMethod(GameMode gm, String name, String fullLine) {
    final subs = _subtokens(fullLine.substring(fullLine.indexOf(':') + 1));
    final sortKey = subs['SORTKEY'] ?? '';
    final method = subs['METHOD'] ?? name;
    gm.addRollMethod(RollMethod(name, sortKey, method));
  }

  static void _parseClassType(GameMode gm, String name, String fullLine) {
    final subs = _subtokens(fullLine.substring(fullLine.indexOf(':') + 1));
    final isMonster = subs['ISMONSTER']?.toUpperCase() == 'YES';
    final xpPenalty = subs['XPPENALTY']?.toUpperCase() == 'YES';
    final crFormula = subs['CRFORMULA'] ?? 'CL';
    final crMod = int.tryParse(subs['CRMOD'] ?? '0') ?? 0;
    final crPri = int.tryParse(subs['CRMODPRIORITY'] ?? '1') ?? 1;
    // Replace if already exists
    final existing = gm.getClassTypeByName(name);
    if (existing != null) {
      existing.isMonster = isMonster;
      existing.xpPenalty = xpPenalty;
      existing.crFormula = crFormula;
      existing.crMod = crMod;
      existing.crModPriority = crPri;
    } else {
      gm.addClassType(ClassType(name,
          isMonster: isMonster,
          xpPenalty: xpPenalty,
          crFormula: crFormula,
          crMod: crMod,
          crModPriority: crPri));
    }
  }

  static void _parseUnitSet(GameMode gm, String name, String fullLine) {
    final subs = _subtokens(fullLine.substring(fullLine.indexOf(':') + 1));
    gm.addUnitSet(UnitSet(
      name: name,
      heightUnit: subs['HEIGHTUNIT'] ?? 'ftin',
      heightFactor: double.tryParse(subs['HEIGHTFACTOR'] ?? '1') ?? 1.0,
      heightPattern: subs['HEIGHTPATTERN'] ?? '#',
      distanceUnit: subs['DISTANCEUNIT'] ?? 'ft.',
      distanceFactor: double.tryParse(subs['DISTANCEFACTOR'] ?? '1') ?? 1.0,
      distancePattern: subs['DISTANCEPATTERN'] ?? '#.##',
      weightUnit: subs['WEIGHTUNIT'] ?? 'lbs.',
      weightFactor: double.tryParse(subs['WEIGHTFACTOR'] ?? '1') ?? 1.0,
      weightPattern: subs['WEIGHTPATTERN'] ?? '#.##',
    ));
  }

  static void _parseACType(GameMode gm, String name, String fullLine) {
    // ACTYPE lines have multiple ADD: and REMOVE: subtokens. We parse them all.
    final addTypes = <String>[];
    final removeTypes = <String>[];
    for (final tok in fullLine.split('\t')) {
      final t = tok.trim();
      final c = t.indexOf(':');
      if (c <= 0) continue;
      final tKey = t.substring(0, c).toUpperCase();
      final tVal = t.substring(c + 1);
      if (tKey == 'ADD') {
        // ADD:Type1|Type2  — split by | but drop PREV... conditions
        for (final part in tVal.split('|')) {
          final p = part.trim();
          if (p.isNotEmpty && !p.startsWith('PRE')) addTypes.add(p);
        }
      } else if (tKey == 'REMOVE') {
        for (final part in tVal.split('|')) {
          final p = part.trim();
          if (p.isNotEmpty && !p.startsWith('PRE')) removeTypes.add(p);
        }
      }
    }
    gm.addACType(ACType(name, add: addTypes, remove: removeTypes));
  }

  static void _parseWieldCategory(GameMode gm, String name, String fullLine) {
    final subs = _subtokens(fullLine.substring(fullLine.indexOf(':') + 1));
    final existing = gm.getWieldCategoryDef(name);
    if (subs.containsKey('HANDS') || subs.containsKey('SIZEDIFF') || subs.containsKey('FINESSABLE')) {
      // Base definition line
      final hands = int.tryParse(subs['HANDS'] ?? '1') ?? 1;
      final finessable = subs['FINESSABLE']?.toLowerCase() == 'yes';
      final sizeDiff = int.tryParse(subs['SIZEDIFF'] ?? '0') ?? 0;
      if (existing != null) {
        existing.hands = hands;
        existing.finessable = finessable;
        existing.sizeDiff = sizeDiff;
      } else {
        gm.addWieldCategoryDef(WieldCategory(name,
            hands: hands, finessable: finessable, sizeDiff: sizeDiff));
      }
    } else {
      // Progression line: UP:/DOWN:/SWITCH:
      final wc = existing ?? WieldCategory(name);
      if (existing == null) gm.addWieldCategoryDef(wc);
      if (subs.containsKey('UP')) {
        wc.upCategories.addAll(subs['UP']!.split('|').where((s) => s.isNotEmpty));
      }
      if (subs.containsKey('DOWN')) {
        wc.downCategories.addAll(subs['DOWN']!.split('|').where((s) => s.isNotEmpty));
      }
      if (subs.containsKey('SWITCH')) {
        wc.switchRules.add('${subs['SWITCH']}');
      }
    }
  }

  static final _abilityCategoryLoader = AbilityCategoryLoader();

  static void _parseAbilityCategory(String value, String fullLine) {
    // The full ability category line including all subtokens needs to be passed.
    final restAfterColon = fullLine.substring(fullLine.indexOf(':') + 1);
    try {
      _abilityCategoryLoader.parseLine(null, 'ABILITYCATEGORY:$restAfterColon', Uri());
    } catch (_) {
      final name = value.split('\t').first.trim();
      if (name.isNotEmpty) AbilityCategory(name);
    }
  }
}
