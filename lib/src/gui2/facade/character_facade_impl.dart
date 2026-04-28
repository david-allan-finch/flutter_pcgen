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
import 'package:flutter_pcgen/src/core/language.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
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

  // Reference facades
  late final DefaultReferenceFacade<Object> _raceRef;
  late final DefaultReferenceFacade<Object> _alignmentRef;
  late final DefaultReferenceFacade<Object> _deityRef;
  late final DefaultReferenceFacade<String> _nameRef;
  late final DefaultReferenceFacade<String> _tabNameRef;
  late final DefaultReferenceFacade<String?> _fileRef;

  CharacterFacadeImpl(this._data) {
    _raceRef = DefaultReferenceFacade(_data['race']);
    _alignmentRef = DefaultReferenceFacade(_data['alignment']);
    _deityRef = DefaultReferenceFacade(_data['deity']);
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

  @override
  void setRace(Object race) {
    _data['race'] = race;
    _raceRef.set(race);
    notifyListeners();
  }

  // ---- Alignment ----------------------------------------------------------

  @override
  DefaultReferenceFacade<Object> getAlignmentRef() => _alignmentRef;

  @override
  void setAlignment(Object? alignment) {
    _data['alignment'] = alignment;
    _alignmentRef.set(alignment);
    notifyListeners();
  }

  // ---- Deity --------------------------------------------------------------

  @override
  DefaultReferenceFacade<Object> getDeityRef() => _deityRef;

  @override
  void setDeity(Object? deity) {
    _data['deity'] = deity;
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

  @override
  int getHP() => (_data['hp'] as num?)?.toInt() ?? 0;

  @override
  int getMaxHP() => (_data['maxHp'] as num?)?.toInt() ?? 0;

  @override
  void setHP(int hp) {
    _data['hp'] = hp;
    notifyListeners();
  }

  // ---- Saving throws ------------------------------------------------------

  @override
  int getFortSave() => (_data['fortSave'] as num?)?.toInt() ?? 0;

  @override
  int getRefSave() => (_data['refSave'] as num?)?.toInt() ?? 0;

  @override
  int getWillSave() => (_data['willSave'] as num?)?.toInt() ?? 0;

  // ---- Initiative ---------------------------------------------------------

  @override
  int getInitiative() => (_data['initiative'] as num?)?.toInt() ?? 0;

  // ---- AC -----------------------------------------------------------------

  @override
  int getAC() => (_data['ac'] as num?)?.toInt() ?? 0;

  @override
  int getTouchAC() => (_data['touchAC'] as num?)?.toInt() ?? 0;

  @override
  int getFlatFootedAC() => (_data['flatFootedAC'] as num?)?.toInt() ?? 0;

  // ---- BAB ----------------------------------------------------------------

  @override
  String getBAB() => _str('bab');

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

  @override
  int getModTotal(PCStat stat) => ((getScoreBase(stat) - 10) / 2).floor();

  // ---- Class levels ---------------------------------------------------------

  @override
  void addCharacterLevels(List<PCClass> classes) {
    final levels = (_data['classLevels'] ??= <dynamic>[]) as List;
    for (final cls in classes) {
      levels.add({'className': cls.getDisplayName(), 'classKey': cls.getKeyName()});
    }
    notifyListeners();
  }

  @override
  void removeCharacterLevels(int count) {
    final list = _data['classLevels'];
    if (list is! List) return;
    for (int i = 0; i < count && list.isNotEmpty; i++) list.removeLast();
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
      notifyListeners();
    }
  }

  void removeSelectedAbility(String categoryKey, String abilityKey) {
    final map = _data['selectedAbilities'];
    if (map is! Map) return;
    final list = map[categoryKey];
    if (list is List && list.remove(abilityKey)) {
      notifyListeners();
    }
  }

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
    if (!list.contains(key)) { list.add(key); notifyListeners(); }
  }

  void removeTemplateKey(String key) {
    final list = _data['appliedTemplates'];
    if (list is List && list.remove(key)) notifyListeners();
  }

  // ---- Biography ----------------------------------------------------------

  String getBiography() => _str('biography');
  void setBiography(String text) => _set('biography', text);

  String getAppearance() => _str('appearance');
  void setAppearance(String text) => _set('appearance', text);

  String getNotes() => _str('notes');
  void setNotes2(String text) => _set('notes', text);

  // ---- Serialise / deserialise to Map (for save / load) -------------------

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(_data);

  static CharacterFacadeImpl fromJson(Map<String, dynamic> json) =>
      CharacterFacadeImpl(json);

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
