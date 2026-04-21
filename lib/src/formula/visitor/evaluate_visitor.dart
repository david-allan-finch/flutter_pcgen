import 'package:flutter_pcgen/src/formula/parse/node.dart';
import 'package:flutter_pcgen/src/formula/base/evaluation_manager.dart';

abstract interface class EvaluateVisitor {
  Object? visit(Node node, EvaluationManager manager);
}
