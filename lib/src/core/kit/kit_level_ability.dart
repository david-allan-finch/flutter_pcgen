// Copyright (c) Aaron Divinsky, 2005.
//
// Translation of pcgen.core.kit.KitLevelAbility

import 'package:flutter_pcgen/src/core/kit/base_kit.dart';

/// Applies a class feature (ADD choice) to a character via a kit.
class KitLevelAbility extends BaseKit {
  /// Reference to the PCClass this ability belongs to.
  dynamic theClassName;

  /// Level at which the ADD choice fires.
  int theLevel = 0;

  /// Pre-encoded choice strings (e.g. decoded by PersistentTransitionChoice).
  final List<String> choiceList = [];

  /// The PersistentTransitionChoice object from the class.
  dynamic add;

  void setPCClass(dynamic className) => theClassName = className;
  dynamic getPCClass() => theClassName;

  void setLevel(int level) => theLevel = level;
  int getLevel() => theLevel;

  void addChoice(String choice) => choiceList.add(choice);

  void setAdd(dynamic ptc) => add = ptc;
  dynamic getAdd() => add;

  @override
  bool testApply(dynamic aKit, dynamic aPC, List<String> warnings) =>
      _doApplication(aPC);

  @override
  void apply(dynamic aPC) => _doApplication(aPC);

  bool _doApplication(dynamic aPC) {
    final theClass = theClassName.get();
    final classKeyed = aPC.getClassKeyed(theClass.getKeyName());
    if (classKeyed == null) return false;

    final adds = theClass.getListFor('ADD');
    if (adds == null) return false;

    for (final ch in adds) {
      if (add == ch) {
        _process(aPC, classKeyed, ch);
        return true;
      }
    }
    return false;
  }

  void _process(dynamic pc, dynamic cl, dynamic ch) {
    final list = choiceList.map((s) => ch.decodeChoice(null, s)).toList();
    ch.act(list, cl, pc);
  }

  @override
  String getObjectName() => 'Class Feature';

  @override
  String toString() {
    final buf = StringBuffer()..write(add);
    buf.write(': [');
    buf.write(choiceList.join(', '));
    buf.write(']');
    return buf.toString();
  }
}
