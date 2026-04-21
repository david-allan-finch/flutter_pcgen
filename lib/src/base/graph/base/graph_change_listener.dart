import 'package:flutter_pcgen/src/base/graph/base/edge.dart';
import 'package:flutter_pcgen/src/base/graph/base/node_change_event.dart';
import 'package:flutter_pcgen/src/base/graph/base/edge_change_event.dart';

abstract interface class GraphChangeListener<N, ET extends Edge<N>> {
  void nodeAdded(NodeChangeEvent<N> event);
  void nodeRemoved(NodeChangeEvent<N> event);
  void edgeAdded(EdgeChangeEvent<N, ET> event);
  void edgeRemoved(EdgeChangeEvent<N, ET> event);
}
