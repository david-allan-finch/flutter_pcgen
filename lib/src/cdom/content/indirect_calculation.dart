import '../../base/util/indirect.dart';

// An IndirectCalculation wraps an Indirect object and a BasicCalculation,
// applying the calculation's operation using the indirect's resolved value.
//
// Equivalent to the formula system's AbstractNEPCalculation with an Indirect.
class IndirectCalculation<T> {
  final Indirect<T> _obj;
  final dynamic _basicCalculation; // BasicCalculation<T> — typed loosely

  IndirectCalculation(Indirect<T> object, dynamic calc)
      : _obj = object,
        _basicCalculation = calc;

  T process(dynamic evalManager) {
    final T? input = evalManager?.get(#INPUT) as T?;
    return _basicCalculation.process(input, _obj.get()) as T;
  }

  String getInstructions() => _obj.getUnconverted();

  dynamic getBasicCalculation() => _basicCalculation;

  @override
  int get hashCode => _obj.hashCode ^ _basicCalculation.hashCode;

  @override
  bool operator ==(Object o) {
    if (o is IndirectCalculation<T>) {
      return o._basicCalculation == _basicCalculation && o._obj == _obj;
    }
    return false;
  }
}
