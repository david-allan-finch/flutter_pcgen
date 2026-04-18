import '../../../base/util/format_manager.dart';
import 'dependency_manager.dart';
import 'evaluation_manager.dart';
import 'formula_semantics.dart';
import '../parse/node.dart';
import '../visitor/dependency_visitor.dart';
import '../visitor/evaluate_visitor.dart';
import '../visitor/semantics_visitor.dart';
import '../visitor/static_visitor.dart';

abstract interface class FormulaFunction {
  String getFunctionName();

  bool isStatic(StaticVisitor visitor, List<Node> args);

  FormatManager<dynamic> allowArgs(
      SemanticsVisitor visitor, List<Node> args, FormulaSemantics semantics);

  Object evaluate(
      EvaluateVisitor visitor, List<Node> args, EvaluationManager manager);

  FormatManager<dynamic>? getDependencies(
      DependencyVisitor visitor, DependencyManager manager, List<Node> args);
}
