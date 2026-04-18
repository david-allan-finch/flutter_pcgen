// Translation of pcgen.io.ExportException

/// Thrown when an error occurs during character sheet export.
class ExportException implements Exception {
  final String message;
  final Object? cause;

  ExportException(this.message, [this.cause]);

  @override
  String toString() => 'ExportException: $message${cause != null ? ' caused by $cause' : ''}';
}
