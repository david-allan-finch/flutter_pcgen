import '../../../base/util/format_manager.dart';
import '../../../base/format/boolean_manager.dart';
import '../../base/unary_action.dart';
import '../../parse/operator.dart';

class BooleanNot implements UnaryAction {
  static const BooleanManager _manager = BooleanManager();

  @override
  Operator getOperator() => Operator.not;

  @override
  FormatManager<dynamic>? processAbstract(Type format) {
    if (format == bool) return _manager;
    return null;
  }

  @override
  Object evaluate(Object argument) => !(argument as bool);
}
