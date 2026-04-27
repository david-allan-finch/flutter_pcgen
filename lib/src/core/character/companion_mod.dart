// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.core.character.CompanionMod

import 'package:flutter_pcgen/src/cdom/base/category.dart';
import 'package:flutter_pcgen/src/cdom/base/class_identity.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart' as lk;
import 'package:flutter_pcgen/src/cdom/enumeration/map_key.dart' as mk;
import 'package:flutter_pcgen/src/core/pcobject.dart';
import 'package:flutter_pcgen/src/cdom/base/categorized.dart';

/// Represents a companion modifier that can be applied to a companion
/// character based on race or class level of the owner.
class CompanionMod extends PObject implements Categorized<CompanionMod> {
  Category<CompanionMod>? _category;

  static final _appliedVariableKey =
      mk.MapKey.getConstant<String, String>('APPLIED_VARIABLE');
  static final _appliedClassKey =
      mk.MapKey.getConstant<String, int>('APPLIED_CLASS');
  static final _appliedRaceKey =
      lk.ListKey.getConstant<dynamic>('APPLIED_RACE');

  /// Returns the formula value of a variable applied to this companion mod,
  /// or null if not found.
  String? getVariableApplied(String varName) {
    return getMapFor(_appliedVariableKey)?[varName];
  }

  /// Returns true if this companion mod applies to the given race.
  bool appliesToRace(dynamic race) {
    final races = getListFor(_appliedRaceKey);
    if (races == null) return false;
    for (final ref in races) {
      if (ref.contains != null && ref.contains(race)) return true;
    }
    return false;
  }

  /// Returns the level at which this mod applies for the given class,
  /// or -1 if it does not apply.
  int getLevelApplied(dynamic pcClass) {
    final map = getMapFor(_appliedClassKey);
    if (map == null) return -1;
    final val = map[pcClass.getKeyName()];
    return val ?? -1;
  }

  @override
  Category<CompanionMod>? getCDOMCategory() => _category;

  @override
  void setCDOMCategory(Category<CompanionMod> cat) {
    _category = cat;
  }

  @override
  ClassIdentity<Loadable>? getClassIdentity() => _category as ClassIdentity<Loadable>?;
}
