// Copyright (c) Tom Parker, 2012.
//
// Translation of pcgen.core.display.UnarmedDamageDisplay

/// Utilities for computing and formatting unarmed damage strings.
class UnarmedDamageDisplay {
  UnarmedDamageDisplay._();

  /// Returns the best unarmed damage string for [pc], optionally adjusting for
  /// PC size and including the STR bonus.
  static String getUnarmedDamageString(
      dynamic pc, bool includeStrBonus, bool adjustForPCSize) {
    final display = pc.getDisplay();
    String retString = '2|1d2';

    for (final pcClass in display.getClassSet() as Iterable) {
      retString = getBestUDamString(
          retString,
          pcClass.getUdamForLevel(
              display.getLevel(pcClass), pc, adjustForPCSize));
    }

    final sizeInt =
        adjustForPCSize ? pc.sizeInt() as int : pc.racialSizeInt() as int;
    for (final unarmedDamage
        in display.getUnarmedDamage() as Iterable<List<String>>) {
      final aDamage = unarmedDamage.length == 1
          ? unarmedDamage[0]
          : unarmedDamage[sizeInt];
      retString = getBestUDamString(retString, aDamage);
    }

    final pObjDamage = display.getUDamForRace() as String? ?? '';
    retString = getBestUDamString(retString, pObjDamage);

    // retString is in the form "sides|damage" — strip the prefix.
    final ret = StringBuffer(retString.substring(retString.indexOf('|') + 1));

    if (includeStrBonus) {
      int sb = (display.getStatBonusTo('DAMAGE', 'TYPE.MELEE') as num).toInt();
      sb += (display.getStatBonusTo('DAMAGE', 'TYPE=MELEE') as num).toInt();
      if (sb != 0) {
        ret.write(sb >= 0 ? '+$sb' : '$sb');
      }
    }

    return ret.toString();
  }

  /// Picks the bigger die size from two strings in the form "V|WdX" and "YdZ".
  ///
  /// Returns the string with the larger die face count.
  static String getBestUDamString(String oldString, String? newString) {
    if (newString == null || newString.length < 2) return oldString;

    final newParts = _tokenize(newString);
    if (newParts.isEmpty) return oldString;

    if (oldString.isEmpty || !oldString.contains('|')) {
      final sidesNew = newParts.length > 1 ? int.tryParse(newParts[1]) ?? 0 : 0;
      return '$sidesNew|$newString';
    }

    final pipIdx = oldString.indexOf('|');
    final oldSides = int.tryParse(oldString.substring(0, pipIdx)) ?? 0;

    if (newParts.length > 1) {
      final newSides = int.tryParse(newParts[1]) ?? 0;
      if (newSides > oldSides) {
        return '$newSides|$newString';
      }
    }

    return oldString;
  }

  static List<String> _tokenize(String s) {
    return s.split(RegExp(r'[ dD+\-(x)]')).where((t) => t.isNotEmpty).toList();
  }
}
