import 'reference_facade.dart';

/// Base class for [ReferenceFacade] implementations providing listener
/// management and a fire helper method.
abstract class AbstractReferenceFacade<T> implements ReferenceFacade<T> {
  final List<void Function(ReferenceChangeEvent<T>)> _listeners = [];

  @override
  void addReferenceListener(void Function(ReferenceChangeEvent<T>) listener) {
    _listeners.add(listener);
  }

  @override
  void removeReferenceListener(
      void Function(ReferenceChangeEvent<T>) listener) {
    _listeners.remove(listener);
  }

  void fireReferenceChangedEvent(Object source, T? old, T? newer) {
    final event = ReferenceChangeEvent<T>(source, old, newer);
    for (final l in List.of(_listeners)) l(event);
  }
}
