// Translation of pcgen.core.PCClass

import 'dart:collection';

import '../cdom/enumeration/integer_key.dart';
import '../cdom/enumeration/list_key.dart';
import '../cdom/enumeration/object_key.dart';
import '../cdom/enumeration/string_key.dart';
import '../cdom/inst/pc_class_level.dart';
import '../util/enumeration/attack_type.dart';
import 'pc_stat.dart';
import 'pcobject.dart';
import 'sub_class.dart';
import 'substitution_class.dart';

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
      classLevel.put(IntegerKey.level, lvl);
      classLevel.setName('${getDisplayName()}($lvl)');
      classLevel.put(StringKey.qualifiedKey, getKeyName());
      classLevel.put(ObjectKey.tokenParent, this);
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
  // Basic class properties
  // ---------------------------------------------------------------------------

  String? getAbbrev() => get(StringKey.abbKr);

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
  String getFullKey() => getKeyName();

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
    if (getSafe(ObjectKey.useSpellSpellStat) as bool? ?? false) return null;
    if (getSafe(ObjectKey.casterWithoutSpellStat) as bool? ?? false) return null;
    final ss = get(ObjectKey.spellStat);
    if (ss != null) return (ss as dynamic).get() as PCStat?;
    return null;
  }

  /// Returns the stat used for bonus spells.
  PCStat? bonusSpellStat() {
    final hbss = get(ObjectKey.hasBonusSpellStat) as bool?;
    if (hbss == null) return baseSpellStat();
    if (hbss) {
      final bssref = get(ObjectKey.bonusSpellStat);
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
