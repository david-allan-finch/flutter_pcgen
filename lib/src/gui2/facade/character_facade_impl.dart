//
// Copyright 2009 (C) James Dempsey
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
// Translation of pcgen.gui2.facade.CharacterFacadeImpl

import 'package:flutter/foundation.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/core/language.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/rules/parsed_bonus.dart';
import 'package:flutter_pcgen/src/rules/bonus_accumulator.dart';
import 'package:flutter_pcgen/src/rules/formula_evaluator.dart';
import 'package:flutter_pcgen/src/facade/core/character_facade.dart';
import 'package:flutter_pcgen/src/facade/core/character_levels_facade.dart';
import 'package:flutter_pcgen/src/facade/core/description_facade.dart';
import 'package:flutter_pcgen/src/facade/core/equipment_list_facade.dart';
import 'package:flutter_pcgen/src/facade/core/equipment_set_facade.dart';
import 'package:flutter_pcgen/src/facade/core/companion_support_facade.dart';
import 'package:flutter_pcgen/src/facade/core/spell_support_facade.dart';
import 'package:flutter_pcgen/src/facade/core/temp_bonus_facade.dart';
import 'package:flutter_pcgen/src/facade/util/list_facade.dart';
import 'package:flutter_pcgen/src/facade/util/default_reference_facade.dart';
import 'package:flutter_pcgen/src/facade/util/reference_facade.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_abilities.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_levels_facade_impl.dart';
import 'package:flutter_pcgen/src/gui2/facade/description_facade_impl.dart';
import 'package:flutter_pcgen/src/gui2/facade/equipment_list_facade_impl.dart';
import 'package:flutter_pcgen/src/gui2/facade/equipment_set_facade_impl.dart';
import 'package:flutter_pcgen/src/gui2/facade/companion_support_facade_impl.dart';
import 'package:flutter_pcgen/src/gui2/facade/spell_support_facade_impl.dart';
import 'package:flutter_pcgen/src/gui2/facade/temp_bonus_facade_impl.dart';

/// Main implementation of CharacterFacade — the primary model object for an
/// open character in the GUI. Wraps all character data and provides accessors
/// for every aspect of the character (stats, levels, equipment, spells, etc.).
///
/// This is a translation of the 4000-line Java CharacterFacadeImpl. The Dart
/// version centralises all character data in a Map<String, dynamic> and lazily
/// constructs sub-facades on first access.
class CharacterFacadeImpl extends ChangeNotifier implements CharacterFacade {
  final Map<String, dynamic> _data;

  // Sub-facades (lazily initialised)
  CharacterAbilities? _abilities;
  CharacterLevelsFacadeImpl? _levels;
  DescriptionFacadeImpl? _description;
  EquipmentListFacadeImpl? _equipmentList;
  CompanionSupportFacadeImpl? _companionSupport;
  SpellSupportFacadeImpl? _spellSupport;
  TempBonusFacadeImpl? _tempBonus;

  // Equipment sets
  final List<EquipmentSetFacadeImpl> _equipmentSets = [];
  int _activeEquipSetIndex = 0;

  // ---- Rules engine --------------------------------------------------------
  BonusAccumulator _bonusAcc = BonusAccumulator();
  bool _bonusDirty = true; // rebuild on next access
  dynamic _dataset; // cached dataset reference for incremental rebuilds

  // Reference facades
  late final DefaultReferenceFacade<Object> _raceRef;
  late final DefaultReferenceFacade<Object> _alignmentRef;
  late final DefaultReferenceFacade<Object> _deityRef;
  late final DefaultReferenceFacade<String> _nameRef;
  late final DefaultReferenceFacade<String> _tabNameRef;
  late final DefaultReferenceFacade<String?> _fileRef;

  CharacterFacadeImpl(this._data) {
    // Race/alignment/deity are stored only as key strings; live objects are
    // reconstructed after load via restoreFromDataset().
    _raceRef = DefaultReferenceFacade(null);
    _alignmentRef = DefaultReferenceFacade(null);
    _deityRef = DefaultReferenceFacade(null);
    _nameRef = DefaultReferenceFacade(_data['name'] as String? ?? '');
    _tabNameRef = DefaultReferenceFacade(_data['tabName'] as String? ?? '');
    _fileRef = DefaultReferenceFacade(_data['fileName'] as String?);
    if (_equipmentSets.isEmpty) {
      _equipmentSets.add(EquipmentSetFacadeImpl('Default'));
    }
  }

  // ---- Identity -----------------------------------------------------------

  @override
  String getDisplayName() => _str('name');

  @override
  String getName() => _str('name');

  @override
  ReferenceFacade<String> getNameRef() => _nameRef;

  @override
  String getTabName() => _str('tabName').isNotEmpty ? _str('tabName') : getDisplayName();

  @override
  ReferenceFacade<String> getTabNameRef() => _tabNameRef;

  @override
  void setName(String name) {
    _set('name', name);
    _nameRef.set(name);
  }

  @override
  String getPlayersName() => _str('playerName');

  String getPlayerName() => _str('playerName');

  @override
  void setPlayersName(String name) => _set('playerName', name);

  void setPlayerName(String name) => _set('playerName', name);

  @override
  String? getFilePath() => _data['fileName'] as String?;

  String getFileName() => _str('fileName');

  @override
  void setFilePath(String? path) {
    _set('fileName', path ?? '');
    _fileRef.set(path);
  }

  void setFileName(String path) => setFilePath(path);

  @override
  ReferenceFacade<String?> getFileRef() => _fileRef;

  @override
  bool isDirty() => _data['modified'] as bool? ?? false;

  @override
  bool isModified() => isDirty();

  void setModified(bool modified) {
    _data['modified'] = modified;
    notifyListeners();
  }

  // ---- Race ---------------------------------------------------------------

  @override
  DefaultReferenceFacade<Object> getRaceRef() => _raceRef;

  /// Assign a race. Stores only the key name in the serialisable data map;
  /// the live object is kept in [_raceRef] for in-session use.
  @override
  void setRace(Object race) {
    _data['raceKey'] = (race as dynamic).getKeyName() as String? ?? '';
    _data.remove('racialStatBonuses'); // invalidate cache
    _raceRef.set(race);
    _applyRaceTraits(race);
    // Cache racial bonuses immediately so stat display updates even before the
    // first full rebuildBonuses (e.g. when _dataset is already set).
    if (_dataset != null) {
      _cacheRacialBonuses(race, _dataset);
    }
    _rebuild();
    notifyListeners();
  }

  /// Grant automatic languages and store size/speed from the race object.
  void _applyRaceTraits(dynamic race) {
    try {
      // Size
      final size = (race as dynamic).getSize() as String? ?? '';
      if (size.isNotEmpty) _data['raceSize'] = size;

      // Movement speeds
      final speeds = (race as dynamic).getMoveSpeeds() as Map<String, int>?;
      if (speeds != null && speeds.isNotEmpty) _data['raceSpeeds'] = speeds;

      // Auto languages + bonus languages — walk full ability chain
      final autoLangs = <String>{};
      final bonusLangs = <String>{};
      _collectChainLanguages(race, _dataset, autoLangs, bonusLangs, {});
      if (autoLangs.isNotEmpty) {
        final langKeys = (_data['languageKeys'] ??= <String>[]) as List;
        for (final lang in autoLangs) {
          if (!langKeys.contains(lang)) langKeys.add(lang);
        }
      }
      _data['raceBonusLanguages'] = bonusLangs.toList();
    } catch (_) {}
  }

  String getRaceKey() => _data['raceKey'] as String? ?? '';

  // ---- Alignment ----------------------------------------------------------

  @override
  DefaultReferenceFacade<Object> getAlignmentRef() => _alignmentRef;

  @override
  void setAlignment(Object? alignment) {
    // Store only the key name; object kept in ref for in-session use.
    if (alignment != null) {
      _data['alignmentKey'] = (alignment as dynamic).getKeyName() as String? ?? '';
    }
    _alignmentRef.set(alignment);
    notifyListeners();
  }

