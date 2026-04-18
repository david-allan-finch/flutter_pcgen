// Exception thrown by the persistence (data loading) layer.
class PersistenceLayerException implements Exception {
  final String message;
  final Object? cause;

  const PersistenceLayerException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) return 'PersistenceLayerException: $message (caused by $cause)';
    return 'PersistenceLayerException: $message';
  }
}
