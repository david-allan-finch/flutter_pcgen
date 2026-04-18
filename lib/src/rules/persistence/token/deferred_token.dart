import '../../../rules/context/load_context.dart';

/// A DeferredToken is processed after LST file load is complete but before
/// references are resolved.
abstract interface class DeferredToken<T> {
  /// Process the deferred token. Returns true if successful.
  bool process(LoadContext context, T obj);

  /// Returns the Type of object this DeferredToken operates on.
  Type getDeferredTokenClass();
}
