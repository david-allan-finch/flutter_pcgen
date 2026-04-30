//
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.core.PCClass

import 'dart:collection';

import 'package:flutter_pcgen/src/cdom/enumeration/integer_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/cdom/inst/pc_class_level.dart';
import 'package:flutter_pcgen/src/util/enumeration/attack_type.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/core/pcobject.dart';
import 'package:flutter_pcgen/src/core/sub_class.dart';
import 'package:flutter_pcgen/src/core/substitution_class.dart';

/// Represents a character class (e.g., Fighter, Wizard, Rogue).
class PCClass extends PObject {
  final SplayTreeMap<int, PCClassLevel> _levelMap = SplayTreeMap();

  String getLocalScopeName() => 'PC.CLASS';

  // ---------------------------------------------------------------------------
  // Level storage
  // ---------------------------------------------------------------------------

  PCClassLevel getOriginalClassLevel(int lvl) {
    if (!_levelMap.containsKey(lvl)) {
      final classLevel = PCClassLevel();
      classLevel.putInt(IntegerKey.level, lvl);
      classLevel.setName('${getDisplayName()}($lvl)');
      classLevel.putString(StringKey.qualifiedKey, getKeyName());
      classLevel.putObject(ObjectKey.tokenParent, this);
      _levelMap[lvl] = classLevel;
    }
    return _levelMap[lvl]!;
  }

  bool hasOriginalClassLevel(int lvl) => _levelMap.containsKey(lvl);

  Iterable<PCClassLevel> getOriginalClassLevelCollection() =>
      UnmodifiableListView(_levelMap.values.toList());

  void copyLevelsFrom(PCClass cl) {
    for (final entry in cl._levelMap.entries) {
      _levelMap[entry.key] = entry.value;
    }
  }

  void clearClassLevels() => _levelMap.clear();

  // ---------------------------------------------------------------------------
  // Spell slot tables (CAST: and KNOWN: per level)
  // ---------------------------------------------------------------------------

  // Stored as Map<int, List<int>> — level → slots per spell level
  final Map<int, List<int>> _castSlots  = {};
  final Map<int, List<int>> _knownSlots = {};
  // Abilities granted at each class level: level → [abilityName, ...]
  final Map<int, List<String>> _levelAbilities = {};

  void setCastSlots(int level, List<int> slots) => _castSlots[level] = slots;
  void setKnownSlots(int level, List<int> slots) => _knownSlots[level] = slots;

  /// Spell slots at [level] (the CAST: table row).
  List<int> getCastSlotsAt(int level) => _castSlots[level] ?? const [];

  /// Spells known at [level] (the KNOWN: table row).
  List<int> getKnownSlotsAt(int level) => _knownSlots[level] ?? const [];

  /// All levels that have CAST data defined.
  List<int> get definedCastLevels => _castSlots.keys.toList()..sort();

  /// Whether this class has any spell progression defined.
  bool get hasSpells => _castSlots.isNotEmpty;

  /// Cumulative spells per day at character level [clsLevel].
  /// Returns the CAST: row for [clsLevel], or empty if none defined.
  List<int> getSpellsPerDayAt(int clsLevel) {
    if (_castSlots.isEmpty) return const [];
    // Find the highest defined level ≤ clsLevel
    int? key;
    for (final k in _castSlots.keys) {
      if (k <= clsLevel && (key == null || k > key)) key = k;
    }
    return key != null ? _castSlots[key]! : const [];
  }

  /// Add an ability name granted at [level].
  void addLevelAbility(int level, String abilityName) =>
      _levelAbilities.putIfAbsent(level, () => []).add(abilityName);

  /// Ability names granted at exactly [level].
  List<String> getAbilitiesAtLevel(int level) =>
      List.unmodifiable(_levelAbilities[level] ?? const []);

  /// All level→abilities entries.
  Map<int, List<String>> get allLevelAbilities => Map.unmodifiable(_levelAbilities);

