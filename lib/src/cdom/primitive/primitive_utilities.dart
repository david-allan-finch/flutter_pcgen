// Utility methods for working with PrimitiveCollection objects.
final class PrimitiveUtilities {
  PrimitiveUtilities._();

  // Sorts PrimitiveCollection objects by LST format string.
  static int collectionSorter(dynamic a, dynamic b) =>
      (a.getLSTformat(false) as String)
          .compareTo(b.getLSTformat(false) as String);

  // Joins the LST formats of a collection of PrimitiveCollection objects.
  static String joinLstFormat(
      Iterable<dynamic> pcCollection, String separator, bool useAny) =>
      pcCollection
          .map((pcf) => pcf.getLSTformat(useAny) as String)
          .join(separator);
}
