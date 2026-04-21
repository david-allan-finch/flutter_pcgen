import 'package:flutter_pcgen/src/base/graph/base/edge.dart';
import 'package:flutter_pcgen/src/base/graph/base/graph.dart';

class DepthFirstTraverseAlgorithm<N, ET extends Edge<N>> {
  final Graph<N, ET> _graph;

  DepthFirstTraverseAlgorithm(this._graph);

  List<N> traverse(N startNode) {
    final visited = <N>[];
    final stack = <N>[startNode];
    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      if (visited.contains(node)) continue;
      visited.add(node);
      for (final adjacent in _graph.getAdjacentNodes(node)) {
        if (!visited.contains(adjacent)) {
          stack.add(adjacent);
        }
      }
    }
    return visited;
  }
}
