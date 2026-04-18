import '../../../base/util/format_manager.dart';
import 'operator_action.dart';
import 'unary_action.dart';
import '../parse/operator.dart';

abstract interface class OperatorLibrary {
  void addAction(OperatorAction action);
  void addUnaryAction(UnaryAction action);

  Object evaluate(Operator operator, Object left, Object right,
      FormatManager<dynamic>? asserted);

  FormatManager<dynamic>? processAbstract(Operator operator, Type format1,
      Type format2, FormatManager<dynamic>? asserted);

  Object evaluateUnary(Operator operator, Object argument);

  FormatManager<dynamic>? processAbstractUnary(Operator operator, Type format);
}
