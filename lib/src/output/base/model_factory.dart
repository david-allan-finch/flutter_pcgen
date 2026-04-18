// Translation of pcgen.output.base.ModelFactory

/// A ModelFactory generates output model objects when given a CharID.
abstract interface class ModelFactory {
  /// Generates a model for the given CharID.
  dynamic generate(String charId);
}
