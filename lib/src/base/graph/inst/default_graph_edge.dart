import 'package:flutter_pcgen/src/base/graph/base/graph_edge.dart';

class DefaultGraphEdge<N> implements GraphEdge<N> {
  final N _node1;
  final N _node2;

  const DefaultGraphEdge(this._node1, this._node2);

  @override
  List<N> getAdjacentNodes() => [_node1, _node2];

  @override
  bool isConnected(N node) => node == _node1 || node == _node2;

  @override
  N getNodeAt(int index) {
    if (index == 0) return _node1;
    if (index == 1) return _node2;
    throw RangeError('Index $index out of range');
  }
}
