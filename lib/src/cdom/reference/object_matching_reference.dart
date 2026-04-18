import '../base/cdom_object.dart';
import '../base/cdom_reference.dart';
import '../enumeration/grouping_state.dart';
import '../enumeration/object_key.dart';
import 'cdom_group_ref.dart';

// A CDOMReference that contains objects whose ObjectKey matches an expected value.
class ObjectMatchingReference<T extends CDOMObject, V>
    extends CDOMReference<T> {
  final CDOMGroupRef<T> _all;
  final ObjectKey<V> _key;
  final V? _value;
  bool _allowNull = false;

  ObjectMatchingReference(
      String unparse, CDOMGroupRef<T> startingGroup, ObjectKey<V> targetKey,
      [V? expectedValue])
      : _all = startingGroup,
        _key = targetKey,
        _value = expectedValue,
        super(unparse);

  void returnIncludesNulls(bool includesNulls) => _allowNull = includesNulls;

  @override
  bool contains(T item) {
    if (!_all.contains(item)) return false;
    final actual = item.get(_key);
    if (actual == null) return _allowNull || _value == null;
    return _value == actual;
  }

  @override
  void addResolution(T item) {
    throw StateError('Cannot add resolution to ObjectMatchingReference');
  }

  @override
  List<T> getContainedObjects() {
    final list = <T>[];
    for (final obj in _all.getContainedObjects()) {
      final actual = obj.get(_key);
      if ((actual == null && (_value == null || _allowNull)) ||
          (_value != null && _value == actual)) {
        list.add(obj);
      }
    }
    return list;
  }

  @override
  int getObjectCount() {
    int count = 0;
    for (final obj in _all.getContainedObjects()) {
      final actual = obj.get(_key);
      if ((_value == null && actual == null) || (_value != null && _value == actual)) {
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
      '${_all.getReferenceDescription()} (Object $_key = $_value)';

  @override
  String getPersistentFormat() => _all.getPersistentFormat();

  @override
  bool operator ==(Object other) {
    if (other is ObjectMatchingReference<T, V>) {
      return getReferenceClass() == other.getReferenceClass() &&
          _all == other._all &&
          _key == other._key &&
          _value == other._value;
    }
    return false;
  }

  @override
  int get hashCode =>
      getReferenceClass().hashCode ^
      _key.hashCode +
          (_value == null ? -1 : _value.hashCode);
}
