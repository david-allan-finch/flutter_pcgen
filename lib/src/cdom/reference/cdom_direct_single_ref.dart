import '../base/cdom_reference.dart';
import 'cdom_single_ref.dart';

// A direct reference that holds an object inline (no lookup needed).
class CDOMDirectSingleRef<T> implements CDOMSingleRef<T> {
  final T _obj;

  CDOMDirectSingleRef(this._obj);

  static CDOMDirectSingleRef<T> getRef<T>(T obj) => CDOMDirectSingleRef(obj);

  @override
  T get() => _obj;

  @override
  bool hasBeenResolved() => true;

  @override
  bool contains(T obj) => identical(_obj, obj) || _obj == obj;

  @override
  List<T> getContainedObjects() => [_obj];

  @override
  String getLSTformat([String? joinWith]) => _obj.toString();

  @override
  int getReferenceCount() => 1;

  @override
  String? getReferenceClass() => _obj.runtimeType.toString();

  @override
  String getPersistentFormat() => getLSTformat();

  @override
  String toString() => 'CDOMDirectSingleRef($_obj)';
}
