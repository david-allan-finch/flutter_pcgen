import 'reference_facade.dart';

// Mutable, observable reference to a single value.
class DefaultReferenceFacade<E> implements ReferenceFacade<E> {
  E? _object;
  final List<void Function(ReferenceChangeEvent<E>)> _listeners = [];

  DefaultReferenceFacade([this._object]);

  @override
  E? get() => _object;

  void set(E? object) {
    if (_object == object) return;
    final old = _object;
    _object = object;
    final event = ReferenceChangeEvent<E>(this, old, object);
    for (final l in List.of(_listeners)) l(event);
  }

  @override
  void addReferenceListener(void Function(ReferenceChangeEvent<E>) listener) {
    _listeners.add(listener);
  }

  @override
  void removeReferenceListener(void Function(ReferenceChangeEvent<E>) listener) {
    _listeners.remove(listener);
  }

  @override
  String toString() => _object.toString();
}
