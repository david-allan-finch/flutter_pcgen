// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.BasePCCountAbilitiesTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';

/// Abstract base for term evaluators that count abilities on a PlayerCharacter.
abstract class BasePCCountAbilitiesTermEvaluator extends BasePCTermEvaluator {
  /// The ability category to count in.
  dynamic abCat;
  bool visible = true;
  bool hidden = false;

  /// Returns the collection of abilities to count.
  List<dynamic> getAbilities(dynamic pc);

  /// Counts abilities in [aList] that are visible and/or hidden.
  /// Uses duck-typing for visibility: calls ability.isVisibleToExport() if available.
  double countVisibleAbilities(
      dynamic pc, Iterable<dynamic> aList, bool visible, bool hidden) {
    double count = 0.0;
    for (final ability in aList) {
      count += countVisibleAbility(pc, ability, visible, hidden, true);
    }
    return count;
  }

  /// Counts a single ability based on visibility flags.
  /// [onceOnly] — if true, counts at most 1 even if taken multiple times.
  double countVisibleAbility(dynamic pc, dynamic cna, bool visible, bool hidden,
      bool onceOnly) {
    // TODO: Requires ObjectKey.VISIBILITY and View.HIDDEN_EXPORT check.
    // Stub: uses isHiddenFromExport() if available, otherwise treats as visible.
    bool abilityInvisible = false;
    try {
      abilityInvisible = cna.getAbility().isHiddenFromExport() == true;
    } catch (_) {}

    int count = 0;
    if (abilityInvisible) {
      if (hidden) {
        count += onceOnly
            ? 1
            : _max1(pc.getSelectCorrectedAssociationCount(cna) as num? ?? 1);
      }
    } else {
      if (visible) {
        count += onceOnly
            ? 1
            : _max1(pc.getSelectCorrectedAssociationCount(cna) as num? ?? 1);
      }
    }
    return count.toDouble();
  }

  int _max1(num n) => n.toInt() < 1 ? 1 : n.toInt();
}
