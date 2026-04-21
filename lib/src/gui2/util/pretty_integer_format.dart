// Translation of pcgen.gui2.util.PrettyIntegerFormat

/// Formats small integers (e.g. ability modifiers) with a leading "+" for
/// positive values and the proper Unicode minus sign (U+2212) for negatives.
/// Values outside ±999 may not render symmetrically due to digit-width variance.
class PrettyIntegerFormat {
  PrettyIntegerFormat._();

  static final PrettyIntegerFormat _instance = PrettyIntegerFormat._();

  /// Returns the singleton formatter instance.
  static PrettyIntegerFormat getFormat() => _instance;

  /// Formats [value] as a signed integer string using "+" and "−".
  String format(int value) {
    if (value >= 0) {
      return '+$value';
    } else {
      // Replace the ASCII hyphen-minus with the proper Unicode minus sign.
      return '\u2212${value.abs()}';
    }
  }

  /// Parses a previously formatted string back to an [int], or returns null.
  int? parse(String text) {
    final cleaned = text
        .replaceAll('\u2212', '-')
        .replaceAll('+', '');
    return int.tryParse(cleaned);
  }
}
