/// Tracks changes to a map so that the changes can be committed or rolled back
/// at a later stage. Items can be added to the map, removed from the map or the
/// map can be cleared.
class MapChanges<K, V> {
  final Map<K, V>? _positive;
  final Map<K, V>? _negative;
  final bool _clear;

  MapChanges(Map<K, V>? added, Map<K, V>? removed, bool globallyCleared)
      : _positive = added,
        _negative = removed,
        _clear = globallyCleared;

  bool includesGlobalClear() => _clear;

  bool isEmpty() => !_clear && !hasAddedItems() && !hasRemovedItems();

  Map<K, V>? getAdded() => _positive;

  bool hasAddedItems() => _positive != null && _positive!.isNotEmpty;

  Map<K, V>? getRemoved() => _negative;

  bool hasRemovedItems() => _negative != null && _negative!.isNotEmpty;
}
