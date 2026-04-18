// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.TermUtil

/// Internal utility for converting string formula results to doubles.
class TermUtil {
  TermUtil._();

  static double? convertToFloat(String element, String? aNumber) {
    if (aNumber == null) return null;
    final d = double.tryParse(aNumber);
    if (d == null || d.isNaN) return null;
    return d;
  }
}
