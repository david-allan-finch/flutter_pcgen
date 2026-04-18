import '../parse/node.dart';
import '../base/formula_semantics.dart';

abstract interface class SemanticsVisitor {
  Object? visit(Node node, FormulaSemantics semantics);
}
