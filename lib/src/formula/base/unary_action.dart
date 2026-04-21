import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/formula/parse/operator.dart';

abstract interface class UnaryAction {
  Operator getOperator();
  FormatManager<dynamic>? processAbstract(Type format);
  Object evaluate(Object argument);
}
