// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.ClassLevelChangeFacet

import '../enumeration/char_id.dart';
import '../inst/pc_class_level.dart';
import '../../core/pc_class.dart';
import 'model/class_facet.dart';
import 'model/class_level_facet.dart';

/// Listens for PCClass level changes and updates [ClassLevelFacet] to reflect
/// the current set of active [PCClassLevel] objects.
class ClassLevelChangeFacet implements ClassLevelChangeListener {
  late ClassFacet classFacet;
  late ClassLevelFacet classLevelFacet;

  void init() {
    classFacet.addLevelChangeListener(this);
  }

  @override
  void levelChanged(ClassLevelChangeEvent lce) {
    _update(lce.getCharID(), lce.getPCClass() as PCClass,
        lce.getOldLevel(), lce.getNewLevel());
  }

  @override
  void levelObjectChanged(ClassLevelObjectChangeEvent lce) {
    final old = lce.getOldLevel() as PCClassLevel?;
    if (old == null) return;
    final id = lce.getCharID();
    final pcc = lce.getPCClass() as PCClass;
    if (classLevelFacet.remove(id, old, pcc)) {
      classLevelFacet.add(id, lce.getNewLevel() as PCClassLevel, pcc);
    }
  }

  void _update(CharID id, PCClass pcc, int oldLevel, int level) {
    for (int i = oldLevel + 1; i <= level; i++) {
      final classLevel = classFacet.getClassLevel(id, pcc, i);
      if (classLevel != null) classLevelFacet.add(id, classLevel, pcc);
    }
    for (int i = oldLevel; i > level; i--) {
      final classLevel = classFacet.getClassLevel(id, pcc, i);
      if (classLevel != null) classLevelFacet.remove(id, classLevel, pcc);
    }
  }
}
