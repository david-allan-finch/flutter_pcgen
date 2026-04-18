// Holds a list of Indirect references for formula dependency tracking.
class ReferenceDependency {
  List<dynamic>? _references; // List<Indirect<?>>

  void put(dynamic reference) {
    _references ??= [];
    _references!.add(reference);
  }

  void putAll(Iterable<dynamic> collection) {
    for (final ref in collection) {
      put(ref);
    }
  }

  List<dynamic> getReferences() =>
      _references == null ? const [] : List.unmodifiable(_references!);
}
