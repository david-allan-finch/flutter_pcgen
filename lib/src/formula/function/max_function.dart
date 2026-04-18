import 'dart:math' as math;
import '../../../base/util/format_manager.dart';
import '../../../base/format/number_manager.dart';
import '../base/formula_function.dart';
import '../base/dependency_manager.dart';
import '../base/evaluation_manager.dart';
import '../base/formula_semantics.dart';
import '../parse/node.dart';
import '../visitor/dependency_visitor.dart';
import '../visitor/evaluate_visitor.dart';
import '../visitor/semantics_visitor.dart';
import '../visitor/static_visitor.dart';

class MaxFunction implements FormulaFunction {
  static const NumberManager _manager = NumberManager();

  @override
  String getFunctionName() => 'MAX';

  @override
  bool isStatic(StaticVisitor visitor, List<Node> args) {
    return args.every((arg) => visitor.visit(arg, null));
  }

  @override
  FormatManager<dynamic> allowArgs(
      SemanticsVisitor visitor, List<Node> args, FormulaSemantics semantics) {
    if (args.length < 2) {
      throw ArgumentError('MAX requires at least 2 arguments');
    }
    for (final arg in args) visitor.visit(arg, semantics);
    return _manager;
  }

  @override
  Object evaluate(EvaluateVisitor visitor, List<Node> args, EvaluationManager manager) {
    num result = visitor.visit(args[0], manager) as num;
    for (int i = 1; i < args.length; i++) {
      final val = visitor.visit(args[i], manager) as num;
      result = math.max(result, val);
    }
    return result;
  }

  @override
  FormatManager<dynamic>? getDependencies(
      DependencyVisitor visitor, DependencyManager manager, List<Node> args) {
    for (final arg in args) visitor.visit(arg, manager);
    return _manager;
  }
}
