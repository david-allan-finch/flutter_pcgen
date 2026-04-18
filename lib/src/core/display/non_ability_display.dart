// Copyright (c) Tom Parker, 2012.
//
// Translation of pcgen.core.display.NonAbilityDisplay

/// Utilities for determining whether a stat is treated as a non-ability
/// for a given CDOMObject.
class NonAbilityDisplay {
  NonAbilityDisplay._();

  /// Returns true if [stat] is locked as a non-ability in [po].
  ///
  /// An explicit unlock (NONSTAT_TO_STAT_STATS) always overrides a lock
  /// (NONSTAT_STATS).
  static bool isNonAbilityForObject(dynamic stat, dynamic po) {
    if (po == null) return false;

    // An unlock overrides a lock — check it first.
    final unlocked = po.getSafeListFor('NONSTAT_TO_STAT_STATS') as List? ?? [];
    if (unlocked.any((v) => v.get() == stat)) return false;

    final locked = po.getSafeListFor('NONSTAT_STATS') as List? ?? [];
    return locked.any((v) => v.get() == stat);
  }
}
