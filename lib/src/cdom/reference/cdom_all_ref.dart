import '../base/cdom_reference.dart';
import 'cdom_group_ref.dart';

// A reference to ALL objects of a given type.
class CDOMAllRef<T> implements CDOMGroupRef<T> {
  final List<T> _objects = [];
  final String _typeName;

  CDOMAllRef(this._typeName);

  @override
  void addResolution(T obj) {
    if (!_objects.contains(obj)) _objects.add(obj);
  }

  @override
  bool contains(T obj) => _objects.contains(obj);

  @override
  List<T> getContainedObjects() => List.unmodifiable(_objects);

  @override
  String getLSTformat([String? joinWith]) => 'ALL';

  @override
  int getReferenceCount() => _objects.length;

  @override
  String? getReferenceClass() => _typeName;

  @override
  String getPersistentFormat() => 'ALL';

  @override
  String toString() => 'CDOMAllRef<$_typeName>';
}
