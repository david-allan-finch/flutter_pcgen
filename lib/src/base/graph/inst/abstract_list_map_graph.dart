import '../base/edge.dart';
import '../base/graph.dart';
import '../base/graph_change_listener.dart';
import '../base/node_change_event.dart';
import '../base/edge_change_event.dart';

abstract class AbstractListMapGraph<N, ET extends Edge<N>>
    implements Graph<N, ET> {
  final Map<N, List<ET>> _nodeMap = {};
  final List<ET> _edgeList = [];
  final List<GraphChangeListener<N, ET>> _listeners = [];

  @override
  bool addNode(N v) {
    if (_nodeMap.containsKey(v)) return false;
    _nodeMap[v] = [];
    _fireNodeAdded(v);
    return true;
  }

  @override
  bool addEdge(ET e) {
    for (final node in e.getAdjacentNodes()) {
      _nodeMap.putIfAbsent(node, () => []);
      _nodeMap[node]!.add(e);
    }
    _edgeList.add(e);
    _fireEdgeAdded(e);
    return true;
  }

  @override
  bool containsNode(Object? v) => _nodeMap.containsKey(v);

  @override
  bool containsEdge(ET e) => _edgeList.contains(e);

  @override
  Set<N> getAdjacentNodes(N v) {
    final edges = _nodeMap[v] ?? [];
    final result = <N>{};
    for (final e in edges) {
      result.addAll(e.getAdjacentNodes().where((n) => n != v).cast<N>());
    }
    return result;
  }

  @override
  Set<ET> getAdjacentEdges(N v) => Set<ET>.from(_nodeMap[v] ?? []);

  @override
  bool removeNode(N v) {
    if (!_nodeMap.containsKey(v)) return false;
    final edges = List<ET>.from(_nodeMap[v]!);
    for (final e in edges) removeEdge(e);
    _nodeMap.remove(v);
    _fireNodeRemoved(v);
    return true;
  }

  @override
  bool removeEdge(ET e) {
    if (!_edgeList.remove(e)) return false;
    for (final node in e.getAdjacentNodes()) {
      _nodeMap[node]?.remove(e);
    }
    _fireEdgeRemoved(e);
    return true;
  }

  @override
  Set<N> getNodeList() => Set<N>.from(_nodeMap.keys);

  @override
  Set<ET> getEdgeList() => Set<ET>.from(_edgeList);

  @override
  bool isEmpty() => _nodeMap.isEmpty;

  @override
  int nodeCount() => _nodeMap.length;

  @override
  int edgeCount() => _edgeList.length;

  @override
  void addGraphChangeListener(GraphChangeListener<N, ET> listener) =>
      _listeners.add(listener);

  @override
  void removeGraphChangeListener(GraphChangeListener<N, ET> listener) =>
      _listeners.remove(listener);

  void _fireNodeAdded(N v) {
    final event = NodeChangeEvent(this, v);
    for (final l in _listeners) l.nodeAdded(event);
  }

  void _fireNodeRemoved(N v) {
    final event = NodeChangeEvent(this, v);
    for (final l in _listeners) l.nodeRemoved(event);
  }

  void _fireEdgeAdded(ET e) {
    final event = EdgeChangeEvent<N, ET>(this, e);
    for (final l in _listeners) l.edgeAdded(event);
  }

  void _fireEdgeRemoved(ET e) {
    final event = EdgeChangeEvent<N, ET>(this, e);
    for (final l in _listeners) l.edgeRemoved(event);
  }
}
