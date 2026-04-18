import '../../rules/context/load_context.dart';

// Functional interface for parsing a single LST token value onto an object.
abstract interface class CDOMLoader<T> {
  bool parseLine(LoadContext context, T obj, String val, String source);
}
