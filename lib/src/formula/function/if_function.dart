import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/formula/base/formula_function.dart';
import 'package:flutter_pcgen/src/formula/base/dependency_manager.dart';
import 'package:flutter_pcgen/src/formula/base/evaluation_manager.dart';
import 'package:flutter_pcgen/src/formula/base/formula_semantics.dart';
import 'package:flutter_pcgen/src/formula/parse/node.dart';
import 'package:flutter_pcgen/src/formula/visitor/dependency_visitor.dart';
import 'package:flutter_pcgen/src/formula/visitor/evaluate_visitor.dart';
import 'package:flutter_pcgen/src/formula/visitor/semantics_visitor.dart';
import 'package:flutter_pcgen/src/formula/visitor/static_visitor.dart';

class IfFunction implements FormulaFunction {
  @override
  String getFunctionName() => 'IF';

  @override
  bool isStatic(StaticVisitor visitor, List<Node> args) {
    if (args.length < 2 || args.length > 3) return false;
    return args.every((arg) => visitor.visit(arg, null));
  }

  @override
  FormatManager<dynamic> allowArgs(
      SemanticsVisitor visitor, List<Node> args, FormulaSemantics semantics) {
    if (args.length < 2 || args.length > 3) {
      throw ArgumentError('IF requires 2 or 3 arguments');
    }
    visitor.visit(args[0], semantics); // condition
    final result = visitor.visit(args[1], semantics) as FormatManager<dynamic>?;
    if (args.length == 3) visitor.visit(args[2], semantics);
    return result ?? (visitor.visit(args[0], semantics) as FormatManager<dynamic>);
  }

  @override
  Object evaluate(EvaluateVisitor visitor, List<Node> args, EvaluationManager manager) {
    final condition = visitor.visit(args[0], manager) as bool;
    if (condition) {
      return visitor.visit(args[1], manager)!;
    } else if (args.length == 3) {
      return visitor.visit(args[2], manager)!;
    }
    return false;
  }

  @override
  FormatManager<dynamic>? getDependencies(
      DependencyVisitor visitor, DependencyManager manager, List<Node> args) {
    for (final arg in args) visitor.visit(arg, manager);
    return null;
  }
}
