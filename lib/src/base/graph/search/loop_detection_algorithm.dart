import '../base/directional_graph.dart';
import '../base/directional_graph_edge.dart';
import '../base/edge.dart';

class LoopDetectionAlgorithm<N, ET extends Edge<N>> {
  final DirectionalGraph<N, ET> _graph;

  LoopDetectionAlgorithm(this._graph);

  bool hasLoop() {
    final visited = <N>{};
    final inStack = <N>{};

    bool dfs(N node) {
      visited.add(node);
      inStack.add(node);
      for (final sink in _graph.getAdjacentSinks(node)) {
        if (!visited.contains(sink)) {
          if (dfs(sink)) return true;
        } else if (inStack.contains(sink)) {
          return true;
        }
      }
      inStack.remove(node);
      return false;
    }

    for (final node in _graph.getNodeList()) {
      if (!visited.contains(node)) {
        if (dfs(node)) return true;
      }
    }
    return false;
  }
}
