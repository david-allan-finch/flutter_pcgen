// Translation of pcgen.output.base.ModeModelFactory

/// A ModeModelFactory generates output model objects for the current Game Mode.
abstract interface class ModeModelFactory {
  /// Generates a model for the given game mode.
  dynamic generate(dynamic mode);
}
