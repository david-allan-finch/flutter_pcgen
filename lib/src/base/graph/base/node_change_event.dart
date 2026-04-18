class NodeChangeEvent<N> {
  final Object source;
  final N graphNode;

  const NodeChangeEvent(this.source, this.graphNode);
}
