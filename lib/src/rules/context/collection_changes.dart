import 'changes.dart';

class CollectionChanges<T> implements Changes<T> {
  final List<T>? _positive;
  final List<T>? _negative;
  final bool _clear;

  const CollectionChanges(List<T>? added, List<T>? removed, bool globallyCleared)
      : _positive = added,
        _negative = removed,
        _clear = globallyCleared;

  @override
  bool includesGlobalClear() => _clear;

  @override
  bool isEmpty() => !_clear && !hasAddedItems() && !hasRemovedItems();

  @override
  List<T>? getAdded() => _positive;

  @override
  bool hasAddedItems() => _positive != null && _positive!.isNotEmpty;

  @override
  List<T>? getRemoved() => _negative;

  @override
  bool hasRemovedItems() => _negative != null && _negative!.isNotEmpty;
}
