// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.core.character.CompanionMod

import '../pcobject.dart';
import '../categorized.dart';

/// Represents a companion modifier that can be applied to a companion
/// character based on race or class level of the owner.
class CompanionMod extends PObject implements Categorized<CompanionMod> {
  dynamic _category;

  /// Returns the formula value of a variable applied to this companion mod,
  /// or null if not found.
  String? getVariableApplied(String varName) {
    return getMapFor(MapKey.appliedVariable)?[varName];
  }

  /// Returns true if this companion mod applies to the given race.
  bool appliesToRace(dynamic race) {
    final races = getListFor(ListKey.appliedRace);
    if (races == null) return false;
    for (final ref in races) {
      if (ref.contains(race)) return true;
    }
    return false;
  }

  /// Returns the level at which this mod applies for the given class,
  /// or -1 if it does not apply.
  int getLevelApplied(dynamic pcClass) {
    final map = getMapFor(MapKey.appliedClass);
    if (map == null) return -1;
    final val = map[pcClass.getKeyName()];
    return val ?? -1;
  }

  @override
  CompanionMod? getCDOMCategory() => _category;

  @override
  void setCDOMCategory(dynamic cat) {
    _category = cat;
  }
}

/// Placeholder key classes — replace with actual implementations.
class MapKey {
  static const String appliedVariable = 'APPLIED_VARIABLE';
  static const String appliedClass = 'APPLIED_CLASS';
}

class ListKey {
  static const String appliedRace = 'APPLIED_RACE';
}
