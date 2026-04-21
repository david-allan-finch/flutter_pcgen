import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/formula/base/evaluation_manager.dart';
import 'package:flutter_pcgen/src/formula/parse/node.dart';
import 'package:flutter_pcgen/src/formula/visitor/evaluate_visitor.dart';
import 'package:flutter_pcgen/src/formula/visitor/static_visitor.dart';
import 'nep_formula.dart';

// A full formula parsed from a string expression.
class ComplexNEPFormula<T> implements NEPFormula<T> {
  final String _expression;
  final FormatManager<T> _formatManager;
  final Node _rootNode;
  final EvaluateVisitor _evaluateVisitor;
  final StaticVisitor _staticVisitor;

  ComplexNEPFormula(
    this._expression,
    this._formatManager,
    this._rootNode,
    this._evaluateVisitor,
    this._staticVisitor,
  );

  @override
  T evaluate(EvaluationManager manager) {
    return _evaluateVisitor.visit(_rootNode, manager) as T;
  }

  @override
  FormatManager<T> getFormatManager() => _formatManager;

  @override
  bool isStatic() => _staticVisitor.visit(_rootNode, null);

  @override
  String toExpression() => _expression;

  @override
  String toString() => 'Formula($_expression)';
}
