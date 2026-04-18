// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.TermEvaulatorException
// (preserves original Java spelling "Evaulator" intentionally)

/// Exception thrown when a term string cannot be parsed into an evaluator.
class TermEvaulatorException implements Exception {
  final String message;
  final Object? cause;

  const TermEvaulatorException(this.message, [this.cause]);

  @override
  String toString() {
    final buf = StringBuffer('TermEvaulatorException: $message');
    if (cause != null) buf.write(' (caused by: $cause)');
    return buf.toString();
  }
}
