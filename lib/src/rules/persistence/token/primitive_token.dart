import '../../../rules/context/load_context.dart';
import 'cdom_token.dart';

/// A PrimitiveToken selects zero or more objects of a specific type.
/// Typically used as part of a CHOOSE.
abstract interface class PrimitiveToken<T> implements LstToken {
  /// Initialize the token with a value and optional args.
  /// Returns true if initialization succeeded.
  bool initialize(LoadContext context, Type cl, String? value, String? args);
}
