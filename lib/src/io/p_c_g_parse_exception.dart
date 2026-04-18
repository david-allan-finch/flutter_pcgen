// Translation of pcgen.io.PCGParseException

/// Thrown when a PCG character file cannot be parsed.
class PCGParseException implements Exception {
  final String message;
  final int lineNumber;
  final Object? cause;

  PCGParseException(this.message, {this.lineNumber = -1, this.cause});

  @override
  String toString() =>
      'PCGParseException${lineNumber >= 0 ? ' (line $lineNumber)' : ''}: $message';
}
