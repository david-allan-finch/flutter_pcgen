import 'dart:collection';

import '../cdom/enumeration/integer_key.dart';
import '../cdom/enumeration/list_key.dart';
import '../cdom/enumeration/object_key.dart';
import '../cdom/enumeration/string_key.dart';
import '../cdom/inst/pc_class_level.dart';
import 'pc_stat.dart';
import 'pcobject.dart';
import 'sub_class.dart';

// Represents a character class (e.g., Fighter, Wizard, Rogue).
class PCClass extends PObject {
  final SplayTreeMap<int, PCClassLevel> _levelMap = SplayTreeMap();

  String? getLocalScopeName() => 'PC.CLASS';

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

  int getMaxLevel() => getSafeInt(IntegerKey.maxLevel);

  int getLevelLimit() => getSafeInt(IntegerKey.levelLimit);

  // ---------------------------------------------------------------------------
  // Basic properties
  // ---------------------------------------------------------------------------

  String? getAbbrev() => get(StringKey.abbKr);

  bool isMonster() => isType('Monster');

  String getSpellType() => getSafeString(StringKey.listtype);

  dynamic getAttackBonusType() =>
      getObject(ObjectKey.getConstant<dynamic>('ATTACKBONUSTYPE'));

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
  // SubClass helpers
  // ---------------------------------------------------------------------------

  SubClass? getSubClassKeyed(String aKey) {
    final subClasses = getListFor(ListKey.getConstant<SubClass>('SUB_CLASS'))
        as List<SubClass>?;
    if (subClasses == null) return null;
    for (final sc in subClasses) {
      if (sc.getKeyName() == aKey) return sc;
    }
    return null;
  }

  @override
  String toString() => getDisplayName();
}
