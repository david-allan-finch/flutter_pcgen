class UnreachableError extends Error {
  final String message;
  UnreachableError([this.message = 'Unreachable code was reached']);

  @override
  String toString() => 'UnreachableError: $message';
}
