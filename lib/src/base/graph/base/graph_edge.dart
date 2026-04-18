import 'edge.dart';

abstract interface class GraphEdge<N> implements Edge<N> {
  N getNodeAt(int index);
}
