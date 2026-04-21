import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'dependency_manager.dart';
import 'evaluation_manager.dart';
import 'formula_semantics.dart';
import 'package:flutter_pcgen/src/formula/parse/node.dart';
import 'package:flutter_pcgen/src/formula/visitor/dependency_visitor.dart';
import 'package:flutter_pcgen/src/formula/visitor/evaluate_visitor.dart';
import 'package:flutter_pcgen/src/formula/visitor/semantics_visitor.dart';
import 'package:flutter_pcgen/src/formula/visitor/static_visitor.dart';

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
