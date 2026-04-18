import '../base/class_identity.dart';
import '../base/cdom_reference.dart';
import '../enumeration/grouping_state.dart';
import 'cdom_group_ref.dart';

// A CDOMGroupRef that contains objects matching one or more TYPE tags.
final class CDOMTypeRef<T> extends CDOMReference<T> implements CDOMGroupRef<T> {
  final ClassIdentity<T> _identity;
  final List<String> _types;
  List<T>? _referencedList;

  CDOMTypeRef(ClassIdentity<T> identity, List<String> typeArray)
      : _identity = identity,
        _types = List.unmodifiable(typeArray),
        super('${identity.getReferenceDescription()} $typeArray');

  @override
  String getLSTformat([String? joinWith]) =>
      'TYPE=${_types.join('.')}';

  @override
  bool contains(T item) {
    if (_referencedList == null) {
      throw StateError('Cannot ask for contains: Reference has not been resolved');
    }
    return _referencedList!.contains(item);
  }

  @override
  void addResolution(T item) {
    _referencedList ??= [];
    _referencedList!.add(item);
  }

  @override
  int getObjectCount() => _referencedList?.length ?? 0;

  @override
  List<T> getContainedObjects() {
    if (_referencedList == null) {
      throw StateError('Cannot ask for contained objects: Reference has not been resolved');
    }
    return List.unmodifiable(_referencedList!);
  }

  @override
  GroupingState getGroupingState() => GroupingState.any;

  @override
  String? getChoice() => null;

  @override
  Type getReferenceClass() => _identity.getReferenceClass();

  @override
  String getReferenceDescription() =>
      '${_identity.getReferenceDescription()} of TYPE=$_types';

  @override
  String getPersistentFormat() => _identity.getPersistentFormat();

  @override
  bool operator ==(Object other) {
    if (other is CDOMTypeRef<T>) {
      return getReferenceClass() == other.getReferenceClass() &&
          getName() == other.getName() &&
          _types.length == other._types.length &&
          _types.every((t) => other._types.contains(t));
    }
    return false;
  }

  @override
  int get hashCode => getReferenceClass().hashCode ^ getName().hashCode;
}
