// Observable reference (single value) abstraction for the facade layer.
abstract interface class ReferenceFacade<E> {
  E? get();
  void addReferenceListener(void Function(ReferenceChangeEvent<E>) listener);
  void removeReferenceListener(void Function(ReferenceChangeEvent<E>) listener);
}

class ReferenceChangeEvent<E> {
  final Object source;
  final E? oldValue;
  final E? newValue;
  const ReferenceChangeEvent(this.source, this.oldValue, this.newValue);
}
