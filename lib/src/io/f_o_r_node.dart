// Translation of pcgen.io.FORNode

/// Represents a FOR loop node in an export template.
class FORNode {
  final String varName;
  final String min;
  final String max;
  final String step;
  final bool exists;
  final List<Object> children = [];

  FORNode(this.varName, this.min, this.max, this.step, this.exists);

  void addChild(Object child) => children.add(child);
}
