import '../../../rules/context/load_context.dart';
import 'parse_result.dart';

// Mirrors LstToken – provides getTokenName().
abstract interface class LstToken {
  String getTokenName();
}

/// A CDOMToken parses one LST token key+value onto an object of type [T].
abstract interface class CDOMToken<T> implements LstToken {
  ParseResult parseToken(LoadContext context, T obj, String value);

  /// Returns the runtime type class this token operates on.
  /// In Dart we use a Type object instead of Java's Class<T>.
  Type getTokenClass();
}
