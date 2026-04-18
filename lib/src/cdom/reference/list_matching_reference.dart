import '../base/cdom_object.dart';
import '../base/cdom_reference.dart';
import '../enumeration/grouping_state.dart';
import '../enumeration/list_key.dart';
import 'cdom_group_ref.dart';

// A CDOMReference that contains objects whose ListKey includes an expected value.
class ListMatchingReference<T extends CDOMObject, V>
    extends CDOMReference<T> {
  final CDOMGroupRef<T> _all;
  final ListKey<V> _key;
  final V? _value;

  ListMatchingReference(
      String unparse, CDOMGroupRef<T> startingGroup, ListKey<V> targetKey,
      [V? expectedValue])
      : _all = startingGroup,
        _key = targetKey,
        _value = expectedValue,
        super(unparse);

  @override
  bool contains(T item) {
    if (!_all.contains(item)) return false;
    final actualList = item.getListFor(_key);
    if (actualList == null) return false;
    return actualList.any((actual) => _value != null && _value == actual);
  }

  @override
  void addResolution(T item) {
    throw StateError('Cannot add resolution to ListMatchingReference');
  }

  @override
  List<T> getContainedObjects() {
    final list = <T>[];
    for (final obj in _all.getContainedObjects()) {
      final actualList = obj.getListFor(_key);
      if (actualList != null &&
          actualList.any((actual) => _value != null && _value == actual)) {
        list.add(obj);
      }
    }
    return list;
  }

  @override
  int getObjectCount() {
    int count = 0;
    for (final obj in _all.getContainedObjects()) {
      final actualList = obj.getListFor(_key);
      if (actualList != null &&
          actualList.any((actual) => _value != null && _value == actual)) {
        count++;
      }
    }
    return count;
  }

  @override
  String getLSTformat([String? joinWith]) => getName();

  @override
  GroupingState getGroupingState() => GroupingState.any;

  @override
  String? getChoice() => null;

  @override
  Type getReferenceClass() => _all.getReferenceClass();

  @override
  String getReferenceDescription() =>
      '${_all.getReferenceDescription()} (List $_key = $_value)';

  @override
  String getPersistentFormat() => _all.getPersistentFormat();

  @override
  bool operator ==(Object other) {
    if (other is ListMatchingReference<T, V>) {
      if (getReferenceClass() == other.getReferenceClass() &&
          _all == other._all &&
          _key == other._key) {
        return _value == null ? other._value == null : _value == other._value;
      }
    }
    return false;
  }

  @override
  int get hashCode =>
      getReferenceClass().hashCode ^
      _key.hashCode +
          (_value == null ? -1 : _value.hashCode);
}
