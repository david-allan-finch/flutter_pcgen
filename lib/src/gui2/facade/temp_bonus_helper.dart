// Translation of pcgen.gui2.facade.TempBonusHelper

/// Utility class for processing and categorizing temporary bonuses.
class TempBonusHelper {
  TempBonusHelper._();

  /// Returns true if the bonus applies to the given category.
  static bool appliesTo(Map<String, dynamic> bonus, String category) {
    final targets = bonus['targets'];
    if (targets == null) return true;
    if (targets is List) return targets.contains(category);
    return targets.toString() == category;
  }

  /// Formats a bonus value as a signed string (+3, -1, etc.).
  static String formatBonus(int value) {
    return value >= 0 ? '+$value' : '$value';
  }

  /// Returns the display name of the bonus.
  static String getBonusName(Map<String, dynamic> bonus) {
    return bonus['name'] as String? ?? bonus['source']?.toString() ?? 'Unknown';
  }

  /// Returns the bonus value as a string expression.
  static String getBonusExpression(Map<String, dynamic> bonus) {
    return bonus['expression'] as String? ?? '0';
  }

  /// Returns the bonus type (e.g. 'Enhancement', 'Luck', etc.).
  static String getBonusType(Map<String, dynamic> bonus) {
    return bonus['type'] as String? ?? '';
  }

  /// Returns true if this bonus has a character target selection requirement.
  static bool requiresTarget(Map<String, dynamic> bonus) {
    return bonus['requiresTarget'] as bool? ?? false;
  }

  /// Returns the associated spells list for a temp bonus (if spell-based).
  static List<dynamic> getAssociatedSpells(Map<String, dynamic> bonus) {
    final spells = bonus['associatedSpells'];
    return spells is List ? spells : [];
  }

  /// Merges a list of bonus maps into a total per stat.
  static Map<String, int> sumBonusesByTarget(List<Map<String, dynamic>> bonuses) {
    final result = <String, int>{};
    for (final bonus in bonuses) {
      final targets = bonus['targets'];
      final value = (bonus['value'] as num?)?.toInt() ?? 0;
      if (targets is List) {
        for (final t in targets) {
          result[t.toString()] = (result[t.toString()] ?? 0) + value;
        }
      } else if (targets != null) {
        final key = targets.toString();
        result[key] = (result[key] ?? 0) + value;
      }
    }
    return result;
  }
}
