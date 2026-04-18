import '../parse/node.dart';
import '../base/evaluation_manager.dart';

abstract interface class EvaluateVisitor {
  Object? visit(Node node, EvaluationManager manager);
}
