class SemanticsException implements Exception {
  final String message;
  const SemanticsException(this.message);

  @override
  String toString() => 'SemanticsException: $message';
}
