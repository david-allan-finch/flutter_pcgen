import 'edge.dart';
import 'node_change_event.dart';
import 'edge_change_event.dart';

abstract interface class GraphChangeListener<N, ET extends Edge<N>> {
  void nodeAdded(NodeChangeEvent<N> event);
  void nodeRemoved(NodeChangeEvent<N> event);
  void edgeAdded(EdgeChangeEvent<N, ET> event);
  void edgeRemoved(EdgeChangeEvent<N, ET> event);
}
