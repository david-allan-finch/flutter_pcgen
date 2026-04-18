// ChooseInformationUtilities provides static helpers for the CHOOSE system.
class ChooseInformationUtilities {
  ChooseInformationUtilities._();

  /// Converts each element to its string representation, sorts them, and
  /// joins with ", ".
  static String buildEncodedString<T>(Iterable<T> collection) {
    final strs = collection.map((e) => e.toString()).toList()..sort();
    return strs.join(', ');
  }
}