  // ---- Deity --------------------------------------------------------------

  @override
  DefaultReferenceFacade<Object> getDeityRef() => _deityRef;

  @override
  void setDeity(Object? deity) {
    if (deity != null) {
      _data['deityKey'] = (deity as dynamic).getKeyName() as String? ?? '';
    }
    _deityRef.set(deity);
    notifyListeners();
  }

  // ---- Gender / Age -------------------------------------------------------

  @override
  String getGender() => _str('gender');

  @override
  void setGender(String gender) => _set('gender', gender);

  @override
  int getAge() => (_data['age'] as num?)?.toInt() ?? 0;

  @override
  void setAge(int age) {
    _data['age'] = age;
    notifyListeners();
  }

  @override
  String getAgeCategory() => _str('ageCategory');

  // ---- Abilities (stats) --------------------------------------------------

  CharacterAbilities get abilities =>
      _abilities ??= CharacterAbilities(_data);

  // ---- Levels -------------------------------------------------------------

  @override
  CharacterLevelsFacade getLevels() =>
      _levels ??= CharacterLevelsFacadeImpl(_data);

  @override
  int getTotalLevels() {
    if (_data['classLevels'] is List) {
      return (_data['classLevels'] as List).length;
    }
    return 0;
  }

  @override
  int getXP() => (_data['xp'] as num?)?.toInt() ?? 0;

  @override
  void setXP(int xp) {
    _data['xp'] = xp;
    notifyListeners();
  }

  void adjustXP(int delta) {
    _data['xp'] = ((_data['xp'] as num?)?.toInt() ?? 0) + delta;
    notifyListeners();
  }

  @override
  int getXPForNextLevel() => (_data['xpForNext'] as num?)?.toInt() ?? 0;

  @override
  String getXPTableName() => _str('xpTable');

  // ---- Description --------------------------------------------------------

  @override
  DescriptionFacade getDescription() =>
      _description ??= DescriptionFacadeImpl(
          (_data['description'] as Map<String, dynamic>?) ?? <String, dynamic>{});

  // ---- Equipment ----------------------------------------------------------

  @override
  EquipmentListFacade getEquipmentList() =>
      _equipmentList ??= EquipmentListFacadeImpl(_data);

  @override
  List<EquipmentSetFacade> getEquipmentSets() =>
      List.unmodifiable(_equipmentSets);

  @override
  EquipmentSetFacade getEquippedItems() =>
      _equipmentSets[_activeEquipSetIndex.clamp(0, _equipmentSets.length - 1)];

  @override
  void addEquipmentSet(String name) {
    _equipmentSets.add(EquipmentSetFacadeImpl(name));
    notifyListeners();
  }

  @override
  void removeEquipmentSet(EquipmentSetFacade set) {
    _equipmentSets.remove(set);
    if (_activeEquipSetIndex >= _equipmentSets.length) {
      _activeEquipSetIndex = _equipmentSets.length - 1;
    }
    notifyListeners();
  }

  @override
  void setActiveEquipmentSet(EquipmentSetFacade set) {
    final idx = _equipmentSets.indexOf(set as EquipmentSetFacadeImpl);
    if (idx >= 0) {
      _activeEquipSetIndex = idx;
      notifyListeners();
    }
  }

  // ---- Companions ---------------------------------------------------------

  @override
  CompanionSupportFacade getCompanionSupport() =>
      _companionSupport ??= CompanionSupportFacadeImpl(_data);

  // ---- Spells -------------------------------------------------------------

  @override
  SpellSupportFacade getSpellSupport() =>
      _spellSupport ??= SpellSupportFacadeImpl(_data);

  // ---- Temp bonuses -------------------------------------------------------

  @override
  TempBonusFacade getTempBonusFacade() =>
      _tempBonus ??= TempBonusFacadeImpl(_data, []);

  // ---- HP -----------------------------------------------------------------

  /// Current hit points (may be less than max due to damage).
  @override
  int getHP() => (_data['hp'] as num?)?.toInt() ?? getMaxHP();

  /// Maximum hit points — sum of per-level HP plus CON modifier per level
  /// plus BONUS:HP bonuses (Toughness feat, temporary effects, etc.).
  @override
  int getMaxHP() {
    final levels = _data['classLevels'] as List? ?? [];
    int total = 0;
    for (final l in levels) {
      if (l is Map) total += (l['hp'] as num?)?.toInt() ?? 0;
    }
    if (total > 0) {
      final conMod = _statModByAbb('CON');
      total += conMod * levels.length;
      // Add BONUS:HP|CURRENTMAX and BONUS:HP|BONUS from accumulator
      total += _bonusAcc.totalInt('HP', 'CURRENTMAX') +
               _bonusAcc.totalInt('HP', 'BONUS') +
               _bonusAcc.totalInt('HP', 'WOUNDPOINTS');
      return total.clamp(levels.length, 9999);
    }
    return (_data['maxHp'] as num?)?.toInt() ?? 0;
  }

  @override
  void setHP(int hp) {
    _data['hp'] = hp;
    notifyListeners();
  }

  /// Set the HP gained at level [levelIndex] (0-based).
  void setLevelHP(int levelIndex, int hp) {
    final levels = _data['classLevels'] as List? ?? [];
    if (levelIndex >= 0 && levelIndex < levels.length) {
      if (levels[levelIndex] is Map) {
        (levels[levelIndex] as Map)['hp'] = hp.clamp(1, 999);
        notifyListeners();
      }
    }
  }

  /// Roll random HP for level [levelIndex] using the class's HD.
  /// Returns the rolled value.
  int rollLevelHP(int levelIndex, int hdSize) {
    // Simple pseudo-random using current time — no dart:math import needed.
    final roll = (DateTime.now().microsecondsSinceEpoch % hdSize) + 1;
    setLevelHP(levelIndex, roll);
    return roll;
  }

  // ---- Saving throws -------------------------------------------------------

  @override
  int getFortSave() {
    final acc = _bonusAcc;
    final base = acc.totalIntWithAll('SAVE', 'Fortitude') +
                 acc.totalIntWithAll('SAVE', 'BASE.FORTITUDE');
    // Fallback: if no bonus data, use CON mod + stored value
    if (base == 0) return (_data['fortSave'] as num?)?.toInt() ?? _statModByAbb('CON');
    return base + _statModByAbb('CON');
  }

  @override
  int getRefSave() {
    final acc = _bonusAcc;
    final base = acc.totalIntWithAll('SAVE', 'Reflex') +
                 acc.totalIntWithAll('SAVE', 'BASE.REFLEX');
    if (base == 0) return (_data['refSave'] as num?)?.toInt() ?? _statModByAbb('DEX');
    return base + _statModByAbb('DEX');
  }

  @override
  int getWillSave() {
    final acc = _bonusAcc;
    final base = acc.totalIntWithAll('SAVE', 'Will') +
                 acc.totalIntWithAll('SAVE', 'BASE.WILL');
    if (base == 0) return (_data['willSave'] as num?)?.toInt() ?? _statModByAbb('WIS');
    return base + _statModByAbb('WIS');
  }

  int _statModByAbb(String abb) {
    final scores = _data['statScores'];
    int base = 10;
    if (scores is Map) base = (scores[abb] as num?)?.toInt() ?? 10;
    // Add level ASI gains
    int levelGains = 0;
    final levels = _data['classLevels'] as List? ?? [];
    for (final l in levels) {
      if (l is Map) {
        final gains = l['statGains'] as Map?;
        if (gains != null) {
          levelGains += (gains[abb.toUpperCase()] as num?)?.toInt() ?? 0;
        }
      }
    }
    return ((base + levelGains - 10) / 2).floor();
  }

  // ---- Initiative ---------------------------------------------------------

  @override
  int getInitiative() {
    final dexMod = _statModByAbb('DEX');
    final miscInit = _bonusAcc.totalInt('COMBAT', 'INITIATIVE') +
                     _bonusAcc.totalInt('VAR', 'INITCOMP');
    return dexMod + miscInit;
  }

