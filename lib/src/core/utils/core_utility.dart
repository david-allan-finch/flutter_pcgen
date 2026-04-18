// Copyright (c) Bryan McRoberts, 2002.
//
// Translation of pcgen.core.utils.CoreUtility

import 'dart:math' as math;

/// General-purpose utility methods used throughout PCGen's core.
class CoreUtility {
  CoreUtility._();

  static const double _epsilon = 0.0001;

  /// Comparator for Equipment by outputIndex, then outputSubindex, then name.
  static int equipmentCompare(dynamic eq1, dynamic eq2) {
    int o1i = (eq1.getOutputIndex() as int? ?? 0);
    int o2i = (eq2.getOutputIndex() as int? ?? 0);
    if (o1i == 0) o1i = 999;
    if (o2i == 0) o2i = 999;
    final r1 = o1i.compareTo(o2i);
    if (r1 != 0) return r1;

    final r2 = ((eq1.getOutputSubindex() as int? ?? 0))
        .compareTo(eq2.getOutputSubindex() as int? ?? 0);
    if (r2 != 0) return r2;

    final r3 = (eq1.getName() as String)
        .toLowerCase()
        .compareTo((eq2.getName() as String).toLowerCase());
    if (r3 != 0) return r3;

    return (eq1.getAppliedName() as String)
        .toLowerCase()
        .compareTo((eq2.getAppliedName() as String).toLowerCase());
  }

  /// Returns true if [uri] uses a non-file scheme.
  static bool isNetUri(Uri uri) => uri.scheme != 'file';

  /// Capitalizes the first letter of every word in [aString].
  static String capitalizeFirstLetter(String aString) {
    bool toUpper = true;
    final chars = aString.toLowerCase().split('');
    for (int i = 0; i < chars.length; i++) {
      if (chars[i].trim().isEmpty) {
        toUpper = true;
      } else if (toUpper) {
        chars[i] = chars[i].toUpperCase();
        toUpper = false;
      }
    }
    return chars.join();
  }

  /// Returns true if |a - b| < [eps].
  static bool compareDouble(double a, double b, double eps) =>
      (a - b).abs() < eps;

  /// Returns true if |a - b| < 0.0001.
  static bool doublesEqual(double a, double b) =>
      compareDouble(a, b, _epsilon);

  /// Returns floor(d + epsilon).
  static double epsilonFloor(double d) => (d + _epsilon).floorToDouble();

  /// Replaces path separators with the platform separator.
  static String fixFilenamePath(String argFileName) =>
      argFileName.replaceAll('/', '/').replaceAll('\\', '/');

  /// Returns the index of the closing `)` for the innermost `(…)` pair.
  static int innerMostStringEnd(String aString) {
    int index = 0;
    int hi = 0;
    int current = 0;
    for (int i = 0; i < aString.length; i++) {
      if (aString[i] == '(') {
        current++;
        if (current > hi) hi = current;
      } else if (aString[i] == ')') {
        if (current == hi) index = i;
        current--;
      }
    }
    return index;
  }

  /// Returns the index of the opening `(` for the innermost `(…)` pair.
  static int innerMostStringStart(String aString) {
    int index = 0;
    int hi = 0;
    int current = 0;
    for (int i = 0; i < aString.length; i++) {
      if (aString[i] == '(') {
        current++;
        if (current >= hi) {
          hi = current;
          index = i;
        }
      } else if (aString[i] == ')') {
        current--;
      }
    }
    return index;
  }

  /// Returns the English ordinal suffix string for [iValue] (e.g. "1st", "2nd").
  static String ordinal(int iValue) {
    String suffix = 'th';
    if (iValue < 4 || iValue > 20) {
      switch (iValue % 10) {
        case 1:
          suffix = 'st';
          break;
        case 2:
          suffix = 'nd';
          break;
        case 3:
          suffix = 'rd';
          break;
      }
    }
    return '$iValue$suffix';
  }

  /// Splits [aString] by [separator] and returns trimmed parts.
  /// Returns an empty list if [aString] is blank.
  static List<String> split(String aString, String separator) {
    if (aString.trim().isEmpty) return [];
    return aString
        .split(separator)
        .map((s) => s.trim())
        .toList();
  }

  /// Compares two version arrays element by element.
  ///
  /// Returns negative, zero, or positive like [Comparable.compareTo].
  static int compareVersionArrays(List<int> ver, List<int> compVer) {
    final len = math.min(ver.length, compVer.length);
    for (int i = 0; i < len; i++) {
      final r = ver[i].compareTo(compVer[i]);
      if (r != 0) return r;
    }
    return ver.length.compareTo(compVer.length);
  }

  /// Compares two dot-separated version strings.
  static int compareVersionStrings(String ver, String compVer) {
    return compareVersionArrays(
        convertVersionToNumber(ver), convertVersionToNumber(compVer));
  }

  /// Converts a dot-separated version string to a list of integers.
  static List<int> convertVersionToNumber(String version) {
    return version
        .split('.')
        .map((s) => int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
  }

  /// Merges an equipment list according to [merge] strategy.
  /// Strategy values: 0 = no merge, 1 = merge location, 2 = merge all.
  static List<dynamic> mergeEquipmentList(
      Iterable<dynamic> equip, int merge) {
    if (merge == 0) return List<dynamic>.from(equip);
    final merged = <String, dynamic>{};
    for (final eq in equip) {
      final key = merge == 2
          ? eq.getName() as String
          : '${eq.getName()}|${eq.getLocation()}';
      if (merged.containsKey(key)) {
        merged[key].addQty(eq.qty());
      } else {
        merged[key] = eq;
      }
    }
    final result = merged.values.toList();
    result.sort(equipmentCompare);
    return result;
  }
}
