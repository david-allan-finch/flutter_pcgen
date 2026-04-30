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
import 'package:flutter_pcgen/src/core/language.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/rules/parsed_bonus.dart';
import 'package:flutter_pcgen/src/rules/bonus_accumulator.dart';
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
    _rebuild();
    notifyListeners();
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

  /// Maximum hit points — sum of per-level HP values plus CON modifier per level.
  @override
  int getMaxHP() {
    final levels = _data['classLevels'] as List? ?? [];
    int total = 0;
    for (final l in levels) {
      if (l is Map) total += (l['hp'] as num?)?.toInt() ?? 0;
    }
    if (total > 0) {
      // Add CON modifier × number of levels
      final conMod = _statModByAbb('CON');
      total += conMod * levels.length;
      return total.clamp(levels.length, 9999); // minimum 1 HP per level
    }
    // Fall back to stored maxHp if no per-level data yet.
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
    final acc = _bonusAcc;
    // Base 10 + all COMBAT|AC bonuses (armor, dex/ability, size, natural, deflection, dodge...)
    final fromBonuses = acc.totalInt('COMBAT', 'AC');
    if (fromBonuses == 0) {
      // No bonus data loaded yet — return simple 10+DEX
      return 10 + _statModByAbb('DEX');
    }
    return fromBonuses;
  }

  @override
  int getTouchAC() {
    // Touch AC excludes armor and natural armor type bonuses
    // For now approximate as 10 + DEX + dodge + deflection
    final dex = _statModByAbb('DEX');
    final dodge = _bonusAcc.totalInt('COMBAT', 'AC'); // will overcount but acceptable fallback
    return 10 + dex;
  }

  @override
  int getFlatFootedAC() {
    // Flat-footed excludes DEX and dodge
    return getAC() - _statModByAbb('DEX').clamp(0, 99);
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

  /// BONUS:SKILL total for a skill (from feats, racial traits, items, etc.)
  int getSkillBonus(String displayName, String keyName) {
    final acc = _bonusAcc;
    // Try both display name and key name as targets
    return acc.totalIntWithAll('SKILL', displayName.toUpperCase()) +
           acc.totalIntWithAll('SKILL', keyName.toUpperCase());
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
    // Prefer the pre-computed cache built by _cacheRacialBonuses.
    final cache = _data['racialStatBonuses'] as Map?;
    if (cache != null && cache.isNotEmpty) {
      return (cache[stat.getKeyName().toUpperCase()] as int?) ?? 0;
    }
    // Fallback: read STAT_BONUS directly from the race object (races that have
    // BONUS:STAT directly rather than through an ability chain).
    int total = 0;
    final race = _raceRef.get();
    if (race != null) {
      try {
        final bonusList = (race as dynamic)
            .getSafeListFor(ListKey.getConstant<String>('STAT_BONUS')) as List?;
        if (bonusList != null) {
          for (final b in bonusList) {
            if (b is String) {
              final idx = b.indexOf(':');
              if (idx > 0 &&
                  b.substring(0, idx).toUpperCase() ==
                      stat.getKeyName().toUpperCase()) {
                total += int.tryParse(b.substring(idx + 1)) ?? 0;
              }
            }
          }
        }
      } catch (_) {}
    }
    return total;
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

  /// Base score + racial bonuses + level ASI gains.
  int getEffectiveScore(PCStat stat) =>
      getScoreBase(stat) + getRacialBonus(stat) + getLevelStatGains(stat);

  @override
  int getModTotal(PCStat stat) => ((getEffectiveScore(stat) - 10) / 2).floor();

  // ---- Class levels ---------------------------------------------------------

  @override
  void addCharacterLevels(List<PCClass> classes) {
    final levels = (_data['classLevels'] ??= <dynamic>[]) as List;
    for (final cls in classes) {
      final hd = int.tryParse(cls.getHD()) ?? 8;
      levels.add({
        'className': cls.getDisplayName(),
        'classKey':  cls.getKeyName(),
        'hp': hd,
      });
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
    if (!list.contains(key)) { list.add(key); notifyListeners(); }
  }

  void removeDomainKey(String key) {
    final list = _data['selectedDomains'];
    if (list is List && list.remove(key)) notifyListeners();
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
          // Collect racial stat bonuses from the race object AND from any
          // abilities it automatically grants (e.g. Gnome ~ Rock has BONUS:STAT).
          _cacheRacialBonuses(race, dataset);
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
    rebuildBonuses(dataset);
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
    if (raceObj != null) collect(raceObj);

    // Also walk AUTO_ABILITIES chain for race (racial abilities with bonuses)
    _collectAbilityChainBonuses(raceObj, dataset, allBonuses, {});

    // Class objects — each class contributes saves/BAB progression bonuses
    final classLevels = _data['classLevels'] as List? ?? [];
    final counts = <String, int>{};
    for (final l in classLevels) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        counts[k] = (counts[k] ?? 0) + 1;
      }
    }
    try {
      final classes = (dataset as dynamic).classes as List? ?? [];
      for (final cls in classes) {
        final key = (cls as dynamic).getKeyName() as String? ?? '';
        final lvl = counts[key] ?? 0;
        if (lvl > 0) collect(cls);
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

    // Equipped items
    final equippedSlots = _data['equippedSlots'] as Map? ?? {};
    final equippedKeys = equippedSlots.values.toSet();
    try {
      final equipment = (dataset as dynamic).equipment as List? ?? [];
      for (final item in equipment) {
        final key = (item as dynamic).getKeyName() as String? ?? '';
        if (equippedKeys.contains(key)) collect(item);
      }
    } catch (_) {}

    // Build state for formula evaluation
    final statScores = <String, int>{};
    final scoreMap = _data['statScores'] as Map? ?? {};
    scoreMap.forEach((k, v) {
      statScores[k.toString().toUpperCase()] = (v as num?)?.toInt() ?? 10;
    });

    final statMods = statScores.map((k, v) => MapEntry(k, ((v - 10) / 2).floor()));

    final classLevelCounts = counts.map((k, v) => MapEntry(k, v));

    final state = CharacterBonusState(
      statMods: statMods,
      statScores: statScores,
      totalLevel: classLevels.length,
      classLevelCounts: classLevelCounts,
      definedVars: const {},
      alignmentKey: _str('alignmentKey'),
      raceKey: _str('raceKey'),
      objectTypes: const [],
      classSkillNames: const [],
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
    _bonusDirty = false;
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

  static CharacterFacadeImpl fromJson(Map<String, dynamic> json) =>
      CharacterFacadeImpl(json);

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
