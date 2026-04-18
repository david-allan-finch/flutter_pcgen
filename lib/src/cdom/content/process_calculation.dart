import '../../base/util/format_manager.dart';

// A ProcessCalculation wraps a direct object and a BasicCalculation, applying
// the calculation's operation using the stored object as the operand.
class ProcessCalculation<T> {
  final T _obj;
  final dynamic _basicCalculation; // BasicCalculation<T> — typed loosely
  final FormatManager<T> _formatManager;

  ProcessCalculation(T object, dynamic calc, FormatManager<T> fmtManager)
      : _obj = object,
        _basicCalculation = calc,
        _formatManager = fmtManager;

  T process(dynamic evalManager) {
    final T? input = evalManager?.get(#INPUT) as T?;
    return _basicCalculation.process(input, _obj) as T;
  }

  String getInstructions() => _formatManager.unconvert(_obj);

  dynamic getBasicCalculation() => _basicCalculation;

  @override
  int get hashCode => _obj.hashCode ^ _basicCalculation.hashCode;

  @override
  bool operator ==(Object o) {
    if (o is ProcessCalculation<T>) {
      return o._basicCalculation == _basicCalculation && o._obj == _obj;
    }
    return false;
  }
}
