import '../base/cdom_reference.dart';

// A reference to a single CDOMObject by key name.
abstract interface class CDOMSingleRef<T> implements CDOMReference<T> {
  // Gets the resolved object (may throw if not resolved).
  T get();

  // Returns true if the referenced object has been resolved.
  bool hasBeenResolved();
}