  // ---------------------------------------------------------------------------
  // Basic class properties
  // ---------------------------------------------------------------------------

  String? getAbbrev() => getString(StringKey.abbKr);

  String getSpellType() => getSafeString(StringKey.listtype);

  /// Returns the abbreviated spell base stat (e.g., "INT", "WIS").
  String getSpellBaseStat() {
    final stat = baseSpellStat();
    return stat?.getKeyName() ?? 'None';
  }

  String getBaseStat() => getSpellBaseStat();

  bool isMonster() => isType('Monster');
  bool hasXPPenalty() => getSafeInt(IntegerKey.levelAdjustment) != 0;

  bool hasMaxLevel() => getSafeInt(IntegerKey.maxLevel) != 0;
  int getMaxLevel() => getSafeInt(IntegerKey.maxLevel);
  int getLevelLimit() => getSafeInt(IntegerKey.levelLimit);

  String getHD() => getSafeString(StringKey.hdFormula);
  String getClassType() => getSafeString(StringKey.classType);

  /// Spellcasting ability abbreviation from SPELLSTAT token (e.g. 'WIS', 'INT').
  String getSpellStat() => getSafeString(StringKey.spellStat);

  /// Returns the BAB progression type: 'Full', 'ThreeQuarters', 'Half', or '' (unknown).
  String getBabProgression() => getSafeString(StringKey.masterBabFormula);

  /// Returns true if this class has Good (fast) progression for [saveName].
  /// [saveName] is 'Fortitude', 'Reflex', or 'Will'.
  bool isSaveGood(String saveName) {
    final data = getSafeString(StringKey.masterCheckFormula);
    if (data.isEmpty) return false;
    final lower = saveName.toLowerCase();
    for (final entry in data.split(',')) {
      final idx = entry.indexOf(':');
      if (idx < 0) continue;
      if (entry.substring(0, idx).toLowerCase().contains(lower)) {
        return entry.substring(idx + 1) == 'Good';
      }
    }
    return false;
  }
  String getFullKey() => getKeyName();

  /// Returns skill points per level parsed from STARTSKILLPTS token.
  int getSkillPtsPerLevel() {
    try {
      final v = getSafeObject(ObjectKey.getConstant<int>('START_SKILL_PTS'));
      return v as int? ?? 2;
    } catch (_) { return 2; }
  }

  /// Returns the raw CSKILL string (pipe-separated skill names/TYPE= entries).
  String getRawClassSkills() => getSafeString(StringKey.listtype);

  List<String> getTypes() {
    final types = getSafeListFor<dynamic>(ListKey.getConstant<dynamic>('TYPE'));
    return types.map((t) => t.toString()).toList();
  }

  /// Returns the qualified key (used in output).
  String getQualifiedKey() => getKeyName();

  // ---------------------------------------------------------------------------
  // Attack
  // ---------------------------------------------------------------------------

  /// Returns the attack cycle (number of BAB points per extra attack) for
  /// the given attack type. Defaults to the game mode's BAB attack cycle.
  int attackCycle(AttackType at) {
    // TODO: read from ATTACK_CYCLE map token when MapKey.getConstant is available
    return 5; // default: +5/+10/+15 for standard BAB
  }

  /// Returns the base attack bonus for this class at [aPC]'s current level.
  int baseAttackBonus(dynamic aPC) {
    final lvl = (aPC as dynamic).getLevelForClass(this);
    if (lvl == 0) return 0;
    return getBonusTo('COMBAT', 'BASEAB', lvl, aPC).toInt();
  }

  /// Calculates a bonus of type [argType].[argMname] at [asLevel] for [aPC].
  double getBonusTo(String argType, String argMname, int asLevel, dynamic aPC) {
    // TODO: sum bonus objects for this class at the given level
    return 0.0;
  }

  /// Returns the skill points at a given level for [aPC].
  int getSkillPool(dynamic aPC) {
    // TODO: compute from SKILLMULTIPLIER and class skill point token
    return getSafeInt(IntegerKey.bonusClassSkillPoints);
  }

