class LegalVariableException implements Exception {
  final String message;
  const LegalVariableException(this.message);

  @override
  String toString() => 'LegalVariableException: $message';
}
