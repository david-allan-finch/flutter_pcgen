import '../../../rules/context/load_context.dart';

/// A PostValidationToken is processed after LST file load is complete and
/// after references are resolved. It operates on ALL objects of a given type.
abstract interface class PostValidationToken<T> {
  /// Process the token across all collected objects. Returns true if successful.
  bool process(LoadContext context, List<T> collection);

  /// Returns the Type of object this PostValidationToken operates on.
  Type getValidationTokenClass();

  /// Returns the priority (lower = processed first).
  int getPriority();
}
