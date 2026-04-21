import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/formula/base/operator_action.dart';
import 'package:flutter_pcgen/src/formula/base/operator_library.dart';
import 'package:flutter_pcgen/src/formula/base/unary_action.dart';
import 'package:flutter_pcgen/src/formula/parse/operator.dart';

class SimpleOperatorLibrary implements OperatorLibrary {
  final List<OperatorAction> _binaryActions = [];
  final List<UnaryAction> _unaryActions = [];

  @override
  void addAction(OperatorAction action) => _binaryActions.add(action);

  @override
  void addUnaryAction(UnaryAction action) => _unaryActions.add(action);

  @override
  Object evaluate(Operator operator, Object left, Object right,
      FormatManager<dynamic>? asserted) {
    for (final action in _binaryActions) {
      if (action.getOperator() == operator) {
        final result = action.processAbstract(left.runtimeType, right.runtimeType, asserted);
        if (result != null) {
          return action.evaluate(left, right, asserted);
        }
      }
    }
    throw StateError('No OperatorAction found for $operator on ${left.runtimeType}, ${right.runtimeType}');
  }

  @override
  FormatManager<dynamic>? processAbstract(Operator operator, Type format1,
      Type format2, FormatManager<dynamic>? asserted) {
    for (final action in _binaryActions) {
      if (action.getOperator() == operator) {
        final result = action.processAbstract(format1, format2, asserted);
        if (result != null) return result;
      }
    }
    return null;
  }

  @override
  Object evaluateUnary(Operator operator, Object argument) {
    for (final action in _unaryActions) {
      if (action.getOperator() == operator) {
        final result = action.processAbstract(argument.runtimeType);
        if (result != null) {
          return action.evaluate(argument);
        }
      }
    }
    throw StateError('No UnaryAction found for $operator on ${argument.runtimeType}');
  }

  @override
  FormatManager<dynamic>? processAbstractUnary(Operator operator, Type format) {
    for (final action in _unaryActions) {
      if (action.getOperator() == operator) {
        final result = action.processAbstract(format);
        if (result != null) return result;
      }
    }
    return null;
  }
}
