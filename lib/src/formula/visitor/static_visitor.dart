import '../parse/node.dart';

abstract interface class StaticVisitor {
  bool visit(Node node, Object? data);
}
