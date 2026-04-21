import 'package:flutter_pcgen/src/formula/parse/node.dart';
import 'package:flutter_pcgen/src/formula/base/formula_semantics.dart';

abstract interface class SemanticsVisitor {
  Object? visit(Node node, FormulaSemantics semantics);
}
