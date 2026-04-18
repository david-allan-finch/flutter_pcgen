// Translation of pcgen.output.base.PCGenObjectWrapper

/// PCGenObjectWrapper wraps an object into an output model, using the CharID
/// to resolve character-specific information if necessary.
abstract interface class PCGenObjectWrapper {
  /// Wrap the given object into an output model, using the CharID if necessary.
  dynamic wrap(String charId, Object obj);
}
