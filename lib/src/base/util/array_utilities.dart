class ArrayUtilities {
  ArrayUtilities._();

  static List<T> mergeArray<T>(List<T> first, List<T> second) {
    return [...first, ...second];
  }

  static bool containsMatch<T>(List<T> array, bool Function(T) predicate) {
    return array.any(predicate);
  }

  static int indexOf<T>(List<T> array, T element) {
    return array.indexOf(element);
  }

  static List<T> toList<T>(T? item) {
    if (item == null) return [];
    return [item];
  }
}
