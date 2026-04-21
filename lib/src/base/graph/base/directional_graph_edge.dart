import 'package:flutter_pcgen/src/base/graph/base/graph_edge.dart';

abstract interface class DirectionalGraphEdge<N> implements GraphEdge<N> {
  N getSource();
  N getSink();
}