  // ---- AC -----------------------------------------------------------------

  @override
  int getAC() {
    // 10 base + DEX modifier (capped by armor MAXDEX) + all typed/untyped AC bonuses
    // from the accumulator (armor, shield, natural armor, dodge, deflection, etc.)
    return 10 + _effectiveDexForAC() +
        _bonusAcc.totalIntWithAll('COMBAT', 'AC');
  }

  @override
  int getTouchAC() {
    // Touch AC: base + DEX + dodge + deflection, no armor/natural/shield
    return 10 + _effectiveDexForAC() +
        _bonusAcc.totalInt('COMBAT', 'AC'); // will include dodge/deflect from accumulator
    // A more correct impl would separately sum only typed bonuses; this is acceptable for now
  }

  @override
  int getFlatFootedAC() => getAC() - _effectiveDexForAC().clamp(0, 99);

  /// DEX bonus to AC, capped by the lowest MAXDEX among equipped armor/shields.
  int _effectiveDexForAC() {
    final dexMod = _statModByAbb('DEX');
    if (dexMod <= 0) return dexMod;
    // Find the lowest MAXDEX cap from equipped items
    int? cap;
    try {
      final dataset = _dataset;
      if (dataset != null) {
        final equippedSlots = _data['equippedSlots'] as Map? ?? {};
        final equippedKeys = equippedSlots.values.toSet();
        final equipment = (dataset as dynamic).equipment as List? ?? [];
        for (final item in equipment) {
          final key = (item as dynamic).getKeyName() as String? ?? '';
          if (!equippedKeys.contains(key)) continue;
          final maxDex = (item as dynamic).getMaxDex() as int?;
          if (maxDex != null) {
            cap = cap == null ? maxDex : maxDex < cap ? maxDex : cap;
          }
        }
      }
    } catch (_) {}
    return cap != null ? dexMod.clamp(-99, cap) : dexMod;
  }

  // ---- BAB ----------------------------------------------------------------

  @override
  String getBAB() {
    final bab = _bonusAcc.totalInt('COMBAT', 'BASEAB');
    if (bab == 0) return _str('bab');
    if (bab < 6) return '+$bab';
    final attacks = <String>[];
    int cur = bab;
    while (cur > 0) { attacks.add('+$cur'); cur -= 5; }
    return attacks.join('/');
  }

  /// Miscellaneous to-hit bonus from BONUS:COMBAT|TOHIT (feats, items, etc.)
  int getTohitBonus() =>
      _bonusAcc.totalInt('COMBAT', 'TOHIT') +
      _bonusAcc.totalInt('COMBAT', 'TOHIT.MELEE');

  /// Miscellaneous damage bonus from BONUS:COMBAT|DAMAGE (feats, items, etc.)
  int getDamageBonus() =>
      _bonusAcc.totalInt('COMBAT', 'DAMAGE') +
      _bonusAcc.totalInt('COMBAT', 'DAMAGE.MELEE');

  // ---- Skills -------------------------------------------------------------

