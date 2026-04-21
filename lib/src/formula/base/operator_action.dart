import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/formula/parse/operator.dart';

abstract interface class OperatorAction {
  Operator getOperator();
  FormatManager<dynamic>? processAbstract(Type format1, Type format2, FormatManager<dynamic>? asserted);
  Object evaluate(Object left, Object right, FormatManager<dynamic>? asserted);
}
