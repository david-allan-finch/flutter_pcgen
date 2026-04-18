/// Tracks changes to a map so that the changes can be committed or rolled back
/// at a later stage. Items can be added to the map, removed from the map or the
/// map can be cleared.
class PatternChanges<T> {
  final List<T>? _positive;
  final List<String>? _negative;
  final bool _clear;

  PatternChanges(List<T>? added, List<String>? removed, bool globallyCleared)
      : _positive = added,
        _negative = removed,
        _clear = globallyCleared;

  bool includesGlobalClear() => _clear;

  bool isEmpty() => !_clear && !hasAddedItems() && !hasRemovedItems();

  List<T>? getAdded() => _positive;

  bool hasAddedItems() => _positive != null && _positive!.isNotEmpty;

  List<String>? getRemoved() => _negative;

  bool hasRemovedItems() => _negative != null && _negative!.isNotEmpty;
}
