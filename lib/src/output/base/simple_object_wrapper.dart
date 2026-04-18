// Translation of pcgen.output.base.SimpleObjectWrapper

/// SimpleObjectWrapper wraps an object into an output model.
abstract interface class SimpleObjectWrapper {
  /// Wrap the given object into an output model.
  /// Throws StateError if this wrapper does not support the given object.
  dynamic wrap(Object obj);
}
