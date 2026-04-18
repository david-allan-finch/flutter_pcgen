abstract interface class ComplexResult<T> {
  bool isValid();
  T? get();
  String? getFailedMessage();
}
