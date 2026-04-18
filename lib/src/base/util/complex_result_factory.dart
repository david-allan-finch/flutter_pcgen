import 'complex_result.dart';
import 'failure_result.dart';

class _SuccessResult<T> implements ComplexResult<T> {
  final T _value;
  const _SuccessResult(this._value);

  @override
  bool isValid() => true;

  @override
  T get() => _value;

  @override
  String? getFailedMessage() => null;

  @override
  String toString() => 'Success: $_value';
}

class ComplexResultFactory {
  ComplexResultFactory._();

  static ComplexResult<T> success<T>(T value) => _SuccessResult(value);
  static ComplexResult<T> failure<T>(String message) => FailureResult(message);
}
