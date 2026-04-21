import 'dart:math' as math;
import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/base/format/number_manager.dart';
import 'package:flutter_pcgen/src/formula/base/operator_action.dart';
import 'package:flutter_pcgen/src/formula/parse/operator.dart';

class NumberExp implements OperatorAction {
  static const NumberManager _manager = NumberManager();

  @override
  Operator getOperator() => Operator.exp;

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
    return math.pow(left as num, right as num);
  }
}