  @override
  int getSkillTotal(Object skill) {
    if (_data['skills'] is Map) {
      final key = skill is Map ? skill['name'] as String? : skill.toString();
      return (_data['skills'][key] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  @override
  int getSkillRanks(Object skill) {
    if (_data['skillRanks'] is Map) {
      final key = skill is Map ? skill['name'] as String? : skill.toString();
      return (_data['skillRanks'][key] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  @override
  void setSkillRanks(Object skill, int ranks) {
    final key = skill is Map ? skill['name'] as String? : skill.toString();
    (_data['skillRanks'] ??= <String, dynamic>{})[key] = ranks;
    notifyListeners();
  }

  /// Total armor check penalty from all equipped armor and shields.
  int getArmorCheckPenalty() {
    int total = 0;
    try {
      final dataset = _dataset;
      if (dataset == null) return 0;
      final equippedSlots = _data['equippedSlots'] as Map? ?? {};
      final equippedKeys = equippedSlots.values.toSet();
      final equipment = (dataset as dynamic).equipment as List? ?? [];
      for (final item in equipment) {
        final key = (item as dynamic).getKeyName() as String? ?? '';
        if (!equippedKeys.contains(key)) continue;
        total += (item as dynamic).getAcCheck() as int? ?? 0;
      }
    } catch (_) {}
    return total; // negative or zero
  }

  /// BONUS:SKILL total for a skill (from feats, racial traits, items, etc.)
  /// Also resolves BONUS:SKILL|LIST|N bonuses from CHOOSE-based abilities.
  int getSkillBonus(String displayName, String keyName) {
    final acc = _bonusAcc;
    int total = acc.totalIntWithAll('SKILL', displayName.toUpperCase()) +
                acc.totalIntWithAll('SKILL', keyName.toUpperCase());

    // Resolve LIST bonuses: check abilityChoices for any that match this skill
    try {
      final data = _data;
      final choices = data['abilityChoices'] as Map? ?? {};
      final selectedAbilities = data['selectedAbilities'] as Map? ?? {};
      // Gather all selected keys across categories
      final allSelected = <String>[];
      for (final cat in selectedAbilities.values) {
        if (cat is List) allSelected.addAll(cat.cast<String>());
      }
      for (final storedKey in allSelected) {
        final choice = choices[storedKey] as String?;
        if (choice == null) continue;
        // Does this choice match the skill we're computing?
        if (choice.toLowerCase() != displayName.toLowerCase() &&
            choice.toLowerCase() != keyName.toLowerCase()) continue;
        // Look up the LIST bonus on the ability
        total += _listBonusForAbility(storedKey, 'SKILL');
      }
    } catch (_) {}

    return total;
  }

  int _listBonusForAbility(String storedKey, String category) {
    // storedKey may be "AbilityName|Choice" — base key is before '|'
    final baseKey = storedKey.contains('|')
        ? storedKey.substring(0, storedKey.indexOf('|'))
        : storedKey;

    try {
      final dataset = _dataset;
      if (dataset == null) return 0;
      final abilities = (dataset as dynamic).getAllAbilities() as List? ?? [];
      for (final ab in abilities) {
        if ((ab as dynamic).getKeyName() != baseKey) continue;
        // Sum BONUS:SKILL|LIST|N entries on this ability
        final bonuses = (ab as dynamic)
            .getSafeListFor(ListKey.getConstant<ParsedBonus>('PARSED_BONUS')) as List?;
        if (bonuses == null) return 0;
        int sum = 0;
        for (final b in bonuses) {
          if (b is! ParsedBonus) continue;
          if (b.category != category) continue;
          if (!b.targets.any((t) => t.toUpperCase() == 'LIST')) continue;
          // Evaluate the formula with current character context
          sum += b.evaluate(_buildFormulaCtx()).truncate();
        }
        return sum;
      }
    } catch (_) {}
    return 0;
  }

  FormulaContext _buildFormulaCtx() {
    final statScores = <String, int>{};
    (_data['statScores'] as Map? ?? {}).forEach((k, v) {
      statScores[k.toString().toUpperCase()] = (v as num?)?.toInt() ?? 10;
    });
    final statMods =
        statScores.map((k, v) => MapEntry(k, ((v - 10) / 2).floor()));
    final classLevels = _data['classLevels'] as List? ?? [];
    return FormulaContext(
      statMods: statMods,
      statScores: statScores,
      totalLevel: classLevels.length,
    );
  }

  @override
  int getSkillPointsRemaining() => (_data['skillPointsRemaining'] as num?)?.toInt() ?? 0;

  // ---- Languages ----------------------------------------------------------

  @override
  List<Language> getLanguages() => const [];

  // ---- Funds / wealth -----------------------------------------------------

  @override
  double getFunds() => (_data['funds'] as num?)?.toDouble() ?? 0.0;

  @override
  void setFunds(double funds) {
    _data['funds'] = funds;
    notifyListeners();
  }

  // ---- Notes --------------------------------------------------------------

  @override
  String getNotes() => _str('notes');

  @override
  void setNotes(String notes) => _set('notes', notes);

  // ---- Serialization hints ------------------------------------------------

  @override
  String toString() => getDisplayName();

  // ---- Helpers ------------------------------------------------------------

  String _str(String key) => (_data[key] as String?) ?? '';

  void _set(String key, dynamic value) {
    if (_data[key] == value) return;
    _data[key] = value;
    notifyListeners();
  }

  // ---- Stats (ability scores) -----------------------------------------------

  @override
  int getScoreBase(PCStat stat) {
    final scores = _data['statScores'];
    if (scores is Map) return (scores[stat.getKeyName()] as num?)?.toInt() ?? 10;
    return 10;
  }

  @override
  void setScoreBase(PCStat stat, int score) {
    (_data['statScores'] ??= <String, dynamic>{})[stat.getKeyName()] = score;
    notifyListeners();
  }

  /// Racial (and template) bonus to [stat] from BONUS:STAT tokens.
  /// Reads from the cached bonus map (populated by restoreFromDataset) which
  /// includes bonuses from the full auto-ability chain (e.g. Gnome ~ Rock).
  int getRacialBonus(PCStat stat) {
    // Use the bonus accumulator — it captures BONUS:STAT from all active
    // objects (race, templates, etc.) regardless of which dataset loaded them.
    return _bonusAcc.totalIntWithAll('STAT', stat.getKeyName().toUpperCase());
  }

  /// Total stat gains from level-up ability score increases (PRESTAT in PCG).
  int getLevelStatGains(PCStat stat) {
    int total = 0;
    final levels = _data['classLevels'] as List? ?? [];
    for (final l in levels) {
      if (l is Map) {
        final gains = l['statGains'] as Map?;
        if (gains != null) {
          total += (gains[stat.getKeyName().toUpperCase()] as num?)?.toInt() ?? 0;
        }
      }
    }
    return total;
  }

  /// Base score + all BONUS:STAT contributions + level ASI gains.
  /// Reads from the bonus accumulator so racial, enhancement, inherent, etc.
  /// bonuses are all included regardless of data source (3.5e, PF2e, 5e).
  int getEffectiveScore(PCStat stat) {
    final key = stat.getKeyName().toUpperCase();
    final accBonus = _bonusAcc.totalIntWithAll('STAT', key);
    final base = getScoreBase(stat);
    final lvl = getLevelStatGains(stat);
    return base + accBonus + lvl;
  }

  @override
  int getModTotal(PCStat stat) => ((getEffectiveScore(stat) - 10) / 2).floor();

  // ---- Class levels ---------------------------------------------------------

  @override
  void addCharacterLevels(List<PCClass> classes) {
    final levels = (_data['classLevels'] ??= <dynamic>[]) as List;
    for (final cls in classes) {
      final hd = int.tryParse(cls.getHD()) ?? 8;

      // Class level in this class after adding this level
      final newClsLevel = levels.where(
            (l) => l is Map && l['classKey'] == cls.getKeyName()).length + 1;

      levels.add({
        'className': cls.getDisplayName(),
        'classKey':  cls.getKeyName(),
        'hp': hd,
      });

      // Auto-grant class abilities defined for this level
      final abilities = cls.getAbilitiesAtLevel(newClsLevel);
      if (abilities.isNotEmpty) {
        final selectedAbilities =
            (_data['selectedAbilities'] ??= <String, dynamic>{}) as Map;
        for (final abilName in abilities) {
          // Abilities from class levels go into their category
          // (we store under 'Class Ability' to keep them separate from FEAT)
          final cat = 'Class Ability';
          final list =
              (selectedAbilities[cat] ??= <String>[]) as List;
          if (!list.contains(abilName)) list.add(abilName);
        }
      }
    }
    _rebuild();
    notifyListeners();
  }

  @override
  void removeCharacterLevels(int count) {
    final list = _data['classLevels'];
    if (list is! List) return;
    for (int i = 0; i < count && list.isNotEmpty; i++) list.removeLast();
    _rebuild();
    notifyListeners();
  }

  @override
  int getClassLevel(PCClass c) {
    final list = _data['classLevels'];
    if (list is! List) return 0;
    return list.where((l) => l is Map && l['classKey'] == c.getKeyName()).length;
  }

  /// Compute total levels across all classes.
  int getTotalCharacterLevel() {
    final list = _data['classLevels'];
    return list is List ? list.length : 0;
  }

  /// Get the class level list as a display string e.g. "Fighter 2 / Wizard 1".
  String getClassLevelSummary() {
    final list = _data['classLevels'];
    if (list is! List || list.isEmpty) return '';
    final counts = <String, int>{};
    for (final l in list) {
      if (l is Map) {
        final name = l['className'] as String? ?? '?';
        counts[name] = (counts[name] ?? 0) + 1;
      }
    }
    return counts.entries.map((e) => '${e.key} ${e.value}').join(' / ');
  }

  // ---- Ability / Feat selection -------------------------------------------

  // Selected abilities stored as: _data['selectedAbilities'] = Map<String, List<String>>
  // category key → [abilityKeyName, ...]

  List<String> getSelectedAbilityKeys(String categoryKey) {
    final map = _data['selectedAbilities'];
    if (map is! Map) return [];
    final list = map[categoryKey];
    return list is List ? list.cast<String>() : [];
  }

  bool isAbilitySelected(String categoryKey, String abilityKey) =>
      getSelectedAbilityKeys(categoryKey).contains(abilityKey);

  void addSelectedAbility(String categoryKey, String abilityKey) {
    final map = (_data['selectedAbilities'] ??= <String, dynamic>{}) as Map;
    final list = (map[categoryKey] ??= <String>[]) as List;
    if (!list.contains(abilityKey)) {
      list.add(abilityKey);
      _rebuild();
      notifyListeners();
    }
  }

  void removeSelectedAbility(String categoryKey, String abilityKey) {
    final map = _data['selectedAbilities'];
    if (map is! Map) return;
    final list = map[categoryKey];
    if (list is List && list.remove(abilityKey)) {
      _rebuild();
      notifyListeners();
    }
  }

  // ---- Game mode ----------------------------------------------------------

  String getGameMode() => _str('gameMode');
  void setGameMode(String mode) => _set('gameMode', mode);

  // ---- Alignment string ---------------------------------------------------

  String getAlignmentKey() => _str('alignmentKey');
  void setAlignmentKey(String key) => _set('alignmentKey', key);

  // ---- Deity key ----------------------------------------------------------

  String getDeityKey() => _str('deityKey');
  void setDeityKey(String key) => _set('deityKey', key);

  // ---- Domain keys --------------------------------------------------------

  List<String> getSelectedDomainKeys() {
    final list = _data['selectedDomains'];
    return list is List ? list.cast<String>() : [];
  }

  void addDomainKey(String key) {
    final list = (_data['selectedDomains'] ??= <String>[]) as List;
    if (!list.contains(key)) {
      list.add(key);
      _grantDomainBenefits(key);
      _rebuild();
      notifyListeners();
    }
  }

  void removeDomainKey(String key) {
    final list = _data['selectedDomains'];
    if (list is List && list.remove(key)) {
      _revokeDomainBenefits(key);
      _rebuild();
      notifyListeners();
    }
  }

  /// Auto-grant abilities and domain spells when a domain is selected.
  void _grantDomainBenefits(String domainKey) {
    try {
      final dataset = _dataset;
      if (dataset == null) return;
      final domains = (dataset as dynamic).domains as List? ?? [];
      for (final d in domains) {
        if ((d as dynamic).getKeyName() != domainKey) continue;

        // Grant ABILITY:...|AUTOMATIC| entries from domain
        final autoAbilities = (d as dynamic).getAutoGrantedAbilities()
            as List<String>? ?? [];
        if (autoAbilities.isNotEmpty) {
          final selectedAbilities =
              (_data['selectedAbilities'] ??= <String, dynamic>{}) as Map;
          for (final abilName in autoAbilities) {
            final cat = 'Special Ability';
            final catList = (selectedAbilities[cat] ??= <String>[]) as List;
            if (!catList.contains(abilName)) catList.add(abilName);
          }
        }

        // Store domain spells in domainSpells map: domainKey → {level: spellName}
        final spellMap = (d as dynamic).getDomainSpellMap()
            as Map<int, String>? ?? {};
        if (spellMap.isNotEmpty) {
          final domainSpells =
              (_data['domainSpells'] ??= <String, dynamic>{}) as Map;
          domainSpells[domainKey] = {
            for (final e in spellMap.entries) '${e.key}': e.value,
          };
        }
        break;
      }
    } catch (_) {}
  }

  /// Remove auto-granted abilities when a domain is removed.
  void _revokeDomainBenefits(String domainKey) {
    try {
      final dataset = _dataset;
      if (dataset == null) return;
      final domains = (dataset as dynamic).domains as List? ?? [];
      for (final d in domains) {
        if ((d as dynamic).getKeyName() != domainKey) continue;

        final autoAbilities = (d as dynamic).getAutoGrantedAbilities()
            as List<String>? ?? [];
        if (autoAbilities.isNotEmpty) {
          final selectedAbilities = _data['selectedAbilities'] as Map? ?? {};
          for (final abilName in autoAbilities) {
            final catList = selectedAbilities['Special Ability'] as List?;
            catList?.remove(abilName);
          }
        }

        // Remove domain spells
        (_data['domainSpells'] as Map?)?.remove(domainKey);
        break;
      }
    } catch (_) {}
  }

  /// All domain spells for selected domains: list of {domain, level, spell}.
  List<Map<String, dynamic>> getDomainSpells() {
    final result = <Map<String, dynamic>>[];
    final domainSpells = _data['domainSpells'] as Map? ?? {};
    for (final entry in domainSpells.entries) {
      final domainKey = entry.key as String;
      final spells = entry.value as Map? ?? {};
      for (final se in spells.entries) {
        final level = int.tryParse(se.key.toString()) ?? 0;
        result.add({
          'domain': domainKey,
          'level': level,
          'spell': se.value as String? ?? '',
        });
      }
    }
    result.sort((a, b) => (a['level'] as int).compareTo(b['level'] as int));
    return result;
  }

  // ---- Template keys -------------------------------------------------------

  List<String> getAppliedTemplateKeys() {
    final list = _data['appliedTemplates'];
    return list is List ? list.cast<String>() : [];
  }

  void applyTemplateKey(String key) {
    final list = (_data['appliedTemplates'] ??= <String>[]) as List;
    if (!list.contains(key)) { list.add(key); _rebuild(); notifyListeners(); }
  }

  void removeTemplateKey(String key) {
    final list = _data['appliedTemplates'];
    if (list is List && list.remove(key)) { _rebuild(); notifyListeners(); }
  }

  // ---- DR / SR ------------------------------------------------------------

  List<String> getDRList() {
    try {
      final raceObj = _raceRef.get();
      if (raceObj == null) return const [];
      final list = (raceObj as dynamic)
          .getSafeListFor(ListKey.getConstant<String>('DR_LIST')) as List?;
      return list?.cast<String>() ?? const [];
    } catch (_) { return const []; }
  }

  int getSR() {
    final fromAcc = _bonusAcc.totalInt('SAVE', 'SR');
    if (fromAcc > 0) return fromAcc;
    try {
      final raceObj = _raceRef.get();
      if (raceObj == null) return 0;
      final srStr = (raceObj as dynamic)
          .getSafeObject(CDOMObjectKey.getConstant<String>('SR_FORMULA')) as String?;
      return int.tryParse(srStr ?? '') ?? 0;
    } catch (_) { return 0; }
  }

  // ---- Race traits --------------------------------------------------------

  String getRaceSize() => _data['raceSize'] as String? ?? 'M';

  Map<String, int> getRaceSpeeds() {
    final m = _data['raceSpeeds'];
    if (m is Map) return Map<String, int>.from(m);
    return const {'Walk': 30};
  }

  List<String> getRaceBonusLanguages() {
    final l = _data['raceBonusLanguages'];
    if (l is List) return l.cast<String>();
    return const [];
  }

  // ---- Physical appearance ------------------------------------------------

  int getHeight() => (_data['height'] as num?)?.toInt() ?? 0;
  void setHeight(int h) { _data['height'] = h; notifyListeners(); }

  int getWeight() => (_data['weight'] as num?)?.toInt() ?? 0;
  void setWeight(int w) { _data['weight'] = w; notifyListeners(); }

  String getEyeColor() => _str('eyeColor');
  void setEyeColor(String v) => _set('eyeColor', v);

  String getHairColor() => _str('hairColor');
  void setHairColor(String v) => _set('hairColor', v);

  String getSkinColor() => _str('skinColor');
  void setSkinColor(String v) => _set('skinColor', v);

  // ---- Biography ----------------------------------------------------------

  String getBiography() => _str('biography');
  void setBiography(String text) => _set('biography', text);

  String getAppearance() => _str('appearance');
  void setAppearance(String text) => _set('appearance', text);

  // ---- Serialise / deserialise to Map (for save / load) -------------------

  /// Returns the live data map directly so callers can mutate lists in-place.
  Map<String, dynamic> toJson() => _data;

  /// Reconstruct live object references (race, alignment, deity) from
  /// [dataset] after loading a character from disk.
  void restoreFromDataset(dynamic dataset) {
    if (dataset == null) return;
    try {
      final raceKey = _data['raceKey'] as String? ?? '';
      if (raceKey.isNotEmpty) {
        final race = (dataset as dynamic).findRace(raceKey);
        if (race != null) {
          _raceRef.set(race);
          _cacheRacialBonuses(race, dataset);
          // Restore size/speed/language data without re-adding duplicate languages
          // (they're already in _data from the saved PCG file)
          try {
            final size = (race as dynamic).getSize() as String? ?? '';
            if (size.isNotEmpty) _data['raceSize'] ??= size;
            final speeds = (race as dynamic).getMoveSpeeds() as Map<String, int>?;
            if (speeds != null && speeds.isNotEmpty) _data['raceSpeeds'] ??= speeds;
            _data['raceBonusLanguages'] =
                (race as dynamic).getBonusLanguageChoices() as List<String>? ?? [];
          } catch (_) {}
        }
      }
    } catch (_) {}
    try {
      final alignKey = _data['alignmentKey'] as String? ?? '';
      if (alignKey.isNotEmpty) {
        final align = (dataset as dynamic).findAlignment(alignKey);
        if (align != null) _alignmentRef.set(align);
      }
    } catch (_) {}
    try {
      final deityKey = _data['deityKey'] as String? ?? '';
      if (deityKey.isNotEmpty) {
        final deity = (dataset as dynamic).findDeity(deityKey);
        if (deity != null) _deityRef.set(deity);
      }
    } catch (_) {}

    // Cache dataset and rebuild the bonus accumulator with all loaded data.
    _dataset = dataset;

    // Rebuild abilityChoices from stored "Key|Choice" entries so LIST bonuses
    // resolve correctly after loading a saved character.
    _rebuildChoicesMap();

    rebuildBonuses(dataset);
  }

  void _rebuildChoicesMap() {
    final selectedAbilities = _data['selectedAbilities'] as Map? ?? {};
    final choices = (_data['abilityChoices'] ??= <String, String>{}) as Map;
    choices.clear();
    for (final cat in selectedAbilities.values) {
      if (cat is! List) continue;
      for (final stored in cat) {
        final s = stored.toString();
        final pipe = s.indexOf('|');
        if (pipe > 0) {
          choices[s] = s.substring(pipe + 1);
        }
      }
    }
  }

  /// Called after any mutation that could affect bonus totals.
  void _rebuild() {
    if (_dataset != null) rebuildBonuses(_dataset);
  }

  /// Walk the automatic-ability chain of [obj] (race or ability) and accumulate
  /// all STAT_BONUS values into [_data]['racialStatBonuses'].
  void _cacheRacialBonuses(dynamic obj, dynamic dataset, [Set<String>? seen]) {
    seen ??= {};

    // Collect direct STAT_BONUS entries on this object.
    try {
      final bonusList = (obj as dynamic)
          .getSafeListFor(ListKey.getConstant<String>('STAT_BONUS')) as List?;
      if (bonusList != null) {
        final cache = (_data['racialStatBonuses'] ??= <String, int>{}) as Map;
        for (final b in bonusList) {
          if (b is String) {
            final idx = b.indexOf(':');
            if (idx > 0) {
              final stat  = b.substring(0, idx).toUpperCase();
              final bonus = int.tryParse(b.substring(idx + 1)) ?? 0;
              cache[stat] = (cache[stat] as int? ?? 0) + bonus;
            }
          }
        }
      }
    } catch (_) {}

    // Recurse into AUTO_ABILITIES.
    try {
      final autoAbilities = (obj as dynamic)
          .getSafeListFor(ListKey.getConstant<String>('AUTO_ABILITIES')) as List?;
      if (autoAbilities != null) {
        for (final name in autoAbilities) {
          if (name is String && seen.add(name)) {
            try {
              final ability = (dataset as dynamic).findAbilityByName(name);
              if (ability != null) _cacheRacialBonuses(ability, dataset, seen);
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
  }

  /// Named variable resolved from DEFINE/BONUS:VAR processing.
  double getVariable(String name) {
    final vars = _data['charVariables'];
    if (vars is Map) {
      return (vars[name] as num?)?.toDouble() ??
             (vars[name.toUpperCase()] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  /// Extra feats from BONUS:ABILITYPOOL|FEAT|N (e.g. from feats or race).
  int getFeatPoolBonus() => _bonusAcc.totalInt('ABILITYPOOL', 'FEAT');

  /// Bonus to skill points per level from BONUS:MODSKILLPOINTS (e.g. Pathfinder INT bonus feats).
  int getSkillPointBonus() => _bonusAcc.totalInt('MODSKILLPOINTS', 'NUMBER');

  /// Spell save DC for a spell of [spellLevel] using the primary spellcasting stat.
  int getSpellSaveDC(int spellLevel, [String? spellcastingClassKey]) {
    String spellStat = 'INT';
    try {
      final dataset = _dataset;
      if (dataset != null && spellcastingClassKey != null) {
        final classes = (dataset as dynamic).classes as List? ?? [];
        for (final cls in classes) {
          if ((cls as dynamic).getKeyName() == spellcastingClassKey) {
            spellStat = (cls as dynamic).getSpellStat() as String? ?? 'INT';
            if (spellStat.isEmpty) spellStat = 'INT';
            break;
          }
        }
      }
    } catch (_) {}
    return 10 + spellLevel + _statModByAbb(spellStat);
  }

  /// Natural attacks from race (name:count:damage strings).
  /// Innate spells collected from race and its AUTO_ABILITIES chain.
  List<String> getInnateSpells() {
    final result = <String>[];
    _collectChainInnateSpells(_raceRef.get(), _dataset, result, {});
    return result;
  }

  void _collectChainInnateSpells(
      dynamic obj, dynamic dataset, List<String> out, Set<String> seen) {
    if (obj == null) return;
    try {
      final list = (obj as dynamic)
          .getSafeListFor(ListKey.getConstant<String>('INNATE_SPELLS')) as List?;
      if (list != null) for (final s in list) { if (s is String) out.add(s); }
    } catch (_) {}
    try {
      final auto = (obj as dynamic)
          .getSafeListFor(ListKey.getConstant<String>('AUTO_ABILITIES')) as List?;
      if (auto != null) {
        for (final name in auto) {
          if (name is String && seen.add(name) && dataset != null) {
            final ability = (dataset as dynamic).findAbilityByName(name);
            if (ability != null) _collectChainInnateSpells(ability, dataset, out, seen);
          }
        }
      }
    } catch (_) {}
  }

  List<String> getNaturalAttacks() {
    final attacks = <String>{};
    try {
      final race = _raceRef.get();
      if (race != null) {
        // Direct race NATURAL_ATTACKS
        final direct = (race as dynamic).getSafeListFor(
            ListKey.getConstant<String>('NATURAL_ATTACKS')) as List?;
        if (direct != null) for (final a in direct) { if (a is String) attacks.add(a); }
        // Also walk the ability chain for granted natural attacks
        _collectChainNaturalAttacks(race, _dataset, attacks, {});
      }
    } catch (_) {}
    return attacks.toList();
  }

  void _collectChainNaturalAttacks(
      dynamic obj, dynamic dataset, Set<String> out, Set<String> seen) {
    if (obj == null) return;
    try {
      final list = (obj as dynamic).getSafeListFor(
          ListKey.getConstant<String>('NATURAL_ATTACKS')) as List?;
      if (list != null) for (final a in list) { if (a is String) out.add(a); }
    } catch (_) {}
    try {
      final auto = (obj as dynamic).getSafeListFor(
          ListKey.getConstant<String>('AUTO_ABILITIES')) as List?;
      if (auto != null) {
        for (final name in auto) {
          if (name is String && seen.add(name) && dataset != null) {
            final ability = (dataset as dynamic).findAbilityByName(name);
            if (ability != null) _collectChainNaturalAttacks(ability, dataset, out, seen);
          }
        }
      }
    } catch (_) {}
  }

  /// Vision types from race (and eventually templates).
  List<String> getVisionTypes() {
    final result = <String>{};
    try {
      final race = _raceRef.get();
      if (race != null) {
        final visions = (race as dynamic).getVisionTypes() as List<String>? ?? [];
        result.addAll(visions);
      }
    } catch (_) {}
    return result.toList();
  }

  /// BAB as a plain integer (first attack only).
  int getBABAsInt() => _bonusAcc.totalInt('COMBAT', 'BASEAB');

  /// Stat modifier by abbreviation string (e.g. 'STR', 'DEX').
  int getStatModByAbb(String abb) => _statModByAbb(abb);

  // ---- Bonus engine --------------------------------------------------------

  /// Rebuild the bonus accumulator from all currently active objects.
  /// Call after loading a character, changing race/class/feats/equipment.
  void rebuildBonuses(dynamic dataset) {
    if (dataset == null) return;
    final allBonuses = <ParsedBonus>[];

    // Helper: collect ParsedBonus from any CDOMObject
    void collect(dynamic obj) {
      try {
        final list = (obj as dynamic)
            .getSafeListFor(ListKey.getConstant<ParsedBonus>('PARSED_BONUS')) as List?;
        if (list != null) {
          for (final b in list) {
            if (b is ParsedBonus) allBonuses.add(b);
          }
        }
      } catch (_) {}
    }

    // Race
    final raceObj = _raceRef.get();
    if (raceObj != null) {
      collect(raceObj);
    }

    // Also walk AUTO_ABILITIES chain for race (racial abilities with bonuses)
    _collectAbilityChainBonuses(raceObj, dataset, allBonuses, {});

    // Class objects — evaluated per-class so classlevel() returns the right value.
    // We don't collect class bonuses into allBonuses (which uses a single context);
    // instead we evaluate them immediately with a per-class FormulaContext.
    final classLevels = _data['classLevels'] as List? ?? [];
    final counts = <String, int>{};
    for (final l in classLevels) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        counts[k] = (counts[k] ?? 0) + 1;
      }
    }
    // Collect class-specific bonuses separately — to be applied below with
    // per-class level context.
    final classBonuses = <String, List<ParsedBonus>>{}; // classKey → bonuses
    try {
      final classes = (dataset as dynamic).classes as List? ?? [];
      for (final cls in classes) {
        final key = (cls as dynamic).getKeyName() as String? ?? '';
        final lvl = counts[key] ?? 0;
        if (lvl == 0) continue;
        final bonuses = <ParsedBonus>[];
        try {
          final list = (cls as dynamic)
              .getSafeListFor(ListKey.getConstant<ParsedBonus>('PARSED_BONUS')) as List?;
          if (list != null) {
            for (final b in list) { if (b is ParsedBonus) bonuses.add(b); }
          }
        } catch (_) {}
        if (bonuses.isNotEmpty) classBonuses[key] = bonuses;
      }
    } catch (_) {}

    // Selected feats / abilities
    final selectedAbilities = _data['selectedAbilities'] as Map? ?? {};
    try {
      final allAbilities = (dataset as dynamic).getAllAbilities() as List? ?? [];
      for (final cat in selectedAbilities.keys) {
        final keys = (selectedAbilities[cat] as List?)?.cast<String>() ?? [];
        for (final key in keys) {
          for (final ab in allAbilities) {
            if ((ab as dynamic).getKeyName() == key) { collect(ab); break; }
          }
        }
      }
    } catch (_) {}

    // Applied templates
    final appliedTemplateKeys = _data['appliedTemplates'] as List? ?? [];
    try {
      final templates = (dataset as dynamic).templates as List? ?? [];
      for (final tpl in templates) {
        final key = (tpl as dynamic).getKeyName() as String? ?? '';
        if (appliedTemplateKeys.contains(key)) collect(tpl);
      }
    } catch (_) {}

    // Equipped items + their EQMOD bonuses
    final equippedSlots = _data['equippedSlots'] as Map? ?? {};
    final equippedKeys = equippedSlots.values.toSet();
    try {
      final equipment = (dataset as dynamic).equipment as List? ?? [];
      // Build a key→object map for EQMOD lookups (EQMODs are also Equipment)
      final equipByKey = <String, dynamic>{};
      for (final item in equipment) {
        final k = (item as dynamic).getKeyName() as String? ?? '';
        if (k.isNotEmpty) equipByKey[k] = item;
      }

      for (final item in equipment) {
        final key = (item as dynamic).getKeyName() as String? ?? '';
        if (!equippedKeys.contains(key)) continue;
        collect(item);
        // Collect bonuses from each EQMOD applied to this item
        try {
          final eqmodKeys = (item as dynamic)
              .getSafeListFor(ListKey.getConstant<String>('EQMOD_KEYS')) as List?;
          if (eqmodKeys != null) {
            for (final mk in eqmodKeys) {
              if (mk is String) {
                final mod = equipByKey[mk];
                if (mod != null) collect(mod);
              }
            }
          }
        } catch (_) {}
      }
    } catch (_) {}

    // ---- Pass 1: Collect DEFINE variables from all active objects ----
    final charVars = <String, double>{};

    void collectDefines(dynamic obj) {
      try {
        final defines = (obj as dynamic)
            .getSafeListFor(ListKey.getConstant<String>('VAR_DEFINES')) as List?;
        if (defines != null) {
          for (final d in defines) {
            if (d is String) {
              final eq = d.indexOf('=');
              if (eq > 0) {
                final varName = d.substring(0, eq).trim();
                final defVal = double.tryParse(d.substring(eq + 1).trim()) ?? 0.0;
                charVars.putIfAbsent(varName, () => defVal);
              }
            }
          }
        }
      } catch (_) {}
    }

    if (raceObj != null) collectDefines(raceObj);
    try {
      final classes = (dataset as dynamic).classes as List? ?? [];
      for (final cls in classes) {
        if ((counts[(cls as dynamic).getKeyName() as String? ?? ''] ?? 0) > 0) {
          collectDefines(cls);
        }
      }
    } catch (_) {}
    try {
      final allAbilities = (dataset as dynamic).getAllAbilities() as List? ?? [];
      for (final cat in selectedAbilities.values) {
        if (cat is! List) continue;
        for (final key in cat.cast<String>()) {
          for (final ab in allAbilities) {
            if ((ab as dynamic).getKeyName() == key) { collectDefines(ab); break; }
          }
        }
      }
    } catch (_) {}

    // ---- Pass 2: Evaluate BONUS:VAR to accumulate variable values ----
    final statScores = <String, int>{};
    final scoreMap = _data['statScores'] as Map? ?? {};
    scoreMap.forEach((k, v) {
      statScores[k.toString().toUpperCase()] = (v as num?)?.toInt() ?? 10;
    });
    final statMods = statScores.map((k, v) => MapEntry(k, ((v - 10) / 2).floor()));

    // Quick formula context with current stats + initial vars for VAR resolution
    final varFormulaCtx = FormulaContext(
      statMods: statMods, statScores: statScores,
      totalLevel: classLevels.length, variables: charVars,
    );
    for (final bonus in allBonuses) {
      if (bonus.category != 'VAR') continue;
      final val = bonus.evaluate(varFormulaCtx);
      for (final target in bonus.targets) {
        charVars[target] = (charVars[target] ?? 0.0) + val;
      }
    }
    // Also evaluate VAR bonuses from class objects (per-class level context)
    try {
      final classes = (dataset as dynamic).classes as List? ?? [];
      for (final cls in classes) {
        final clsKey = (cls as dynamic).getKeyName() as String? ?? '';
        final clsLvl = counts[clsKey] ?? 0;
        if (clsLvl == 0) continue;
        final clsVarCtx = FormulaContext(
          statMods: statMods, statScores: statScores,
          totalLevel: classLevels.length, variables: charVars,
          currentClassLevel: clsLvl,
        );
        final bonusList = (cls as dynamic)
            .getSafeListFor(ListKey.getConstant<ParsedBonus>('PARSED_BONUS')) as List?;
        if (bonusList == null) continue;
        for (final b in bonusList) {
          if (b is! ParsedBonus || b.category != 'VAR') continue;
          final val = b.evaluate(clsVarCtx);
          for (final t in b.targets) {
            charVars[t] = (charVars[t] ?? 0.0) + val;
          }
        }
      }
    } catch (_) {}

    // Expose class levels as CL.<ClassName> variables for PRECLASS evaluation
    for (final entry in counts.entries) {
      charVars['CL.${entry.key}'] = entry.value.toDouble();
    }
    // Also expose by display name for convenience
    try {
      final classes = (dataset as dynamic).classes as List? ?? [];
      for (final cls in classes) {
        final key = (cls as dynamic).getKeyName() as String? ?? '';
        final name = (cls as dynamic).getDisplayName() as String? ?? '';
        final lvl = counts[key] ?? 0;
        if (lvl > 0 && name.isNotEmpty && name != key) {
          charVars['CL.$name'] = lvl.toDouble();
        }
      }
    } catch (_) {}

    // Store resolved variables for getVariable() access
    _data['charVariables'] = Map<String, double>.from(charVars);

    final classLevelCounts = counts.map((k, v) => MapEntry(k, v));

    // Collect class skill names for PrereqContext (PRECSKILL evaluation)
    final classSkillSet = <String>{};
    try {
      final classes = (dataset as dynamic).classes as List? ?? [];
      for (final cls in classes) {
        final key = (cls as dynamic).getKeyName() as String? ?? '';
        if ((counts[key] ?? 0) == 0) continue;
        // From CSKILL token → CLASS_SKILLS list
        final skillList = (cls as dynamic)
            .getSafeListFor(ListKey.getConstant<String>('CLASS_SKILLS')) as List?;
        if (skillList != null) {
          for (final s in skillList) { if (s is String) classSkillSet.add(s.toLowerCase()); }
        }
      }
    } catch (_) {}
    // Also add ADD:CLASSSKILLS from selected abilities
    try {
      final allAbilities = (dataset as dynamic).getAllAbilities() as List? ?? [];
      final selectedAbilityKeys = <String>{};
      for (final cat in selectedAbilities.values) {
        if (cat is List) {
          for (final k in cat) {
            final base = k.toString().contains('|') ? k.toString().split('|').first : k.toString();
            selectedAbilityKeys.add(base);
          }
        }
      }
      for (final ab in allAbilities) {
        if (!selectedAbilityKeys.contains((ab as dynamic).getKeyName())) continue;
        final addSkills = (ab as dynamic)
            .getSafeListFor(ListKey.getConstant<String>('ADD_CLASS_SKILLS')) as List?;
        if (addSkills != null) {
          for (final s in addSkills) { if (s is String) classSkillSet.add(s.toLowerCase()); }
        }
      }
    } catch (_) {}

    final state = CharacterBonusState(
      statMods: statMods,
      statScores: statScores,
      totalLevel: classLevels.length,
      classLevelCounts: classLevelCounts,
      definedVars: charVars,
      alignmentKey: _str('alignmentKey'),
      raceKey: _str('raceKey'),
      objectTypes: const [],
      classSkillNames: classSkillSet.toList(),
      selectedAbilityKeys: {
        for (final e in selectedAbilities.entries)
          e.key.toString(): (e.value as List?)?.cast<String>() ?? []
      },
      skillRanks: {
        for (final e in ((_data['skillRanks'] as Map?) ?? {}).entries)
          e.key.toString().toLowerCase(): (e.value as num?)?.toDouble() ?? 0.0
      },
    );

    _bonusAcc = CharacterBonusEngine.compute(state, allBonuses);

    // Evaluate class-specific bonuses with per-class level context.
    // This ensures classlevel("APPLIEDAS=NONEPIC") returns the correct
    // per-class level (e.g. Fighter 3 contributes BAB 3, not total level).
    for (final entry in classBonuses.entries) {
      final clsKey = entry.key;
      final clsLvl = counts[clsKey] ?? 0;
      if (clsLvl == 0) continue;

      final clsFormulaCtx = FormulaContext(
        statMods:           statMods,
        statScores:         statScores,
        totalLevel:         classLevels.length,
        classLevels:        classLevelCounts,
        variables:          charVars,
        currentClassLevel:  clsLvl,
      );

      final prereqCtx = _SimplePrereqCtxFacade(
        alignmentKey: _str('alignmentKey'),
        raceKey: _str('raceKey'),
        totalLevel: classLevels.length,
        statMods: statMods,
        statScores: statScores,
        selectedAbilities: {
          for (final e in selectedAbilities.entries)
            e.key.toString(): (e.value as List?)?.cast<String>() ?? []
        },
        skillRanks: {
          for (final e in ((_data['skillRanks'] as Map?) ?? {}).entries)
            e.key.toString().toLowerCase(): (e.value as num?)?.toDouble() ?? 0.0
        },
      );

      for (final bonus in entry.value) {
        if (!bonus.checkPrereqs(prereqCtx)) continue;
        final value = bonus.evaluate(clsFormulaCtx);
        _bonusAcc.add(bonus, value);
      }
    }

    // Apply active temporary bonuses (spell effects, rage, etc.)
    _applyTempBonuses();

    _bonusDirty = false;
  }

  void _applyTempBonuses() {
    final tempBonuses = _data['tempBonuses'] as List? ?? [];
    for (final entry in tempBonuses) {
      if (entry is! Map) continue;
      final active = entry['active'] as bool? ?? true;
      if (!active) continue;

      final category = (entry['category'] as String? ?? 'COMBAT').toUpperCase();
      final target   = (entry['target']   as String? ?? 'AC').toUpperCase();
      final formula  = (entry['value']    as String? ?? '0').replaceAll('+', '');
      final bonusType = (entry['bonusType'] as String? ?? '');

      final value = double.tryParse(formula) ?? 0.0;
      if (value == 0) continue;

      final tempBonus = ParsedBonus(
        category: category,
        targets: [target],
        formula: formula,
        bonusType: bonusType,
        stack: bonusType.isEmpty ? BonusStack.normal : BonusStack.normal,
      );
      _bonusAcc.add(tempBonus, value);
    }
  }

  void _collectAbilityChainBonuses(
    dynamic obj,
    dynamic dataset,
    List<ParsedBonus> out,
    Set<String> seen,
  ) {
    if (obj == null) return;
    try {
      final autoAbilities = (obj as dynamic)
          .getSafeListFor(ListKey.getConstant<String>('AUTO_ABILITIES')) as List?;
      if (autoAbilities != null) {
        for (final name in autoAbilities) {
          if (name is String && seen.add(name)) {
            final ability = (dataset as dynamic).findAbilityByName(name);
            if (ability != null) {
              try {
                final list = (ability as dynamic)
                    .getSafeListFor(ListKey.getConstant<ParsedBonus>('PARSED_BONUS')) as List?;
                if (list != null) {
                  for (final b in list) { if (b is ParsedBonus) out.add(b); }
                }
              } catch (_) {}
              _collectAbilityChainBonuses(ability, dataset, out, seen);
            }
          }
        }
      }
    } catch (_) {}
  }

  void _collectChainLanguages(
    dynamic obj, dynamic dataset,
    Set<String> autoOut, Set<String> bonusOut, Set<String> seen,
  ) {
    if (obj == null) return;
    try {
      final auto = (obj as dynamic).getSafeListFor(ListKey.getConstant<String>('AUTO_LANG')) as List?;
      if (auto != null) for (final l in auto) { if (l is String && l.isNotEmpty && !l.startsWith('%')) autoOut.add(l); }
      final bonus = (obj as dynamic).getSafeListFor(ListKey.getConstant<String>('LANG_BONUS')) as List?;
      if (bonus != null) for (final l in bonus) { if (l is String && l.isNotEmpty) bonusOut.add(l); }
    } catch (_) {}
    try {
      final abilities = (obj as dynamic).getSafeListFor(ListKey.getConstant<String>('AUTO_ABILITIES')) as List?;
      if (abilities != null) {
        for (final name in abilities) {
          if (name is String && seen.add(name) && dataset != null) {
            final ability = (dataset as dynamic).findAbilityByName(name);
            if (ability != null) _collectChainLanguages(ability, dataset, autoOut, bonusOut, seen);
          }
        }
      }
    } catch (_) {}
  }

  static CharacterFacadeImpl fromJson(Map<String, dynamic> json) =>
      CharacterFacadeImpl(json);

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

// ---------------------------------------------------------------------------
// Minimal PrereqContext used inside rebuildBonuses for class bonus evaluation
// ---------------------------------------------------------------------------

class _SimplePrereqCtxFacade implements PrereqContext {
  @override final String alignmentKey;
  @override final String raceKey;
  @override final int totalLevel;
  @override final List<String> objectTypes = const [];
  @override final List<String> classSkillNames = const [];
  final Map<String, int> _statMods;
  final Map<String, int> _statScores;
  final Map<String, List<String>> _selectedAbilities;
  final Map<String, double> _skillRanks;

  _SimplePrereqCtxFacade({
    required this.alignmentKey,
    required this.raceKey,
    required this.totalLevel,
    required Map<String, int> statMods,
    required Map<String, int> statScores,
    required Map<String, List<String>> selectedAbilities,
    required Map<String, double> skillRanks,
  })  : _statMods = statMods,
        _statScores = statScores,
        _selectedAbilities = selectedAbilities,
        _skillRanks = skillRanks;

  @override
  List<String> selectedAbilityKeys([String? category]) {
    if (category == null) return _selectedAbilities.values.expand((l) => l).toList();
    return _selectedAbilities[category] ?? [];
  }

  @override
  double getVariable(String name) {
    final upper = name.toUpperCase();
    if (_statMods.containsKey(upper)) return _statMods[upper]!.toDouble();
    if (upper.endsWith('SCORE')) {
      final abb = upper.substring(0, upper.length - 5);
      if (_statScores.containsKey(abb)) return _statScores[abb]!.toDouble();
    }
    if (upper == 'TL' || upper == 'CL') return totalLevel.toDouble();
    return 0.0;
  }

  @override
  double getSkillRanks(String skillName) =>
      _skillRanks[skillName.toLowerCase()] ?? 0.0;

  @override
  int getStatScore(String statAbb) =>
      _statScores[statAbb.toUpperCase()] ?? 10;

  @override String get deityKey => '';
  @override List<String> get domainKeys => const [];
  @override List<String> get languageNames => const [];
  @override List<String> get visionTypes => const [];
  @override List<String> get templateKeys => const [];
  @override List<String> get weaponProficiencies => const [];
  @override String get sizeKey => 'M';
}
