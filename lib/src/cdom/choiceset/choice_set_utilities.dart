// Utility methods for working with PrimitiveChoiceSet-like objects.
class ChoiceSetUtilities {
  ChoiceSetUtilities._();

  // Compares two choice set objects by their LST format string.
  // Returns 0 if equal, negative if pcs1 sorts first, positive if pcs2 sorts first.
  static int compareChoiceSets(dynamic pcs1, dynamic pcs2) {
    final String? base = pcs1.getLSTformat(false) as String?;
    final String? other = pcs2.getLSTformat(false) as String?;
    if (base == null) {
      return other == null ? 0 : -1;
    } else {
      if (other == null) {
        return 1;
      } else {
        return base.compareTo(other);
      }
    }
  }

  // Concatenates the LST format of a collection of choice sets using a separator.
  // Returns an empty string if the collection is null.
  static String joinLstFormat(
    Iterable? pcsCollection,
    String separator,
    bool useAny,
  ) {
    if (pcsCollection == null) {
      return '';
    }
    final StringBuffer result = StringBuffer();
    bool needJoin = false;
    for (final dynamic pcs in pcsCollection) {
      if (needJoin) {
        result.write(separator);
      }
      needJoin = true;
      result.write(pcs.getLSTformat(useAny) as String);
    }
    return result.toString();
  }
}
