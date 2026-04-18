import '../../base/util/map_to_list.dart';
import '../../cdom/base/associated_prereq_object.dart';
import 'associated_changes.dart';

class AssociatedCollectionChanges<T> implements AssociatedChanges<T> {
  final MapToList<T, AssociatedPrereqObject>? _positive;
  final MapToList<T, AssociatedPrereqObject>? _negative;
  final bool _clear;

  AssociatedCollectionChanges(
    MapToList<T, AssociatedPrereqObject>? added,
    MapToList<T, AssociatedPrereqObject>? removed,
    bool globallyCleared,
  )   : _positive = added,
        _negative = removed,
        _clear = globallyCleared;

  @override
  bool includesGlobalClear() => _clear;

  bool isEmpty() => !_clear && !hasAddedItems() && !hasRemovedItems();

  @override
  List<T>? getAdded() => _positive?.getKeySet().toList();

  bool hasAddedItems() => _positive != null && !_positive!.isEmpty();

  @override
  List<T>? getRemoved() {
    if (_negative == null) return null;
    return _negative!.getKeySet().toList();
  }

  bool hasRemovedItems() => _negative != null && !_negative!.isEmpty();

  @override
  MapToList<T, AssociatedPrereqObject>? getAddedAssociations() => _positive;

  @override
  MapToList<T, AssociatedPrereqObject>? getRemovedAssociations() => _negative;
}
