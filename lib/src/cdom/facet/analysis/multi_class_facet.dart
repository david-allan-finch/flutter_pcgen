// Copyright (c) Tom Parker, 2010.
//
// Translation of pcgen.cdom.facet.analysis.MultiClassFacet

import '../../enumeration/char_id.dart';
import '../model/class_facet.dart';
import '../sub_class_facet.dart';
import 'favored_class_facet.dart';
import 'has_any_favored_class_facet.dart';

/// Performs calculations related to multi-class characters (e.g. XP penalty multiplier).
class MultiClassFacet {
  late FavoredClassFacet favoredClassFacet;
  late HasAnyFavoredClassFacet hasAnyFavoredClassFacet;
  late ClassFacet classFacet;
  late SubClassFacet subClassFacet;

  /// Returns the multi-class XP multiplier for the Player Character.
  double getMultiClassXPMultiplier(CharID id) {
    final favored = favoredClassFacet.getSet(id).toSet();
    final hasAny = hasAnyFavoredClassFacet.contains(id, true);
    final unfavoredClasses = <dynamic>{};
    dynamic maxClass;
    dynamic secondClass;
    int maxClassLevel = 0;
    int secondClassLevel = 0;
    double xpMultiplier = 1.0;

    for (final pcClass in classFacet.getSet(id)) {
      if (!pcClass.hasXPPenalty()) continue;

      final subClassKey = subClassFacet.get(id, pcClass);
      var evalClass = pcClass;
      if (subClassKey != null && subClassKey != 'None') {
        evalClass = pcClass.getSubClassKeyed(subClassKey) ?? pcClass;
      }

      if (!favored.contains(evalClass)) {
        unfavoredClasses.add(pcClass);

        final pcClassLevel = classFacet.getLevel(id, pcClass);
        if (pcClassLevel > maxClassLevel) {
          if (hasAny) {
            secondClassLevel = maxClassLevel;
            secondClass = maxClass;
          }
          maxClassLevel = pcClassLevel;
          maxClass = pcClass;
        } else if (pcClassLevel > secondClassLevel && hasAny) {
          secondClassLevel = pcClassLevel;
          secondClass = pcClass;
        }
      }
    }

    if (hasAny && secondClassLevel > 0) {
      maxClassLevel = secondClassLevel;
      unfavoredClasses.remove(maxClass);
      maxClass = secondClass;
    }

    if (maxClassLevel > 0) {
      unfavoredClasses.remove(maxClass);
      int xpPenalty = 0;
      for (final aClass in unfavoredClasses) {
        if ((maxClassLevel - classFacet.getLevel(id, aClass)) > 1) {
          xpPenalty++;
        }
      }
      xpMultiplier = 1.0 - xpPenalty * 0.2;
      if (xpMultiplier < 0) xpMultiplier = 0;
    }

    return xpMultiplier;
  }
}
