// Translation of pcgen.system.LanguageBundle

/// Provides localised strings from resource bundles.
final class LanguageBundle {
  static final Map<String, String> _bundle = {};

  LanguageBundle._();

  static void setBundle(Map<String, String> bundle) =>
      _bundle
        ..clear()
        ..addAll(bundle);

  static String getString(String key, [List<Object>? args]) {
    String? value = _bundle[key];
    if (value == null) return '[$key not defined]';
    if (args != null) {
      for (int i = 0; i < args.length; i++) {
        value = value!.replaceAll('{$i}', args[i].toString());
      }
    }
    return value!;
  }

  static int getMnemonic(String key, [String defaultChar = '']) {
    final s = _bundle[key];
    if (s == null || s.isEmpty) {
      return defaultChar.isEmpty ? 0 : defaultChar.codeUnitAt(0);
    }
    return s.codeUnitAt(0);
  }
}
