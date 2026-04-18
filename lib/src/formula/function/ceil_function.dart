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

class CeilFunction implements FormulaFunction {
  static const NumberManager _manager = NumberManager();

  @override
  String getFunctionName() => 'CEIL';

  @override
  bool isStatic(StaticVisitor visitor, List<Node> args) =>
      args.length == 1 && visitor.visit(args[0], null);

  @override
  FormatManager<dynamic> allowArgs(
      SemanticsVisitor visitor, List<Node> args, FormulaSemantics semantics) {
    if (args.length != 1) throw ArgumentError('CEIL requires exactly 1 argument');
    visitor.visit(args[0], semantics);
    return _manager;
  }

  @override
  Object evaluate(EvaluateVisitor visitor, List<Node> args, EvaluationManager manager) {
    final value = visitor.visit(args[0], manager) as num;
    return value.ceil();
  }

  @override
  FormatManager<dynamic>? getDependencies(
      DependencyVisitor visitor, DependencyManager manager, List<Node> args) {
    if (args.isNotEmpty) visitor.visit(args[0], manager);
    return _manager;
  }
}
