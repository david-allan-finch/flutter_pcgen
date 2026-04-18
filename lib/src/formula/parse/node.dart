// Represents a node in the formula parse tree.
// Corresponds to the SimpleNode/Node types from the JavaCC-generated parser.
abstract interface class Node {
  Node? jjtGetParent();
  void jjtSetParent(Node? n);
  void jjtAddChild(Node n, int i);
  Node jjtGetChild(int i);
  int jjtGetNumChildren();
  Object? jjtAccept(dynamic visitor, Object? data);
}
