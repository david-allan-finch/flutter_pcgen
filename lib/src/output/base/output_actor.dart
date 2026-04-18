// Translation of pcgen.output.base.OutputActor

/// Processes an interpolation and converts it into a template model
/// representing the contents of a specific item.
///
/// Note: FreeMarker TemplateModel is not available in Dart; dynamic is used.
abstract interface class OutputActor<T> {
  /// Processes this OutputActor on the given object to produce output data.
  dynamic process(String charId, T obj);
}
