// Translation of pcgen.gui3.core.IORuntimeException

/// Runtime exception wrapping an IOException from the PCGen I/O layer.
class IORuntimeException implements Exception {
  final String message;
  final Object? cause;

  const IORuntimeException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) return 'IORuntimeException: $message (caused by: $cause)';
    return 'IORuntimeException: $message';
  }
}
