import 'class_identity.dart';

// BasicClassIdentity wraps a runtime Type and provides identity semantics.
// In Dart there is no reflective newInstance, so we accept a factory function.
class BasicClassIdentity<T> implements ClassIdentity<T> {
  final Type _underlyingClass;
  final String _simpleName;
  final T Function() _factory;

  BasicClassIdentity(Type cl, String simpleName, T Function() factory)
      : _underlyingClass = cl,
        _simpleName = simpleName,
        _factory = factory;

  @override
  String getName() => _simpleName;

  @override
  Type getReferenceClass() => _underlyingClass;

  @override
  T newInstance() => _factory();

  @override
  String getReferenceDescription() => _simpleName;

  @override
  bool isMember(T item) => item.runtimeType == _underlyingClass;

  @override
  String toString() => 'Identity: ${getReferenceDescription()}';

  @override
  int get hashCode => _underlyingClass.hashCode;

  @override
  bool operator ==(Object o) {
    if (o is BasicClassIdentity) {
      return _underlyingClass == o._underlyingClass;
    }
    return false;
  }

  @override
  String getPersistentFormat() => getName().toUpperCase();

  static ClassIdentity<T> getIdentity<T>(Type cl, String simpleName, T Function() factory) {
    return BasicClassIdentity<T>(cl, simpleName, factory);
  }
}
