// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.core.character.CompanionMod

import 'package:flutter_pcgen/src/cdom/base/category.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/map_key.dart';
import 'package:flutter_pcgen/src/core/pcobject.dart';
import 'package:flutter_pcgen/src/cdom/base/categorized.dart';

/// Represents a companion modifier that can be applied to a companion
/// character based on race or class level of the owner.
class CompanionMod extends PObject implements Categorized<CompanionMod> {
  Category<CompanionMod>? _category;

  static final _appliedVariableKey =
      MapKey.named<String, String>('APPLIED_VARIABLE');
  static final _appliedClassKey =
      MapKey.named<String, int>('APPLIED_CLASS');
  static final _appliedRaceKey =
      ListKey.getConstant<dynamic>('APPLIED_RACE');

  String? getVariableApplied(String varName) {
    return getMapFor(_appliedVariableKey)?[varName];
  }

  bool appliesToRace(dynamic race) {
    final races = getListFor(_appliedRaceKey);
    if (races == null) return false;
    for (final ref in races) {
      if (ref is List && ref.contains(race)) return true;
    }
    return false;
  }

  int getLevelApplied(dynamic pcClass) {
    final map = getMapFor(_appliedClassKey);
    if (map == null) return -1;
    return map[pcClass.getKeyName()] ?? -1;
  }

  @override
  Category<CompanionMod>? getCDOMCategory() => _category;

  @override
  void setCDOMCategory(Category<CompanionMod> cat) {
    _category = cat;
  }

  @override
  ClassIdentity<Loadable>? getClassIdentity() =>
      _category as ClassIdentity<Loadable>?;
}
