import 'package:flutter_pcgen/src/formula/parse/node.dart';

abstract interface class StaticVisitor {
  bool visit(Node node, Object? data);
}
