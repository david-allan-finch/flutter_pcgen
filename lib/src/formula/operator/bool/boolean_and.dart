import '../../../base/util/format_manager.dart';
import '../../../base/format/boolean_manager.dart';
import '../../base/operator_action.dart';
import '../../parse/operator.dart';

class BooleanAnd implements OperatorAction {
  static const BooleanManager _manager = BooleanManager();

  @override
  Operator getOperator() => Operator.and;

  @override
  FormatManager<dynamic>? processAbstract(Type format1, Type format2, FormatManager<dynamic>? asserted) {
    if (format1 == bool && format2 == bool) return _manager;
    return null;
  }

  @override
  Object evaluate(Object left, Object right, FormatManager<dynamic>? asserted) {
    return (left as bool) && (right as bool);
  }
}
