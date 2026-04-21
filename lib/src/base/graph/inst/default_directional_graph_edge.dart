import 'package:flutter_pcgen/src/base/graph/base/directional_graph_edge.dart';

class DefaultDirectionalGraphEdge<N> implements DirectionalGraphEdge<N> {
  final N _source;
  final N _sink;

  const DefaultDirectionalGraphEdge(this._source, this._sink);

  @override
  N getSource() => _source;

  @override
  N getSink() => _sink;

  @override
  List<N> getAdjacentNodes() => [_source, _sink];

  @override
  bool isConnected(N node) => node == _source || node == _sink;

  @override
  N getNodeAt(int index) {
    if (index == 0) return _source;
    if (index == 1) return _sink;
    throw RangeError('Index $index out of range');
  }
}
