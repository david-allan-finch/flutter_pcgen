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
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
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

  /// Class skill names for this character (populated during rebuildBonuses).
  List<String> classSkillNames = const [];

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
      // Auto-grant proficiency with the deity's favoured weapon (DEITYWEAP token)
      try {
        final weap = (deity as dynamic).getString(StringKey.nameText) as String?;
        if (weap != null && weap.isNotEmpty && weap.toUpperCase() != 'ANY') {
          final profs = (_data['deityWeaponProfs'] ??= <String>[]) as List;
          if (!profs.contains(weap)) profs.add(weap);
        }
      } catch (_) {}
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
    // totalIntWithAll already includes the SAVE|ALL bucket — don't add it again.
    final base = acc.totalIntWithAll('SAVE', 'Fortitude') +
                 acc.totalIntWithAll('SAVE', 'BASE.FORTITUDE') +
                 acc.totalIntWithAll('CHECKS', 'Fortitude');
    if (base == 0) return (_data['fortSave'] as num?)?.toInt() ?? _statModByAbb('CON');
    return base + _statModByAbb('CON');
  }

  @override
  int getRefSave() {
    final acc = _bonusAcc;
    final base = acc.totalIntWithAll('SAVE', 'Reflex') +
                 acc.totalIntWithAll('SAVE', 'BASE.REFLEX') +
                 acc.totalIntWithAll('CHECKS', 'Reflex');
    if (base == 0) return (_data['refSave'] as num?)?.toInt() ?? _statModByAbb('DEX');
    return base + _statModByAbb('DEX');
  }

  @override
  int getWillSave() {
    final acc = _bonusAcc;
    final base = acc.totalIntWithAll('SAVE', 'Will') +
                 acc.totalIntWithAll('SAVE', 'BASE.WILL') +
                 acc.totalIntWithAll('CHECKS', 'Will');
    if (base == 0) return (_data['willSave'] as num?)?.toInt() ?? _statModByAbb('WIS');
    return base + _statModByAbb('WIS');
  }

  int _statModByAbb(String abb) {
    // Delegate to getModTotal so magic item bonuses (Amulet of Health, etc.)
    // are included in saves, HP, initiative, and AC calculations.
    final upper = abb.toUpperCase();
    // Find the matching PCStat by abbreviation
    try {
      // Try direct abbreviation lookup in statScores
      final scores = _data['statScores'];
      if (scores is Map && scores.containsKey(upper)) {
        final base = (scores[upper] as num?)?.toInt() ?? 10;
        int levelGains = 0;
        final levels = _data['classLevels'] as List? ?? [];
        for (final l in levels) {
          if (l is Map) {
            final gains = l['statGains'] as Map?;
            if (gains != null) {
              levelGains += (gains[upper] as num?)?.toInt() ?? 0;
            }
          }
        }
        final itemBonus = _bonusAcc.totalIntWithAll('STAT', upper);
        return ((base + levelGains + itemBonus - 10) / 2).floor();
      }
    } catch (_) {}
    return 0;
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

  // Bonus types excluded from touch AC (physical protection that touch ignores).
  static const _touchACExclude = {'ARMOR', 'ARMORENHANCEMENT', 'NATURALARMOR', 'SHIELD', 'SHIELDENHANCEMENT'};
  // Flat-footed additionally loses Dodge and DEX.
  static const _flatFootedACExclude = {'ARMOR', 'ARMORENHANCEMENT', 'NATURALARMOR', 'SHIELD', 'SHIELDENHANCEMENT', 'DODGE'};

  @override
  int getAC() {
    return 10 + _effectiveDexForAC() +
        _bonusAcc.totalIntWithAll('COMBAT', 'AC');
  }

  @override
  int getTouchAC() {
    // Touch AC: excludes Armor, NaturalArmor, Shield typed bonuses.
    return 10 + _effectiveDexForAC() +
        _bonusAcc.totalIntExcluding('COMBAT', 'AC', _touchACExclude) +
        _bonusAcc.totalInt('COMBAT', 'ALL');
  }

  @override
  int getFlatFootedAC() {
    // Flat-footed: loses DEX and Dodge bonuses in addition to touch exclusions.
    final dexContrib = _effectiveDexForAC().clamp(0, 99);
    return 10 +
        _bonusAcc.totalIntExcluding('COMBAT', 'AC', _flatFootedACExclude) +
        _bonusAcc.totalInt('COMBAT', 'ALL') -
        dexContrib;
  }

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

    // Check for a non-standard attack cycle (e.g. Monk: 5|5|2 instead of 5|5|5).
    List<int> cycles = [5, 5, 5, 5, 5];
    try {
      final dataset = _dataset;
      if (dataset != null) {
        final classes = (dataset as dynamic).classes as List? ?? [];
        final classLevels = _data['classLevels'] as List? ?? [];
        final usedKeys = <String>{};
        for (final l in classLevels) {
          if (l is! Map) continue;
          final key = l['classKey'] as String? ?? '';
          if (!usedKeys.add(key)) continue;
          for (final cls in classes) {
            if ((cls as dynamic).getKeyName() != key) continue;
            final cycle = (cls as dynamic).getString(StringKey.attackCycle) as String?;
            if (cycle != null && cycle.isNotEmpty) {
              final parts = cycle.split('|')
                  .map((s) => int.tryParse(s.trim()) ?? 5).toList();
              if (parts.isNotEmpty) { cycles = parts; break; }
            }
            break;
          }
        }
      }
    } catch (_) {}

    final attacks = <String>[];
    int cur = bab;
    int ci = 0;
    while (cur > 0) {
      attacks.add('${cur >= 0 ? '+' : ''}$cur');
      cur -= cycles[ci < cycles.length ? ci : cycles.length - 1];
      ci++;
      if (ci > 8) break; // safety
    }
    return attacks.join('/');
  }

  /// Universal to-hit bonus (BONUS:COMBAT|TOHIT — applies to all attacks).
  int getTohitBonus() => _bonusAcc.totalInt('COMBAT', 'TOHIT');

  /// Melee-specific to-hit (TOHIT + TOHIT.MELEE). Use for melee weapons only.
  /// BONUS:WEAPON|TOHIT from EQMODs is handled separately by the sheet via
  /// _eqmodBonuses — don't include it here to avoid double-counting.
  int getTohitBonusMelee() =>
      _bonusAcc.totalInt('COMBAT', 'TOHIT') +
      _bonusAcc.totalInt('COMBAT', 'TOHIT.MELEE');

  /// Ranged-specific to-hit (TOHIT + TOHIT.RANGED). Use for ranged weapons only.
  int getTohitBonusRanged() =>
      _bonusAcc.totalInt('COMBAT', 'TOHIT') +
      _bonusAcc.totalInt('COMBAT', 'TOHIT.RANGED');

  /// Universal damage bonus (BONUS:COMBAT|DAMAGE — applies to all attacks).
  int getDamageBonus() => _bonusAcc.totalInt('COMBAT', 'DAMAGE');

  /// Melee-specific damage (DAMAGE + DAMAGE.MELEE).
  int getDamageBonusMelee() =>
      _bonusAcc.totalInt('COMBAT', 'DAMAGE') +
      _bonusAcc.totalInt('COMBAT', 'DAMAGE.MELEE');

  /// Ranged-specific damage (DAMAGE + DAMAGE.RANGED).
  int getDamageBonusRanged() =>
      _bonusAcc.totalInt('COMBAT', 'DAMAGE') +
      _bonusAcc.totalInt('COMBAT', 'DAMAGE.RANGED');

  /// Short-range (≤30ft) to-hit bonus — Point Blank Shot etc.
  int getShortRangeTohitBonus() =>
      _bonusAcc.totalInt('COMBAT', 'TOHIT-SHORTRANGE');

  /// Short-range (≤30ft) damage bonus — Point Blank Shot etc.
  int getShortRangeDamageBonus() =>
      _bonusAcc.totalInt('COMBAT', 'DAMAGE-SHORTRANGE');

  /// Weapon-type-specific to-hit bonus (e.g. Bracers of Archery give +2 to Longbow).
  /// [weaponType] should be a TYPE string from the weapon (e.g. 'Longbow', 'Shortbow').
  int getWeaponTypeTohitBonus(String weaponType) {
    final cat = 'WEAPONPROF=${weaponType.toUpperCase()}';
    return _bonusAcc.totalInt(cat, 'TOHIT');
  }

  /// Weapon-type-specific damage bonus (e.g. Bracers of Archery give +1 damage to Longbow).
  int getWeaponTypeDamageBonus(String weaponType) {
    final cat = 'WEAPONPROF=${weaponType.toUpperCase()}';
    return _bonusAcc.totalInt(cat, 'DAMAGE');
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

  /// Armor bonus to AC (ARMOR-typed bonus from equipped armor).
  int getArmorBonus() => _bonusAcc.totalInt('COMBAT', 'AC');

  int getNaturalArmorBonus() => _bonusAcc.totalIntOfType('COMBAT', 'AC', 'NATURALARMOR');
  int getShieldBonus()       => _bonusAcc.totalIntOfType('COMBAT', 'AC', 'SHIELD') +
                                _bonusAcc.totalIntOfType('COMBAT', 'AC', 'SHIELDENHANCEMENT');
  int getDeflectionBonus()   => _bonusAcc.totalIntOfType('COMBAT', 'AC', 'DEFLECTION');
  int getDodgeBonus()        => _bonusAcc.totalIntOfType('COMBAT', 'AC', 'DODGE');
  int getSacredBonus()       => _bonusAcc.totalIntOfType('COMBAT', 'AC', 'SACRED') +
                                _bonusAcc.totalIntOfType('COMBAT', 'AC', 'PROFANE');

  /// Size modifier to AC: Fine +8 … Colossal −8.
  int getSizeACModifier() {
    const mods = {'F': 8, 'D': 4, 'T': 2, 'S': 1, 'M': 0, 'L': -1, 'H': -2, 'G': -4, 'C': -8};
    return mods[getRaceSize().toUpperCase()] ?? 0;
  }

  /// Lowest MAXDEX cap from all equipped armor/shield items.
  /// Returns null if no cap applies (no armor, or armor has no MAXDEX entry).
  int? getMaxDexCapFromArmor() {
    try {
      final dataset = _dataset;
      if (dataset == null) return null;
      final equippedSlots = _data['equippedSlots'] as Map? ?? {};
      final equippedKeys = equippedSlots.values.toSet();
      final equipment = (dataset as dynamic).equipment as List? ?? [];
      int? cap;
      for (final item in equipment) {
        final key = (item as dynamic).getKeyName() as String? ?? '';
        if (!equippedKeys.contains(key)) continue;
        final md = (item as dynamic).getMaxDex() as int?;
        if (md != null) cap = cap == null ? md : (md < cap ? md : cap);
      }
      return cap;
    } catch (_) { return null; }
  }

  /// Sum of spell failure percentages from all equipped armor/shield items.
  int getSpellFailureTotal() {
    try {
      final dataset = _dataset;
      if (dataset == null) return 0;
      final equippedSlots = _data['equippedSlots'] as Map? ?? {};
      final equippedKeys = equippedSlots.values.toSet();
      final equipment = (dataset as dynamic).equipment as List? ?? [];
      int total = 0;
      for (final item in equipment) {
        final key = (item as dynamic).getKeyName() as String? ?? '';
        if (!equippedKeys.contains(key)) continue;
        final sf = (item as dynamic).getSpellFailure() as int? ?? 0;
        total += sf;
      }
      return total;
    } catch (_) { return 0; }
  }

  /// Returns true if [skillName] is a class skill for this character.
  bool isClassSkill(String skillName) {
    final lower = skillName.toLowerCase();
    return classSkillNames.any((s) => s.toLowerCase() == lower);
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
  /// Includes SKILL|Name, SKILL|ALL, SKILL|TYPE.X, CSKILL|Name, CCSKILL|Name,
  /// and CHOOSE-based LIST bonuses.
  int getSkillBonus(String displayName, String keyName) {
    final acc = _bonusAcc;
    final nameUp = displayName.toUpperCase();
    final keyUp  = keyName.toUpperCase();

    int total = acc.totalIntWithAll('SKILL', nameUp) +
                acc.totalIntWithAll('SKILL', keyUp);

    // Class-skill and cross-class-skill specific bonuses
    total += acc.totalIntWithAll('CSKILL',  nameUp) +
             acc.totalIntWithAll('CSKILL',  keyUp)  +
             acc.totalIntWithAll('CCSKILL', nameUp) +
             acc.totalIntWithAll('CCSKILL', keyUp);

    // Type-based skill bonuses: BONUS:SKILL|TYPE.Craft etc.
    // Skill types come from the dataset skill object's type list.
    try {
      final dataset = _dataset;
      if (dataset != null) {
        final skills = (dataset as dynamic).skills as List? ?? [];
        for (final sk in skills) {
          final skName = (sk as dynamic).getDisplayName() as String? ?? '';
          if (skName.toLowerCase() != displayName.toLowerCase()) continue;
          final typeList = (sk as dynamic)
              .getSafeListFor(ListKey.getConstant<String>('TYPE')) as List? ?? [];
          for (final t in typeList) {
            if (t is String && t.isNotEmpty) {
              total += acc.totalInt('SKILL', 'TYPE.${t.toUpperCase()}');
            }
          }
          break;
        }
      }
    } catch (_) {}

    // Resolve LIST bonuses: check abilityChoices for any that match this skill
    try {
      final choices = _data['abilityChoices'] as Map? ?? {};
      final selectedAbilities = _data['selectedAbilities'] as Map? ?? {};
      final allSelected = <String>[];
      for (final cat in selectedAbilities.values) {
        if (cat is List) allSelected.addAll(cat.cast<String>());
      }
      for (final storedKey in allSelected) {
        final choice = choices[storedKey] as String?;
        if (choice == null) continue;
        if (choice.toLowerCase() != displayName.toLowerCase() &&
            choice.toLowerCase() != keyName.toLowerCase()) continue;
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
    final classLevelList = _data['classLevels'] as List? ?? [];
    final counts = <String, int>{};
    for (final l in classLevelList) {
      if (l is Map) {
        final k = l['classKey'] as String? ?? '';
        counts[k] = (counts[k] ?? 0) + 1;
      }
    }
    return FormulaContext(
      statMods: statMods,
      statScores: statScores,
      totalLevel: classLevelList.length,
      classLevels: counts,
      variables: Map<String, double>.from(_data['charVariables'] as Map? ?? {}),
      charbonusto: (category, target) =>
          _bonusAcc.totalWithAll(category, target),
      countFn: (what) {
        final w = what.toUpperCase();
        if (w == 'CLASSES') return counts.length.toDouble();
        if (w.startsWith('ABILITIES') || w.startsWith('FEATS')) {
          final selected = _data['selectedAbilities'] as Map? ?? {};
          int total = 0;
          for (final cat in selected.values) {
            if (cat is List) total += cat.length;
          }
          return total.toDouble();
        }
        return 0.0;
      },
      skillinfo: (skillName) {
        // Returns total skill modifier for the named skill
        return getSkillBonus(skillName, skillName).toDouble();
      },
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

  String getDeityKey() {
    final raw = _str('deityKey');
    // PCG stores full deity LST record (name|DEITYDOMAINS:...) — return only the name part
    final pipeIdx = raw.indexOf('|');
    return pipeIdx > 0 ? raw.substring(0, pipeIdx) : raw;
  }
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

  String getPersonalityTrait(int n) =>
      _str(n == 1 ? 'personalityTrait1' : 'personalityTrait2');

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

    // For each gear item find its dataset key and store it as 'dsKey'.
    // We deliberately do NOT replace item['key'] (which is the display-name-
    // derived unique key used in equippedSlots/carriedItems) because two
    // custom items can share the same base type (e.g. "+3 Moonbow" and
    // "Masterwork Longbow" both resolve to "Longbow (Composite)") and
    // replacing would cause collisions. The sheet uses 'dsKey' for dataset
    // lookups and 'key' for all identity/slot references.
    try {
      final allEquip = (dataset as dynamic).equipment as List? ?? [];
      final nameToKey = <String, String>{};
      for (final e in allEquip) {
        final n = (e as dynamic).getDisplayName() as String? ?? '';
        final k = (e as dynamic).getKeyName()     as String? ?? '';
        if (n.isNotEmpty && k.isNotEmpty) nameToKey[n.toLowerCase()] = k;
        if (k.isNotEmpty) nameToKey[k.toLowerCase()] = k;
      }
      final gear = _data['gear'] as List? ?? [];
      for (final item in gear) {
        if (item is! Map) continue;
        final name     = (item['name']     as String? ?? '').toLowerCase();
        final baseItem = (item['baseItem'] as String? ?? '').toLowerCase();
        final dsKey = nameToKey[name] ?? nameToKey[baseItem];
        if (dsKey != null) item['dsKey'] = dsKey;
      }
    } catch (_) {}

    // Re-grant domain benefits (abilities + spell lists) that were persisted.
    // _grantDomainBenefits is idempotent for already-stored ability keys.
    try {
      final savedDomains = _data['selectedDomains'] as List? ?? [];
      for (final d in savedDomains) {
        if (d is String && d.isNotEmpty) _grantDomainBenefits(d);
      }
    } catch (_) {}

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
  /// All weapon proficiencies the character has from all sources.
  Set<String> getWeaponProficiencies() {
    final profs = <String>{};
    try {
      // Race AUTO_WEAPONPROF
      final race = _raceRef.get();
      if (race != null) {
        _collectChainWeaponProfs(race, _dataset, profs, {});
      }
      // Classes AUTO_WEAPONPROF via PROFICIENCY token
      final dataset = _dataset;
      if (dataset != null) {
        final classLevels = _data['classLevels'] as List? ?? [];
        final usedKeys = <String>{};
        for (final l in classLevels) {
          if (l is! Map) continue;
          final key = l['classKey'] as String? ?? '';
          if (!usedKeys.add(key)) continue;
          final classes = (dataset as dynamic).classes as List? ?? [];
          for (final cls in classes) {
            if ((cls as dynamic).getKeyName() != key) continue;
            _collectChainWeaponProfs(cls, dataset, profs, {});
            // PROFICIENCY:WEAPON|Simple etc stored in targetArea
            try {
              final p = (cls as dynamic).getString(StringKey.targetArea) as String?;
              if (p != null && p.isNotEmpty) profs.add(p);
            } catch (_) {}
          }
        }
        // Selected abilities (Weapon Proficiency feats)
        final selectedAbilities = _data['selectedAbilities'] as Map? ?? {};
        final allAbilities = (dataset as dynamic).getAllAbilities() as List? ?? [];
        for (final cat in selectedAbilities.values) {
          if (cat is! List) continue;
          for (final stored in cat) {
            final baseKey = stored.toString().split('|').first;
            for (final ab in allAbilities) {
              if ((ab as dynamic).getKeyName() != baseKey) continue;
              _collectChainWeaponProfs(ab, dataset, profs, {});
              break;
            }
          }
        }
      }
      // Deity weapon
      final deityProfs = _data['deityWeaponProfs'] as List? ?? [];
      profs.addAll(deityProfs.cast<String>());
      // Explicit proficiency list stored in the PCG file (WEAPONPROF: line)
      final pcgProfs = _data['weaponProfs'] as List? ?? [];
      profs.addAll(pcgProfs.cast<String>());
    } catch (_) {}
    return profs;
  }

  void _collectChainWeaponProfs(
      dynamic obj, dynamic dataset, Set<String> out, Set<String> seen) {
    if (obj == null) return;
    try {
      final wp = (obj as dynamic)
          .getSafeListFor(ListKey.getConstant<String>('AUTO_WEAPONPROF')) as List?;
      if (wp != null) for (final p in wp) { if (p is String) out.add(p); }
    } catch (_) {}
    try {
      final auto = (obj as dynamic)
          .getSafeListFor(ListKey.getConstant<String>('AUTO_ABILITIES')) as List?;
      if (auto != null && dataset != null) {
        for (final name in auto) {
          if (name is String && seen.add(name)) {
            final ability = (dataset as dynamic).findAbilityByName(name);
            if (ability != null) _collectChainWeaponProfs(ability, dataset, out, seen);
          }
        }
      }
    } catch (_) {}
  }

  /// Whether the character is proficient with [weaponTypes] (TYPE list from the item).
  bool isWeaponProficient(List<String> weaponTypes) =>
      isWeaponProficientByName(weaponTypes, '');

  /// Proficiency check that also matches by the weapon's display name.
  /// PCG WEAPONPROF lists store individual weapon names (e.g. "Greatsword"),
  /// while the dataset TYPE list has category names ("Martial", "Slashing").
  /// Both are checked so that either a matching type category or matching
  /// weapon name grants proficiency.
  bool isWeaponProficientByName(List<String> weaponTypes, String weaponName) {
    final profs = getWeaponProficiencies();
    // Check by weapon display name: strip trailing " +N" enhancement suffix.
    if (weaponName.isNotEmpty) {
      final name = weaponName.toLowerCase();
      final base = name.replaceAll(RegExp(r'\s*\+\d+\s*$'), '').trim();
      for (final p in profs) {
        final pl = p.toLowerCase();
        if (pl == name || pl == base) return true;
        // Partial prefix match: prof "Greatsword" matches weapon "Greatsword +2"
        if (name.startsWith(pl) && pl.length >= 3) return true;
      }
    }
    // Check by TYPE category (Martial, Simple, Exotic, etc.)
    for (final t in weaponTypes) {
      if (profs.contains(t)) return true;
      if (profs.any((p) => p.toLowerCase() == t.toLowerCase())) return true;
    }
    return false;
  }

  /// Caster level for a given spell class or school.
  /// Includes BONUS:CASTERLEVEL and BONUS:PCLEVEL (prestige class spell
  /// progression bonuses like "Dragon Disciple adds to Sorcerer CL").
  int getCasterLevel(String classOrSchool) {
    final key = classOrSchool.toUpperCase();
    int cl = _bonusAcc.totalInt('CASTERLEVEL', key) +
             _bonusAcc.totalIntWithAll('CASTERLEVEL', key);
    // BONUS:PCLEVEL|ClassName|CL — prestige class effective-level bonus
    final pcl = _bonusAcc.totalInt('PCLEVEL', classOrSchool) +
                _bonusAcc.totalInt('PCLEVEL', key);

    // CASTERLEVEL:ClassName token on prestige classes — adds levels to a base class.
    // Each prestige class that has CASTERLEVEL:Wizard grants its class levels
    // to Wizard caster level.
    try {
      final dataset = _dataset;
      if (dataset != null) {
        final classes = (dataset as dynamic).classes as List? ?? [];
        final classLevels = _data['classLevels'] as List? ?? [];
        final counts = <String, int>{};
        for (final l in classLevels) {
          if (l is Map) {
            final k = l['classKey'] as String? ?? '';
            counts[k] = (counts[k] ?? 0) + 1;
          }
        }
        for (final cls in classes) {
          final clsKey = (cls as dynamic).getKeyName() as String? ?? '';
          final lvl = counts[clsKey] ?? 0;
          if (lvl == 0) continue;
          final grants = (cls as dynamic)
              .getSafeListFor(ListKey.getConstant<String>('CASTERLEVEL_GRANTS')) as List? ?? [];
          for (final g in grants) {
            if (g is String && g.toUpperCase() == key) cl += lvl;
          }
        }
      }
    } catch (_) {}

    return cl + pcl;
  }

  /// Bonus ranks to a specific skill from BONUS:SKILLRANK.
  int getSkillRankBonus(String skillName) =>
      _bonusAcc.totalInt('SKILLRANK', skillName) +
      _bonusAcc.totalIntWithAll('SKILLRANK', skillName);

  /// Miscellaneous skill bonus from BONUS:SKILL (circumstance, competence, etc).
  int getSkillMiscBonus(String skillName) =>
      _bonusAcc.totalInt('SKILL', skillName) +
      _bonusAcc.totalIntWithAll('SKILL', skillName);

  /// Movement speed bonus from BONUS:MOVEADD|TYPE.Walk|N.
  Map<String, int> getMovementBonuses() {
    final result = <String, int>{};
    // The BonusAccumulator stores category='MOVEADD', target='TYPE.Walk' etc.
    for (final moveType in ['TYPE.Walk', 'Walk', 'TYPE.Fly', 'Fly',
                             'TYPE.Swim', 'Swim', 'TYPE.Burrow', 'Burrow',
                             'TYPE.Climb', 'Climb']) {
      final bonus = _bonusAcc.totalInt('MOVEADD', moveType);
      if (bonus != 0) {
        final label = moveType.startsWith('TYPE.') ? moveType.substring(5) : moveType;
        result[label] = (result[label] ?? 0) + bonus;
      }
    }
    return result;
  }

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
        // PLUS:N enhancement bonus — synthesise BONUS entries so the +N
        // is included in the character's attack, damage, or AC totals.
        try {
          final plus = (item as dynamic).getPlus() as int? ?? 0;
          if (plus > 0) {
            final isWeapon = (item as dynamic).isWeapon() as bool? ?? false;
            final isArmor  = (item as dynamic).isArmor()  as bool? ?? false;
            final isShield = (item as dynamic).isShield()  as bool? ?? false;
            if (isWeapon) {
              final b1 = ParsedBonus.parse('COMBAT|TOHIT|$plus|TYPE=ENHANCEMENT');
              final b2 = ParsedBonus.parse('COMBAT|DAMAGE|$plus|TYPE=ENHANCEMENT');
              if (b1 != null) allBonuses.add(b1);
              if (b2 != null) allBonuses.add(b2);
            }
            if (isArmor) {
              final b = ParsedBonus.parse('COMBAT|AC|$plus|TYPE=ARMORENHANCEMENT');
              if (b != null) allBonuses.add(b);
            }
            if (isShield) {
              final b = ParsedBonus.parse('COMBAT|AC|$plus|TYPE=SHIELDENHANCEMENT');
              if (b != null) allBonuses.add(b);
            }
          }
        } catch (_) {}
      }
    } catch (_) {}

    // Active temporary bonuses (manually added or from abilities)
    try {
      final tempBonusList = _data['tempBonuses'] as List? ?? [];
      for (final tb in tempBonusList) {
        if (tb is! Map) continue;
        if (!(tb['active'] as bool? ?? true)) continue;
        final category  = tb['category']  as String? ?? '';
        final target    = tb['target']    as String? ?? '';
        final valueStr  = tb['value']     as String? ?? '0';
        final bonusType = tb['bonusType'] as String? ?? '';
        if (category.isEmpty || target.isEmpty) continue;
        final bonusStr = bonusType.isNotEmpty
            ? '$category|$target|$valueStr|TYPE=$bonusType'
            : '$category|$target|$valueStr';
        final bonus = ParsedBonus.parse(bonusStr);
        if (bonus != null) allBonuses.add(bonus);
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

    // Store for isClassSkill() lookups
    classSkillNames = classSkillSet.toList();

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
        if (bonus.category == 'COMBAT' && bonus.targets.any((t) => t.toUpperCase() == 'BASEAB')) {
        }
        _bonusAcc.add(bonus, value, sourceKey: clsKey);
      }
    }

    // Apply active temporary bonuses (spell effects, rage, etc.)
    _applyTempBonuses();

    // Apply size modifiers (standard 3.5e/PF table).
    _applySizeModifiers();

    _bonusDirty = false;
  }

  // Standard 3.5e size modifier table: size abbreviation → (AC/Attack bonus, Grapple bonus)
  static const _sizeMods = {
    'F': (8,  -24), // Fine
    'D': (4,  -12), // Diminutive
    'T': (2,   -8), // Tiny
    'S': (1,   -4), // Small
    'M': (0,    0), // Medium
    'L': (-1,   4), // Large
    'H': (-2,   8), // Huge
    'G': (-4,  12), // Gargantuan
    'C': (-8,  16), // Colossal
  };

  void _applySizeModifiers() {
    final sizeKey = (_data['raceSize'] as String? ?? 'M').toUpperCase();
    final mods = _sizeMods[sizeKey];
    if (mods == null || mods.$1 == 0) return; // Medium has no modifier

    final acAttackBonus = mods.$1.toDouble();

    // AC size modifier
    final acBonus = ParsedBonus(
      category: 'COMBAT', targets: ['AC'],
      formula: acAttackBonus.toString(), bonusType: 'Size', stack: BonusStack.normal,
    );
    _bonusAcc.add(acBonus, acAttackBonus);

    // Attack size modifier
    final hitBonus = ParsedBonus(
      category: 'COMBAT', targets: ['TOHIT'],
      formula: acAttackBonus.toString(), bonusType: 'Size', stack: BonusStack.normal,
    );
    _bonusAcc.add(hitBonus, acAttackBonus);
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
                  for (final b in list) {
                    // Don't collect BONUS:STAT from the ability chain — racial stat
                    // bonuses flow in via the race object directly and via selectedAbilities
                    // (the character's subrace ability). Walking the chain also picks up
                    // wrong-subrace abilities (e.g. Elf ~ High for a Wood Elf) because
                    // auto-ability prereqs aren't evaluated here.
                    if (b is ParsedBonus && b.category != 'STAT') out.add(b);
                  }
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
