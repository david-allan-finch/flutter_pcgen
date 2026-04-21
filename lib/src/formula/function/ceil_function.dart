import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/base/format/number_manager.dart';
import 'package:flutter_pcgen/src/formula/base/formula_function.dart';
import 'package:flutter_pcgen/src/formula/base/dependency_manager.dart';
import 'package:flutter_pcgen/src/formula/base/evaluation_manager.dart';
import 'package:flutter_pcgen/src/formula/base/formula_semantics.dart';
import 'package:flutter_pcgen/src/formula/parse/node.dart';
import 'package:flutter_pcgen/src/formula/visitor/dependency_visitor.dart';
import 'package:flutter_pcgen/src/formula/visitor/evaluate_visitor.dart';
import 'package:flutter_pcgen/src/formula/visitor/semantics_visitor.dart';
import 'package:flutter_pcgen/src/formula/visitor/static_visitor.dart';

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
