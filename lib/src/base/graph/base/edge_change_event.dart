import 'package:flutter_pcgen/src/base/graph/base/edge.dart';

class EdgeChangeEvent<N, ET extends Edge<N>> {
  final Object source;
  final ET graphEdge;

  const EdgeChangeEvent(this.source, this.graphEdge);
}
