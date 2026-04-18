import '../../base/util/format_manager.dart';
import '../base/evaluation_manager.dart';
import '../parse/node.dart';
import '../visitor/evaluate_visitor.dart';

// NEPFormula - a parsed formula ready for evaluation.
// NEP = "New Expression Parser"
abstract interface class NEPFormula<T> {
  T evaluate(EvaluationManager manager);
  FormatManager<T> getFormatManager();
  bool isStatic();
  String toExpression();
}