  // ---------------------------------------------------------------------------
  // Spell stat helpers
  // ---------------------------------------------------------------------------

  /// Returns the stat used for learning/casting spells, or null if none.
  PCStat? baseSpellStat() {
    if (getSafeObject(ObjectKey.useSpellSpellStat) as bool? ?? false) return null;
    if (getSafeObject(ObjectKey.casterWithoutSpellStat) as bool? ?? false) return null;
    final ss = getObject(ObjectKey.spellStat);
    if (ss != null) return (ss as dynamic).get() as PCStat?;
    return null;
  }

  /// Returns the stat used for bonus spells.
  PCStat? bonusSpellStat() {
    final hbss = getObject(ObjectKey.hasBonusSpellStat) as bool?;
    if (hbss == null) return baseSpellStat();
    if (hbss) {
      final bssref = getObject(ObjectKey.bonusSpellStat);
      if (bssref != null) return (bssref as dynamic).get() as PCStat?;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // SubClass / SubstitutionClass helpers
  // ---------------------------------------------------------------------------

  SubClass? getSubClassKeyed(String aKey) {
    final subClasses = getListFor<SubClass>(ListKey.getConstant<SubClass>('SUB_CLASS'));
    if (subClasses == null) return null;
    for (final sc in subClasses) {
      if (sc.getKeyName() == aKey) return sc;
    }
    return null;
  }

  SubstitutionClass? getSubstitutionClassKeyed(String aKey) {
    final subs = getListFor<SubstitutionClass>(
        ListKey.getConstant<SubstitutionClass>('SUBSTITUTION_CLASS'));
    if (subs == null) return null;
    for (final sc in subs) {
      if (sc.getKeyName() == aKey) return sc;
    }
    return null;
  }

  void addSubClass(SubClass sc) {
    addToListFor(ListKey.getConstant<SubClass>('SUB_CLASS'), sc);
  }

  void addSubstitutionClass(SubstitutionClass sc) {
    addToListFor(ListKey.getConstant<SubstitutionClass>('SUBSTITUTION_CLASS'), sc);
  }

  // ---------------------------------------------------------------------------
  // Level application
  // ---------------------------------------------------------------------------

  /// Applies a level-up for this class to [aPC].
  bool addLevel(bool argLevelMax, bool bSilent, dynamic aPC,
      {bool isMonsterHD = false}) {
    // TODO: full level application logic (HP, skill points, spell slots, etc.)
    return true;
  }

  void setLevel(int newLevel, dynamic aPC) {
    // TODO: apply level to PC
  }

  int getSkillPointsForLevel(dynamic aPC, PCClassLevel classLevel, int characterLevel) {
    // TODO: compute including INT modifier and multiplier for first level
    return getSafeInt(IntegerKey.bonusClassSkillPoints);
  }

  // ---------------------------------------------------------------------------
  // UDAM (unarmed damage)
  // ---------------------------------------------------------------------------

  String getUdamForLevel(int aLevel, dynamic aPC, bool adjustForPCSize) {
    // TODO: look up from UDAM list
    return '1d3';
  }

  // ---------------------------------------------------------------------------
  // Qualifies
  // ---------------------------------------------------------------------------

  bool qualifies(dynamic aPC, dynamic owner) => true; // TODO: prereq check

  // ---------------------------------------------------------------------------
  // PCC text
  // ---------------------------------------------------------------------------

  String getPCCText() => getKeyName();

  // ---------------------------------------------------------------------------
  // Clone
  // ---------------------------------------------------------------------------

  @override
  PCClass clone() {
    final copy = PCClass();
    copy.setDisplayName(getDisplayName());
    copy.setKeyName(getKeyName());
    // Copy level map entries
    for (final entry in _levelMap.entries) {
      copy._levelMap[entry.key] = entry.value;
    }
    return copy;
  }

  @override
  String toString() => getDisplayName();
}
