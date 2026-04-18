import '../base/cdom_reference.dart';
import '../enumeration/grouping_state.dart';
import 'cdom_group_ref.dart';
import 'cdom_single_ref.dart';

// A CDOMGroupRef that returns all objects from a base group reference except
// those matched by any of the prohibited single refs.
class FilteredReference<T> extends CDOMReference<T>
    implements CDOMGroupRef<T> {
  final Set<CDOMSingleRef<T>> _filterSet = {};
  final CDOMGroupRef<T> _baseSet;

  FilteredReference(CDOMGroupRef<T> allRef)
      : _baseSet = allRef,
        super('Filtered Reference');

  void addProhibitedItem(CDOMSingleRef<T> prohibitedRef) {
    _filterSet.add(prohibitedRef);
  }

  @override
  bool contains(T item) => getContainedObjects().contains(item);

  @override
  void addResolution(T item) {
    throw StateError('FilteredReference cannot be given a resolution');
  }

  @override
  List<T> getContainedObjects() {
    final choices = Set<T>.from(_baseSet.getContainedObjects());
    choices.removeWhere(
        (choice) => _filterSet.any((ref) => ref.contains(choice)));
    return choices.toList();
  }

  @override
  int getObjectCount() =>
      _baseSet.getContainedObjects().length - _filterSet.length;

  @override
  GroupingState getGroupingState() {
    var state = GroupingState.empty;
    for (final ref in _filterSet) {
      state = ref.getGroupingState().add(state);
    }
    return _filterSet.length == 1
        ? state
        : state.compound(GroupingState.allowsUnion);
  }

  @override
  String getLSTformat([String? joinWith]) {
    final sorted = _filterSet.map((r) => r.getLSTformat()).toList()..sort();
    return 'ALL|!${sorted.join('|!')}';
  }

  @override
  String? getChoice() => null;

  @override
  Type getReferenceClass() => _baseSet.getReferenceClass();

  @override
  String getReferenceDescription() {
    final excepts = _filterSet
        .map((r) => r.getReferenceDescription())
        .join(', ');
    return '${_baseSet.getReferenceDescription()} except: [$excepts]';
  }

  @override
  String getPersistentFormat() => _baseSet.getPersistentFormat();

  @override
  bool operator ==(Object other) {
    if (other is FilteredReference<T>) {
      return _baseSet == other._baseSet && _filterSet == other._filterSet;
    }
    return false;
  }

  @override
  int get hashCode => _baseSet.hashCode + _filterSet.length;
}
