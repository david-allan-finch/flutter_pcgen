import 'package:flutter_pcgen/src/base/graph/base/edge.dart';
import 'package:flutter_pcgen/src/base/graph/base/graph_change_listener.dart';

abstract interface class Graph<N, ET extends Edge<N>> {
  bool addNode(N v);
  bool addEdge(ET e);
  bool containsNode(Object? v);
  bool containsEdge(ET e);
  Set<N> getAdjacentNodes(N v);
  Set<ET> getAdjacentEdges(N v);
  bool removeNode(N v);
  bool removeEdge(ET e);
  Set<N> getNodeList();
  Set<ET> getEdgeList();
  bool isEmpty();
  int nodeCount();
  int edgeCount();
  void addGraphChangeListener(GraphChangeListener<N, ET> listener);
  void removeGraphChangeListener(GraphChangeListener<N, ET> listener);
}
