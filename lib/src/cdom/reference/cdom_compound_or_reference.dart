import '../base/cdom_reference.dart';
import '../base/class_identity.dart';
import '../enumeration/grouping_state.dart';
import 'cdom_group_ref.dart';

// A CDOMGroupRef that joins one or more CDOMReferences with logical OR:
// an object is contained if any underlying reference contains it.
class CDOMCompoundOrReference<T> extends CDOMReference<T>
    implements CDOMGroupRef<T> {
  final ClassIdentity<T> _identity;
  final List<CDOMReference<T>> _references = [];

  CDOMCompoundOrReference(ClassIdentity<T> identity, String refName)
      : _identity = identity,
        super(refName);

  void addReference(CDOMReference<T> ref) {
    if (getReferenceClass() != ref.getReferenceClass()) {
      throw ArgumentError('Cannot add reference of ${ref.getReferenceClass()} '
          'to CDOMCompoundOrReference of ${getReferenceClass()}');
    }
    _references.add(ref);
  }

  void trimToSize() {} // no-op in Dart

  @override
  bool contains(T item) => _references.any((ref) => ref.contains(item));

  @override
  void addResolution(T item) {
    throw StateError('CompoundReference cannot be given a resolution');
  }

  @override
  List<T> getContainedObjects() {
    final set = <T>{};
    for (final ref in _references) {
      set.addAll(ref.getContainedObjects());
    }
    return set.toList();
  }

  @override
  int getObjectCount() =>
      _references.fold(0, (count, ref) => count + ref.getObjectCount());

  @override
  GroupingState getGroupingState() {
    var state = GroupingState.empty;
    for (final ref in _references) {
      state = state.add(ref.getGroupingState());
    }
    return state.compound(GroupingState.allowsUnion);
  }

  @override
  String getLSTformat([String? joinWith]) =>
      _references.map((r) => r.getLSTformat()).join(',');

  @override
  String? getChoice() => null;

  @override
  Type getReferenceClass() => _identity.getReferenceClass();

  @override
  String getReferenceDescription() {
    final parts = _references
        .map((r) => r.getReferenceDescription())
        .join(' OR ');
    return '${_identity.getReferenceDescription()}[$parts]';
  }

  @override
  String getPersistentFormat() => _identity.getPersistentFormat();
}
