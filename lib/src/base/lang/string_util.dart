class StringUtil {
  static const List<String> emptyStringArray = [];

  StringUtil._();

  static String joinCollection(Iterable<Object?> collection, String separator) {
    if (collection == null) return '';
    return collection.map((o) => o.toString()).join(separator);
  }

  static String joinChar(Iterable<Object?> collection, String separator) =>
      joinCollection(collection, separator);

  static String joinArray(List<String?> array, String separator) {
    if (array.isEmpty) return '';
    return array.join(separator);
  }

  static String replaceAll(String original, String find, String replace) {
    return original.replaceAll(find, replace);
  }

  static bool hasBalancedParens(String string) {
    int level = 0;
    for (final ch in string.split('')) {
      if (ch == ')') {
        level--;
      } else if (ch == '(') {
        level++;
      }
      if (level < 0) return false;
    }
    return level == 0;
  }

  static bool hasValidSeparators(String value, String separator) {
    return !value.startsWith(separator) &&
        !value.endsWith(separator) &&
        !value.contains('$separator$separator');
  }

  static List<String> split(String inputStr, String separator) {
    return inputStr.split(RegExp(RegExp.escape(separator)));
  }
}
