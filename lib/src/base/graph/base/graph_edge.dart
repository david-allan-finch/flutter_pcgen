import 'package:flutter_pcgen/src/base/graph/base/edge.dart';

abstract interface class GraphEdge<N> implements Edge<N> {
  N getNodeAt(int index);
}
