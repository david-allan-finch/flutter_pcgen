import '../../../rules/context/load_context.dart';

/// A PostDeferredToken is processed after LST file load is complete AND after
/// references are resolved.
abstract interface class PostDeferredToken<T> {
  /// Process the post-deferred token. Returns true if successful.
  bool process(LoadContext context, T obj);

  /// Returns the Type of object this PostDeferredToken operates on.
  Type getDeferredTokenClass();

  /// Returns the priority (lower = processed first).
  int getPriority();
}
