import 'package:flutter_pcgen/src/base/util/complex_result.dart';

class FailureResult<T> implements ComplexResult<T> {
  final String _message;
  const FailureResult(this._message);

  @override
  bool isValid() => false;

  @override
  T? get() => null;

  @override
  String getFailedMessage() => _message;

  @override
  String toString() => 'Failure: $_message';
}
