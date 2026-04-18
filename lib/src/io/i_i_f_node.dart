// Translation of pcgen.io.IIFNode

/// Represents an IIF (inline-if) conditional node in an export template.
class IIFNode {
  final String condition;
  final List<Object> trueChildren = [];
  final List<Object> falseChildren = [];

  IIFNode(this.condition);

  void addTrueChild(Object child) => trueChildren.add(child);
  void addFalseChild(Object child) => falseChildren.add(child);
}
