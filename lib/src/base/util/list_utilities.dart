class ListUtilities {
  ListUtilities._();

  static List<T> getIntersection<T>(List<T> first, List<T> second) {
    return first.where((e) => second.contains(e)).toList();
  }

  static bool containsAny<T>(List<T> list, Iterable<T> items) {
    return items.any((item) => list.contains(item));
  }

  static List<T> copyOf<T>(List<T> list) => List<T>.from(list);
}
