class SetUtilities {
  SetUtilities._();

  static Set<T> getIntersection<T>(Set<T> first, Set<T> second) {
    return first.intersection(second);
  }

  static Set<T> getUnion<T>(Set<T> first, Set<T> second) {
    return first.union(second);
  }

  static Set<T> getDifference<T>(Set<T> first, Set<T> second) {
    return first.difference(second);
  }
}
