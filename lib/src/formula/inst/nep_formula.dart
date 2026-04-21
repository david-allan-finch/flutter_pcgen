import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/formula/base/evaluation_manager.dart';
import 'package:flutter_pcgen/src/formula/parse/node.dart';
import 'package:flutter_pcgen/src/formula/visitor/evaluate_visitor.dart';

// NEPFormula - a parsed formula ready for evaluation.
// NEP = "New Expression Parser"
abstract interface class NEPFormula<T> {
  T evaluate(EvaluationManager manager);
  FormatManager<T> getFormatManager();
  bool isStatic();
  String toExpression();
}
