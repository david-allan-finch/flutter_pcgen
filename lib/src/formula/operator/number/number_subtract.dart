import '../../../base/util/format_manager.dart';
import '../../../base/format/number_manager.dart';
import '../../base/operator_action.dart';
import '../../parse/operator.dart';

class NumberSubtract implements OperatorAction {
  static const NumberManager _manager = NumberManager();

  @override
  Operator getOperator() => Operator.sub;

  @override
  FormatManager<dynamic>? processAbstract(Type format1, Type format2, FormatManager<dynamic>? asserted) {
    if ((format1 == num || format1 == int || format1 == double) &&
        (format2 == num || format2 == int || format2 == double)) {
      return _manager;
    }
    return null;
  }

  @override
  Object evaluate(Object left, Object right, FormatManager<dynamic>? asserted) {
    return (left as num) - (right as num);
  }
}
