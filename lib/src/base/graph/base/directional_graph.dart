import 'edge.dart';
import 'graph.dart';

abstract interface class DirectionalGraph<N, ET extends Edge<N>>
    implements Graph<N, ET> {
  Set<N> getAdjacentSources(N v);
  Set<N> getAdjacentSinks(N v);
  Set<ET> getInwardEdgeList(N v);
  Set<ET> getOutwardEdgeList(N v);
}
