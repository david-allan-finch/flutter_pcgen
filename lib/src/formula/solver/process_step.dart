import 'package:flutter_pcgen/src/formula/solver/modifier.dart';

class ProcessStep<T> {
  final Modifier<T> modifier;
  final T inputValue;
  final T result;

  const ProcessStep(this.modifier, this.inputValue, this.result);

  @override
  String toString() =>
      '${modifier.getIdentification()}: $inputValue → $result';
}
