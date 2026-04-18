// Copyright (c) Tom Parker, 2012-2014.
//
// Translation of pcgen.core.display.SkillCostDisplay

/// Utilities for generating skill modifier explanation strings for display.
class SkillCostDisplay {
  SkillCostDisplay._();

  /// Builds a string explaining what makes up the misc modifier for [sk].
  ///
  /// [shortForm] selects abbreviated output (e.g. "+2[TUMBLE]" vs. the full
  /// bonus-object description).
  static String getModifierExplanation(
      dynamic sk, dynamic aPC, bool shortForm) {
    final explanation = <String>[];
    final keyName = sk.getKeyName() as String;
    final bonusKey = 'SKILL.$keyName'.toUpperCase();
    double bonusObjTotal = 0.0;

    for (final bonus in aPC.getActiveBonusList() as Iterable) {
      if (!(aPC.isApplied(bonus) as bool? ?? false)) continue;
      if (bonus.getBonusName() != 'SKILL') continue;

      bool include = _bonusForThisSkill(bonus, keyName);
      if (!include) {
        for (final bp in aPC.getStringListFromBonus(bonus) as Iterable) {
          if ((bp.fullyQualifiedBonusType as String).toUpperCase() == bonusKey) {
            include = true;
            break;
          }
        }
      }

      if (!include) continue;

      final value = aPC.getBonus(bonus) as double? ?? 0.0;
      bonusObjTotal += value;

      if (shortForm) {
        explanation.add(
            '${_deltaString(value)}[${bonus.getBonusInfo() ?? bonus}]');
      } else {
        explanation.add('${_deltaString(value)}[${bonus.toString()}]');
      }
    }

    // Summarise anything not explained individually as "OTHER".
    final totalMisc = sk.getMiscMod(aPC) as double? ?? 0.0;
    final other = totalMisc - bonusObjTotal;
    if (other.abs() > 0.001) {
      explanation.add('${_deltaString(other)}[OTHER]');
    }

    return explanation.join(' ');
  }

  /// Builds an explanation for a situation-specific modifier on [sk].
  static String getSituationModifierExplanation(
      dynamic sk, String situation, dynamic aPC, bool shortForm) {
    // TODO: implement full situation modifier breakdown
    return '';
  }

  /// Appends a bonus description entry to [bonusDetails].
  static void appendBonusDesc(
      StringBuffer bonusDetails, double bonus, String description) {
    if (bonusDetails.isNotEmpty) bonusDetails.write(' ');
    bonusDetails.write(_deltaString(bonus));
    bonusDetails.write('[');
    bonusDetails.write(description);
    bonusDetails.write(']');
  }

  /// Returns a string explaining the sources of ranks for [sk].
  static String getRanksExplanation(dynamic pc, dynamic sk) {
    final ranks = <String>[];
    for (final cls in pc.getClassList() as Iterable) {
      final r = pc.getSkillRankForClass(sk, cls) as double? ?? 0.0;
      if (r != 0.0) {
        ranks.add('${_deltaString(r)}[${cls.getKeyName()}]');
      }
    }
    return ranks.join(' ');
  }

  static bool _bonusForThisSkill(dynamic bonus, String keyName) {
    final info = bonus.getBonusInfo() as String? ?? '';
    return info.equalsIgnoreCase(keyName) ||
        info.equalsIgnoreCase('LIST') ||
        info.toUpperCase().startsWith('TYPE=') ||
        info.toUpperCase().startsWith('TYPE.');
  }

  static String _deltaString(double value) {
    if (value >= 0) return '+${value.toInt()}';
    return '${value.toInt()}';
  }
}

extension on String {
  bool equalsIgnoreCase(String other) =>
      toLowerCase() == other.toLowerCase();
}
